/*
    SHA3 message padding
    b    = r (rate) + c (capacity)
    SHA3-256 : b = 1600, r = 1088, c = 512
*/
module message_padding #(
    // ---------------- User parameters ----------------
    parameter STATE_W   = 1600,                 // b : Keccak state width
    parameter CAPACITY  = 512,                  // c : 2 * output length
    parameter LANE_W    = 64,                   // ROM / lane word width
    parameter MAX_WORDS = 64,                   // ROM depth (in LANE_W words)
    parameter [7:0] DSUFFIX  = 8'h06,           // SHA3 domain suffix
    parameter [7:0] PAD_LAST = 8'h80            // final pad bit
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               start,
    input  logic               absorb_ready,    // keccak core can take a block
    output logic [STATE_W-1:0] m,               // padded block
    output logic               blk_valid,       // m holds a valid block
    output logic               blk_last,        // m is the final block
    output logic               done             // all blocks absorbed
);

    // ---------------- Derived parameters ----------------
    localparam RATE           = STATE_W - CAPACITY;            // 1088
    localparam BYTES_PER_WORD = LANE_W / 8;                    // 8
    localparam RATE_WORDS     = RATE / LANE_W;                 // 17
    localparam RATE_BYTES     = RATE / 8;                      // 136
    localparam MAX_BLOCKS     = (MAX_WORDS * BYTES_PER_WORD) / RATE_BYTES + 1;
    localparam COUNT_W        = $clog2(MAX_BLOCKS + 2);        // never wraps

    // ---------------- Storage / variables ----------------
    logic [LANE_W-1:0]  rom [0:MAX_WORDS-1];
    logic [COUNT_W-1:0] count;
    logic [STATE_W-1:0] next_blk;
    logic [7:0]         pad_byte;
    logic               load, accept;

    integer msg_len;          // bytes in last (partial) block
    integer num_blocks;       // number of full RATE_BYTES blocks

    // =====================================================
    // Count valid bytes in message
    // =====================================================
    always_comb begin
        msg_len    = 0;
        num_blocks = 0;
        for (int i = 0; i < MAX_WORDS; i++) begin
            for (int j = 0; j < BYTES_PER_WORD; j++) begin
                if ((rom[i][j*8 +: 8] !== 8'hxx) &&
                    (rom[i][j*8 +: 8] !== 8'h00)) begin
                    msg_len = msg_len + 1;
                    if (msg_len == RATE_BYTES) begin
                        num_blocks = num_blocks + 1;
                        msg_len    = 0;
                    end
                end
            end
        end
    end

    // =====================================================
    // Build block for current count (full or padded last)
    // =====================================================
    always_comb begin
        next_blk = '0;                                  // capacity = 0
        for (int k = 0; k < RATE_BYTES; k++) begin
            pad_byte = rom[count*RATE_WORDS + k/BYTES_PER_WORD]
                          [(k % BYTES_PER_WORD)*8 +: 8];

            if (count == num_blocks) begin              // last block
                if (k >= msg_len)        pad_byte = 8'h00;
                if (k == msg_len)        pad_byte = pad_byte | DSUFFIX;
                if (k == RATE_BYTES - 1) pad_byte = pad_byte | PAD_LAST;
            end

            next_blk[k*8 +: 8] = pad_byte;
        end
    end

    // =====================================================
    // Handshake : hold block until (blk_valid && absorb_ready)
    // =====================================================
    assign accept = blk_valid && absorb_ready;
    assign load   = start && !done &&
                    (count <= num_blocks) &&
                    (!blk_valid || absorb_ready);       // empty or being taken

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m         <= '0;
            count     <= '0;
            blk_valid <= 1'b0;
            blk_last  <= 1'b0;
            done      <= 1'b0;
        end
        else begin
            // current block consumed by core
            if (accept) begin
                blk_valid <= 1'b0;
                if (blk_last) done <= 1'b1;
            end

            // present next block
            if (load) begin
                m         <= next_blk;
                blk_valid <= 1'b1;
                blk_last  <= (count == num_blocks);
                count     <= count + 1'b1;
            
            end
        end
    end

endmodule


// =========================================================
// Testbench
// =========================================================
module tb_keccak;

    parameter STATE_W   = 1600;
    parameter CAPACITY  = 512;
    parameter LANE_W    = 64;
    parameter MAX_WORDS = 64;
    parameter MEM_FILE  = "rtl/keccak_msg.mem";

    localparam RATE = STATE_W - CAPACITY;

    reg                clk;
    reg                rst_n;
    reg                start;
    reg                absorb_ready;
    wire [STATE_W-1:0] m;
    wire               blk_valid, blk_last, done;

    message_padding #(
        .STATE_W   (STATE_W),
        .CAPACITY  (CAPACITY),
        .LANE_W    (LANE_W),
        .MAX_WORDS (MAX_WORDS)
    ) k1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .start        (start),
        .absorb_ready (absorb_ready),
        .m            (m),
        .blk_valid    (blk_valid),
        .blk_last     (blk_last),
        .done         (done)
    );

    always #5 clk = ~clk;

    // ---------------- load ROM ----------------
    initial begin
        $readmemh(MEM_FILE, k1.rom);
    end

    // ---------------- monitor ----------------
    always @(negedge clk) begin
        if (blk_valid)
            $display("[%0t] last=%0b\nm(r) = (0x%h)\n",$time, blk_last, m[RATE-1:0]);
    end

    // ---------------- stimulus ----------------
    initial begin
        clk          = 0;
        rst_n        = 0;
        start        = 0;
        absorb_ready = 1;
        #10;
        rst_n = 1;
        start = 1;

        wait (done);
        #20;
        $finish;
    end

endmodule

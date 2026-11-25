/*
    SHA3 message padding 
    b    = r (rate) + c (capacity)
    SHA3-256 : b = 1600, r = 1088, c = 512

    Usage:
      1. Drive msg_bytes with the total message length in bytes.
      2. Assert start. Padded blocks are presented on m with
         blk_valid; a block is consumed when blk_valid && absorb_ready.
*/
module message_padding #(
    // ---------------- User parameters ----------------
    parameter STATE_W   = 1600,                 // b : Keccak state width
    parameter CAPACITY  = 512,                  // c : 2 * output length
    parameter LANE_W    = 64,                   // buffer / lane word width
    parameter MAX_WORDS = 64,                   // buffer depth (in LANE_W words)
    parameter [7:0] DSUFFIX  = 8'h06,           // SHA3 domain suffix
    parameter [7:0] PAD_LAST = 8'h80,           // final pad bit
    parameter LEN_W     = $clog2(MAX_WORDS * LANE_W/8 + 1)  // 10
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire [LEN_W-1:0]     msg_bytes,       // message length in bytes
    input  wire                 start,
    input  wire                 absorb_ready,    // keccak core can take a block
    output reg  [STATE_W-1:0]   m,               // padded block
    output reg                  blk_valid,       // m holds a valid block
    output reg                  blk_last,        // m is the final block
    output reg                  done             // all blocks absorbed
);

    // ---------------- Derived parameters ----------------  for SHA-256
    localparam RATE           = STATE_W - CAPACITY;            // 1088
    localparam BYTES_PER_WORD = LANE_W / 8;                    // 8
    localparam RATE_WORDS     = RATE / LANE_W;                 // 17
    localparam RATE_BYTES     = RATE / 8;                      // 136
    localparam MAX_BYTES      = MAX_WORDS * BYTES_PER_WORD;    // 512
    localparam MAX_BLOCKS     = MAX_BYTES / RATE_BYTES + 1;
    localparam COUNT_W        = $clog2(MAX_BLOCKS + 2);         // never wraps
    localparam BIDX_W         = $clog2(RATE_BYTES + 1);

    // ---------------- Storage / variables ----------------
    reg  [LANE_W-1:0]   rom [0:MAX_WORDS-1];
    reg  [COUNT_W-1:0]  count;
    reg  [STATE_W-1:0]  next_blk;
    reg  [7:0]          pad_byte;
    wire                load, accept;

    wire [COUNT_W-1:0]  num_blocks;   // number of full RATE_BYTES blocks
    wire [BIDX_W-1:0]   msg_len;      // bytes in last (partial) block

    integer k;                        // byte loop variable (static unroll)

    // =====================================================
    // Block count / tail length (divide by constant)
    // =====================================================
    assign num_blocks = msg_bytes / RATE_BYTES;
    assign msg_len    = msg_bytes - num_blocks * RATE_BYTES;

    // =====================================================
    // Build block for current count (full or padded last)
    // =====================================================
    always @(*) begin
        next_blk = {STATE_W{1'b0}};                     // capacity = 0
        for (k = 0; k < RATE_BYTES; k = k + 1) begin
            // k-th message byte of the current block
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
                    (!blk_valid || absorb_ready);      

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m         <= {STATE_W{1'b0}};
            count     <= {COUNT_W{1'b0}};
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

`ifdef messagepadding
// =========================================================
// Testbench (simulation only)
// =========================================================
module tb_keccak;

    parameter STATE_W   = 1600;
    parameter CAPACITY  = 512;
    parameter LANE_W    = 64;
    parameter MAX_WORDS = 64;
    parameter MEM_FILE  = "rtl/keccak_msg.mem";

    localparam RATE      = STATE_W - CAPACITY;
    localparam BPW       = LANE_W / 8;

    reg                clk;
    reg                rst_n;
    reg                start;
    reg                absorb_ready;
    reg  [9:0]         msg_bytes;
    wire [STATE_W-1:0] m;
    wire               blk_valid, blk_last, done;

    integer            i, j;

    message_padding #(
        .STATE_W   (STATE_W),
        .CAPACITY  (CAPACITY),
        .LANE_W    (LANE_W),
        .MAX_WORDS (MAX_WORDS)
    ) k1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .msg_bytes    (msg_bytes),
        .start        (start),
        .absorb_ready (absorb_ready),
        .m            (m),
        .blk_valid    (blk_valid),
        .blk_last     (blk_last),
        .done         (done)
    );

    always #5 clk = ~clk;

    // ---------------- monitor ----------------
    always @(negedge clk) begin
        if (blk_valid)
            $display("[%0t] last=%0b\nm(r) = (0x%h)\n",$time, blk_last, m[RATE-1:0]);
    end
    initial begin
        $fsdbdumpfile("tb.fsdb");
        $fsdbdumpvars(0, tb_keccak);
    end
    // ---------------- stimulus ----------------
    initial begin
        clk          = 0;
        rst_n        = 0;
        start        = 0;
        absorb_ready = 1;
        msg_bytes    = 0;

        // load message directly into DUT ROM, then count its bytes
        $readmemh(MEM_FILE, k1.rom);
        for (i = 0; i < MAX_WORDS; i = i + 1)
            for (j = 0; j < BPW; j = j + 1)
                if (k1.rom[i][j*8 +: 8] !== 8'hxx)
                    msg_bytes = msg_bytes + 1;
        $display("message length = %0d bytes", msg_bytes);

        #10;
        rst_n = 1;
        start = 1;
        wait (done);
        #20;
        $finish;
    end

endmodule
`endif
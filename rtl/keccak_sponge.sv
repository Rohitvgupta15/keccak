module keccak_sponge#(
    // ---------------- User parameters ----------------
    parameter STATE_W   = 1600,                 // b : Keccak state width
    parameter CAPACITY  = 512,                  // c : 2 * output length
    parameter LANE_W    = 64,                   // ROM / lane word width
    parameter MAX_WORDS = 64,                   // ROM depth (in LANE_W words)
    parameter [7:0] DSUFFIX  = 8'h06,           // SHA3 domain suffix
    parameter [7:0] PAD_LAST = 8'h80,            // final pad bit
    parameter LEN_W     = $clog2(MAX_WORDS * LANE_W + 1)  // 10
)(
    input             clk,
    input             rst_n,
    input [LEN_W-1:0] msg_bits,
    input             start,
    output            done,
    output [255:0]    hashvalue 
);
parameter IDLE         = 2'b00,
          PADDING      = 2'b01,
          ABSORB       = 2'b10,
          KECCAK_ROUND = 2'b11;
          
reg [1:0] state,next_state;

reg start_message_pading;
reg absorb_ready;
wire [1599:0]  m;
wire           blk_valid;
wire           blk_last;
wire           message_padding_done;


reg [1599:0] absorb_out;
reg           start_keccak_round;
reg           last_blk;
wire [1599:0] keccak_round_out;
wire          keccak_round_done;

message_padding #(
    .STATE_W  (STATE_W),           // b : Keccak state width
    .CAPACITY (CAPACITY),          // c : 2 * output length
    .LANE_W   (LANE_W),            // ROM / lane word width
    .MAX_WORDS(MAX_WORDS),         // ROM depth (in LANE_W words)
    .DSUFFIX  (DSUFFIX),           // SHA3 domain suffix
    .PAD_LAST (PAD_LAST)           // final pad bit
) s1(
    .clk          (clk),
    .rst_n        (rst_n),
    .msg_bits    (msg_bits),
    .start        (start_message_pading),
    .absorb_ready (absorb_ready),           // keccak core can take a block
    .m            (m),                      // padded block
    .blk_valid    (blk_valid),              // m holds a valid block
    .blk_last     (blk_last),               // m is the final block
    .done         (message_padding_done)    // all blocks absorbed
);

keccak_round S3(
    .clk        (clk),
    .rst_n      (rst_n),
    .start      (start_keccak_round),
    .state_in   (absorb_out),   
    .state_out  (keccak_round_out),              
    .done       (keccak_round_done)
);
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state              <= IDLE;
        absorb_out         <= '0;
        start_keccak_round <= 1'b0;
        last_blk           <= 1'b0;
    end
    else begin
        state              <= next_state;
        start_keccak_round <= (state == ABSORB);   
        if (state == ABSORB) begin
            absorb_out <= m ^ keccak_round_out;    
            last_blk   <= blk_last;               
        end
    end
end

always @(*) begin
    next_state           = state;
    start_message_pading = (state != IDLE);       
    absorb_ready         = 1'b0;
    case (state)
        IDLE: begin
            if (start)
                next_state = PADDING;
        end
        PADDING: begin
            if (blk_valid)
                next_state = ABSORB;
        end
        ABSORB: begin
            absorb_ready = 1'b1;                   
            next_state   = KECCAK_ROUND;
        end
        KECCAK_ROUND: begin
            if (keccak_round_done && !start_keccak_round)
                next_state = last_blk ? IDLE : PADDING;
        end
        default: next_state = IDLE;
    endcase
end

assign done      = last_blk && keccak_round_done && !start_keccak_round;
assign hashvalue = done ? keccak_round_out[255:0] : 256'd0;
endmodule

`ifdef keccak_sponge
// =========================================================
// Testbench (simulation only)
// =========================================================
module tb_keccakq;

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
    reg  [12:0]        msg_bits;     // Widened to hold up to 4096 bits (MAX_WORDS * LANE_W)
    wire               done;
    wire   [255:0]     hashvalue;

    integer            i, b;
    reg                found;

    keccak_sponge #(
        .STATE_W   (STATE_W),
        .CAPACITY  (CAPACITY),
        .LANE_W    (LANE_W),
        .MAX_WORDS (MAX_WORDS)
    ) ks1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .msg_bits    (msg_bits),    // Pass bit count directly (removed *8)
        .start        (start),
        .done         (done),
        .hashvalue    (hashvalue)
    );

    always #5 clk = ~clk;

    // initial begin
    //     $dumpfile("tb.vcd");
    //     $dumpvars(1, tb_keccakq);
    // end

    // ---------------- stimulus ----------------
    initial begin
        clk      = 0;
        rst_n    = 0;
        start    = 0;
        msg_bits = 0;

        for (i = 0; i < MAX_WORDS; i = i + 1)
            ks1.s1.rom[i] = {LANE_W{1'bx}};

        $readmemh(MEM_FILE, ks1.s1.rom);

  
        found = 0;
        for (i = MAX_WORDS - 1; i >= 0; i = i - 1) begin
            for (b = LANE_W - 1; b >= 0; b = b - 1) begin
                if (!found && (ks1.s1.rom[i][b] === 1'b1)) begin
                    msg_bits = (i * LANE_W) + b + 1;
                    found    = 1;
                end
            end
        end

        $display("message length = %0d bit", msg_bits);

        #10;
        rst_n = 1;
        start = 1;
        @(posedge clk);                        // FSM samples start here
        @(negedge clk) start = 0;              // drop it safely after the edge
        @(posedge clk); 
        #50;
        $display("num block      = %h", ks1.s1.num_blocks);
        $display("Message len    = %h", ks1.s1.msg_len);
        $display("Absorb message = %h", ks1.absorb_out);
        wait (done);
        $display("hello");
        @(posedge clk);
        $display("[%0t] HASH = %h", $time, hashvalue);
        #20;
        
        $finish;
    end

    always @(posedge ks1.keccak_round_done)
        $display("[%0t] block done, state = %h", $time, ks1.keccak_round_out);

endmodule
`endif
module keccak_sponge#(
    // ---------------- User parameters ----------------
    parameter STATE_W   = 1600,                 // b : Keccak state width
    parameter CAPACITY  = 512,                  // c : 2 * output length
    parameter LANE_W    = 64,                   // ROM / lane word width
    parameter MAX_WORDS = 64,                   // ROM depth (in LANE_W words)
    parameter [7:0] DSUFFIX  = 8'h06,           // SHA3 domain suffix
    parameter [7:0] PAD_LAST = 8'h80            // final pad bit
)(
    input           clk,
    input           rst_n,
    input           start,
    output          done,
    output [1599:0] hashvalue 
);

message_padding #(
    .STATE_W  (STATE_W),           // b : Keccak state width
    .CAPACITY (CAPACITY),          // c : 2 * output length
    .lane_w   (LANE_W),            // ROM / lane word width
    .MAX      (MAX_WORDS),         // ROM depth (in LANE_W words)
    .DSUFFIX  (DSUFFIX),           // SHA3 domain suffix
    .PAD_LAST (PAD_LAST)           // final pad bit
)(
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (start),
    .absorb_ready (absorb_ready),    // keccak core can take a block
    .m            (m),               // padded block
    .blk_valid    (blk_valid),       // m holds a valid block
    .blk_last     (blk_last),        // m is the final block
    .done         (done)             // all blocks absorbed
);
keccak_absorb s2(
    .in         (in),
    .state_in   (state_in),
    .out        (out)
);
keccak_round S3(
    .clk        (clk),
    .rst_n      (rst_n),
    .start      (start),
    .state_in   (state_in),   
    .state_out  (state_out),              
    .done       (done)             
);
endmodule
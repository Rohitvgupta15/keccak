module keccak_absorb(
    input [1599:0] in,
    input [1599:0] state_in,
    output [1599:0] out
);
assign out = state_in ^ in;

endmodule
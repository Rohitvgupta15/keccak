module keccak_iota (
    input  wire [1599:0] state_in,
    input  wire [4:0] round,
    output wire [1599:0] state_out
);
    wire [63:0] in  [0:4][0:4];
    wire [63:0] out [0:4][0:4];
    function [63:0] round_constant;
        input [4:0] idx;
        begin
            case (idx)
                5'd0: round_constant = 64'h0000000000000001;
                5'd1: round_constant = 64'h0000000000008082;
                5'd2: round_constant = 64'h800000000000808a;
                5'd3: round_constant = 64'h8000000080008000;
                5'd4: round_constant = 64'h000000000000808b;
                5'd5: round_constant = 64'h0000000080000001;
                5'd6: round_constant = 64'h8000000080008081;
                5'd7: round_constant = 64'h8000000000008009;
                5'd8: round_constant = 64'h000000000000008a;
                5'd9: round_constant = 64'h0000000000000088;
                5'd10: round_constant = 64'h0000000080008009;
                5'd11: round_constant = 64'h000000008000000a;
                5'd12: round_constant = 64'h000000008000808b;
                5'd13: round_constant = 64'h800000000000008b;
                5'd14: round_constant = 64'h8000000000008089;
                5'd15: round_constant = 64'h8000000000008003;
                5'd16: round_constant = 64'h8000000000008002;
                5'd17: round_constant = 64'h8000000000000080;
                5'd18: round_constant = 64'h000000000000800a;
                5'd19: round_constant = 64'h800000008000000a;
                5'd20: round_constant = 64'h8000000080008081;
                5'd21: round_constant = 64'h8000000000008080;
                5'd22: round_constant = 64'h0000000080000001;
                5'd23: round_constant = 64'h8000000080008008;
                default: round_constant = 64'h0;
            endcase
        end
    endfunction

    genvar i, j;

    assign state_out = { state_in[1599:64],state_in[63:0] ^ round_constant(round)};
endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// reg  [4:0]    round;
// wire [1599:0] state_out;

// keccak_iota q1(
//     state_in,
//     round,
//     state_out
// );

// integer l,m;
//     initial begin
//         state_in = 1600'h9f9f9f9f9f9f9f9f20202020202020201d1d1d1d1d1d1d1da3a3a3a3a3a3a3a33939393939393939e4e4e4e4e4e4e4e4a3a3a3a3a3a3a3a3d7d7d7d7d7d7d7d720202020202020209393939393939393bebebebebebebebee2e2e2e2e2e2e2e2828282828282828218181818181818184f4f4f4f4f4f4f4fe8e8e8e8e8e8e8e8888888888888888860606060606060609c9c9c9c9c9c9c9c7474747474747474a6a6a6a6a6a6a6a69c9c9c9c9c9c9c9c4747474747474747d6d6d6d6d6d6d6d62121212121212121;        
//         round = 32'd0;
//         #10;
//         #10;

//          for(l = 0; l < 5; l = l + 1) begin
//             for(m = 0; m < 5; m = m + 1) begin
//                 $display("in[%0d][%0d] = %h",l,m,q1.out[l][m]);
//             end
//         end
    
//         $display("input = %h",state_in);
//         $display("output = %h",state_out);
//         $finish;
//     end

// endmodule
module keccak_chi (
    input  wire [1599:0] state_in,
    output wire [1599:0] state_out
);
    wire [63:0] in  [0:4][0:4];
    wire [63:0] out [0:4][0:4];

    genvar i, j;
    generate
        // 1. Unpack 1600-bit state into 5x5 64-bit lanes (A[x][y] = A[i][j])
        for (i = 0; i < 5; i = i + 1) begin : gen_unpack_x
            for (j = 0; j < 5; j = j + 1) begin : gen_unpack_y
                assign in[i][j]  = state_in[(i + 5*j)*64 +: 64];
                assign out[i][j] = in[i][j] ^ ( ~in[(i+1)%5][j] & in[(i+2)%5][j]);
                assign state_out[(i + 5*j)*64 +: 64] = out[i][j];
            end
        end
    endgenerate
endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// wire [1599:0] state_out;

// keccak_chi q1(
//     state_in,
//     state_out
// );

// integer l,m;
//     initial begin
//         state_in = 1600'h1d1d1d1d1d1d1d1d00000000000000000000000000000000a3a3a3a3a3a3a3a33939393939393939e4e4e4e4e4e4e4e4a3a3a3a3a3a3a3a39393939393939393000000000000000000000000000000008e8e8e8e8e8e8e8ea3a3a3a3a3a3a3a38e8e8e8e8e8e8e8e3939393939393939c9c9c9c9c9c9c9c9e8e8e8e8e8e8e8e89c9c9c9c9c9c9c9c000000000000000000000000000000007474747474747474e8e8e8e8e8e8e8e89c9c9c9c9c9c9c9c27272727272727274e4e4e4e4e4e4e4e0000000000000000;        #10;
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
module keccak_pi (
    input  wire [1599:0] state_in,
    output wire [1599:0] state_out
);
    wire [63:0] in  [0:4][0:4];
    wire [63:0] out [0:4][0:4];

    genvar i, j;
    generate
        for (i = 0; i < 5; i = i + 1) begin : gen_unpack_x
            for (j = 0; j < 5; j = j + 1) begin : gen_unpack_y
                assign in[i][j]  = state_in[(i + 5*j)*64 +: 64];
                assign out[j][(i*2 + j*3) %5] = in[i][j];
                assign state_out[(i + 5*j)*64 +: 64] = out[i][j];
            end
        end
    endgenerate
endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// wire [1599:0] state_out;

// keccak_pi q1(
//     state_in,
//     state_out
// );

// integer l,m;
//     initial begin
//         state_in = 1600'he8e8e8e8e8e8e8e8e4e4e4e4e4e4e4e4e8e8e8e8e8e8e8e81d1d1d1d1d1d1d1d8e8e8e8e8e8e8e8ea3a3a3a3a3a3a3a39c9c9c9c9c9c9c9ca3a3a3a3a3a3a3a39c9c9c9c9c9c9c9c000000000000000000000000000000008e8e8e8e8e8e8e8e2727272727272727939393939393939300000000000000000000000000000000a3a3a3a3a3a3a3a339393939393939394e4e4e4e4e4e4e4e0000000000000000000000000000000074747474747474743939393939393939c9c9c9c9c9c9c9c90000000000000000;
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
module keccak_theta (
    input  wire [1599:0] state_in,
    output wire [1599:0] state_out
);
    wire [63:0] in  [0:4][0:4];
    wire [63:0] c   [0:4];
    wire [63:0] d   [0:4];
    wire [63:0] out [0:4][0:4];

    function automatic [63:0] one_bit_rotate;
        input [63:0] lane;
        begin
            one_bit_rotate = {lane[62:0], lane[63]};
        end
    endfunction

    genvar i, j;
    generate
        // 1. Unpack 1600-bit state into 5x5 64-bit lanes (A[x][y] = A[i][j])
        for (i = 0; i < 5; i = i + 1) begin : gen_unpack_x
            for (j = 0; j < 5; j = j + 1) begin : gen_unpack_y
                assign in[i][j] = state_in[(i + j*5)*64 +: 64];
            end
        end

        // 2. Column parity C[x]
        for (i = 0; i < 5; i = i + 1) begin : gen_c
            assign c[i] = in[i][0] ^ in[i][1] ^ in[i][2] ^ in[i][3] ^ in[i][4];
        end

        // 3. Theta effect D[x]
        for (i = 0; i < 5; i = i + 1) begin : gen_d
            assign d[i] = c[(i == 0) ? 4 : (i - 1)] ^ one_bit_rotate(c[(i + 1) % 5]);
        end

        // 4. XOR D[x] into each lane and repack into 1600-bit output
        for (i = 0; i < 5; i = i + 1) begin : gen_pack_x
            for (j = 0; j < 5; j = j + 1) begin : gen_pack_y
                assign out[i][j] = in[i][j] ^ d[i];
                assign state_out[(i + j*5)*64 +: 64] = out[i][j];
            end
        end
    endgenerate
endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// wire [1599:0] state_out;

// keccak_theta q1(
//     state_in,
//     state_out
// );
// localparam logic [1599:0] THETA_OUT = {
//     64'hA3A3A3A3A3A3A3A3, // W24 (MSB)
//     64'hE4E4E4E4E4E4E4E4, // W23
//     64'h4747474747474747, // W22
//     64'h4747474747474747, // W21
//     64'hA3A3A3A3A3A3A3A3, // W20
//     64'hA3A3A3A3A3A3A3A3, // W19
//     64'hE4E4E4E4E4E4E4E4, // W18
//     64'h4747474747474747, // W17
//     64'hE4E4E4E4E4E4E4E4, // W16
//     64'h0000000000000000, // W15
//     64'h0000000000000000, // W14
//     64'h4747474747474747, // W13
//     64'hE4E4E4E4E4E4E4E4, // W12
//     64'hE4E4E4E4E4E4E4E4, // W11
//     64'h0000000000000000, // W10
//     64'h0000000000000000, // W09
//     64'h4747474747474747, // W08
//     64'hE4E4E4E4E4E4E4E4, // W07
//     64'hE4E4E4E4E4E4E4E4, // W06
//     64'h0000000000000000, // W05
//     64'h0000000000000000, // W04
//     64'h4747474747474747, // W03
//     64'hE4E4E4E4E4E4E4E4, // W02
//     64'hE4E4E4E4E4E4E4E4, // W01
//     64'h0000000000000000  // W00 (LSB)
// };
// integer i,j;
//     initial begin
//     state_in = {
//     // y = 4
//     64'h0000000000000000, // [4,4]
//     64'h0000000000000000, // [3,4]
//     64'h0000000000000000, // [2,4]
//     64'h0000000000000000, // [1,4]
//     64'h0000000000000000, // [0,4]

//     // y = 3
//     64'h0000000000000000, // [4,3]
//     64'h0000000000000000, // [3,3]
//     64'h0000000000000000, // [2,3]
//     64'hA3A3A3A3A3A3A3A3, // [1,3]
//     64'hA3A3A3A3A3A3A3A3, // [0,3]

//     // y = 2
//     64'hA3A3A3A3A3A3A3A3, // [4,2]
//     64'hA3A3A3A3A3A3A3A3, // [3,2]
//     64'hA3A3A3A3A3A3A3A3, // [2,2]
//     64'hA3A3A3A3A3A3A3A3, // [1,2]
//     64'hA3A3A3A3A3A3A3A3, // [0,2]

//     // y = 1
//     64'hA3A3A3A3A3A3A3A3, // [4,1]
//     64'hA3A3A3A3A3A3A3A3, // [3,1]
//     64'hA3A3A3A3A3A3A3A3, // [2,1]
//     64'hA3A3A3A3A3A3A3A3, // [1,1]
//     64'hA3A3A3A3A3A3A3A3, // [0,1]

//     // y = 0
//     64'hA3A3A3A3A3A3A3A3, // [4,0]
//     64'hA3A3A3A3A3A3A3A3, // [3,0]
//     64'hA3A3A3A3A3A3A3A3, // [2,0]
//     64'hA3A3A3A3A3A3A3A3, // [1,0]
//     64'hA3A3A3A3A3A3A3A3  // [0,0]
// };  
//         // for(i = 0; i < 5; i= i + 1) begin
//         //     for(j = 0; j < 5; j = j + 1) begin
//         //         $display("in[%0d][%0d] = %h",i,j,state_in[(i + j*5)*64 +: 64]);
//         //     end
//         // end
//         // #10;
//         // #10;

//         //  for(i = 0; i < 5; i= i + 1) begin
//         //     for(j = 0; j < 5; j = j + 1) begin
//         //         $display("out[%0d][%0d] = %h",i,j,q1.out[i][j]);
//         //     end
//         // end
    
//         $display("input = %h",state_in);
//         if(state_out == THETA_OUT)
//             $display("output matched = %h",state_out);
//         else
//             $display("output not matched = %h",state_out);
//         $finish;
//     end

// endmodule
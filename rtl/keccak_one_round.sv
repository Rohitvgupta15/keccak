module keccak_one_round (
    input  wire [1599:0] state_in,
    input  wire    [4:0] round,
    output wire [1599:0] state_out
);
    wire [1599:0] theta_out;
    wire [1599:0] rho_out;
    wire [1599:0] pi_out;
    wire [1599:0] chi_out;
 
        keccak_theta theta(
            .state_in(state_in),
            .state_out(theta_out)
        );
        keccak_rho rho(
            .state_in(theta_out),
            .state_out(rho_out)
        );
        keccak_pi pi(
            .state_in(rho_out),
            .state_out(pi_out)
        );
        keccak_chi chi(
            .state_in(pi_out),
            .state_out(chi_out)
        );
        keccak_iota iota(
            .state_in(chi_out),
            .round(round),
            .state_out(state_out)
        );

endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// reg  [4:0]    round;
// wire [1599:0] state_out;

// keccak_one_round q1(
//     state_in,
//     round,
//     state_out
// );
// localparam [1599:0] THETA_OUT = {
//     64'hA3A3A3A3A3A3A3A3, // W24
//     64'hE4E4E4E4E4E4E4E4,
//     64'h4747474747474747,
//     64'h4747474747474747,
//     64'hA3A3A3A3A3A3A3A3,
//     64'hA3A3A3A3A3A3A3A3,
//     64'hE4E4E4E4E4E4E4E4,
//     64'h4747474747474747,
//     64'hE4E4E4E4E4E4E4E4,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h4747474747474747,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hE4E4E4E4E4E4E4E4,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h4747474747474747,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hE4E4E4E4E4E4E4E4,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h4747474747474747,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hE4E4E4E4E4E4E4E4,
//     64'h0000000000000000  // W00
// };
// localparam [1599:0] RHO_OUT = {
//     64'hE8E8E8E8E8E8E8E8, // W24
//     64'hE4E4E4E4E4E4E4E4,
//     64'hE8E8E8E8E8E8E8E8,
//     64'h1D1D1D1D1D1D1D1D,
//     64'h8E8E8E8E8E8E8E8E,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h9C9C9C9C9C9C9C9C,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h8E8E8E8E8E8E8E8E,
//     64'h2727272727272727,
//     64'h9393939393939393,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h3939393939393939,
//     64'h4E4E4E4E4E4E4E4E,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h7474747474747474,
//     64'h3939393939393939,
//     64'hC9C9C9C9C9C9C9C9,
//     64'h0000000000000000  // W00
// };
// localparam [1599:0] PI_OUT = {
//     64'h1D1D1D1D1D1D1D1D, // W24
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h3939393939393939,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h9393939393939393,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h8E8E8E8E8E8E8E8E,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h8E8E8E8E8E8E8E8E,
//     64'h3939393939393939,
//     64'hC9C9C9C9C9C9C9C9,
//     64'hE8E8E8E8E8E8E8E8,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h0000000000000000,
//     64'h0000000000000000,
//     64'h7474747474747474,
//     64'hE8E8E8E8E8E8E8E8,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h2727272727272727,
//     64'h4E4E4E4E4E4E4E4E,
//     64'h0000000000000000  // W00
// };
// localparam [1599:0] CHI_OUT = {
//     64'h9F9F9F9F9F9F9F9F, // W24
//     64'h2020202020202020,
//     64'h1D1D1D1D1D1D1D1D,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h3939393939393939,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hA3A3A3A3A3A3A3A3,
//     64'hD7D7D7D7D7D7D7D7,
//     64'h2020202020202020,
//     64'h9393939393939393,
//     64'hBEBEBEBEBEBEBEBE,
//     64'hE2E2E2E2E2E2E2E2,
//     64'h8282828282828282,
//     64'h1818181818181818,
//     64'h4F4F4F4F4F4F4F4F,
//     64'hE8E8E8E8E8E8E8E8,
//     64'h8888888888888888,
//     64'h6060606060606060,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h7474747474747474,
//     64'hA6A6A6A6A6A6A6A6,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h4747474747474747,
//     64'hD6D6D6D6D6D6D6D6,
//     64'h2121212121212121  // W00
// };
// localparam [1599:0] IOTA_OUT = {
//     64'h9F9F9F9F9F9F9F9F, // W24
//     64'h2020202020202020,
//     64'h1D1D1D1D1D1D1D1D,
//     64'hA3A3A3A3A3A3A3A3,
//     64'h3939393939393939,
//     64'hE4E4E4E4E4E4E4E4,
//     64'hA3A3A3A3A3A3A3A3,
//     64'hD7D7D7D7D7D7D7D7,
//     64'h2020202020202020,
//     64'h9393939393939393,
//     64'hBEBEBEBEBEBEBEBE,
//     64'hE2E2E2E2E2E2E2E2,
//     64'h8282828282828282,
//     64'h1818181818181818,
//     64'h4F4F4F4F4F4F4F4F,
//     64'hE8E8E8E8E8E8E8E8,
//     64'h8888888888888888,
//     64'h6060606060606060,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h7474747474747474,
//     64'hA6A6A6A6A6A6A6A6,
//     64'h9C9C9C9C9C9C9C9C,
//     64'h4747474747474747,
//     64'hD6D6D6D6D6D6D6D6,
//     64'h2121212121212120  // W00, RC[0] applied
// };
// integer l,m;
//     initial begin
//    state_in = {
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
//         round = 32'd0;
//         #10;
//         #100;

//         $display("input = %h",state_in);
//         for(l = 0; l < 5; l = l + 1) begin
//             for(m = 0; m < 5; m = m + 1) begin
//                 $display("in[%0d][%0d] = %h",l,m,state_in[(l + m*5)*64 +: 64]);
//             end
//         end
//         if(q1.theta_out === THETA_OUT)
//             $display("theta matched = %h",q1.theta_out);
//         else
//             $display("theta not matched = %h",q1.theta_out);

//         if(q1.rho_out === RHO_OUT)
//             $display("rho matched= %h",q1.rho_out);
//         else
//              $display("rho not matched= %h",q1.rho_out);

//         if(q1.pi_out === PI_OUT)
//             $display("pi matched= %h",q1.pi_out);
//         else
//             $display("pi not matched= %h",q1.pi_out);

//         if(q1.chi_out === CHI_OUT)
//             $display("chi matched= %h",q1.chi_out);
//         else
//             $display("chi not matched= %h",q1.chi_out);

//         if(state_out === IOTA_OUT)
//             $display("output(iota output) matched= %h",state_out);
//         else    
//             $display("output(iota output) not matched= %h",state_out);
//         $finish;
//     end

// endmodule
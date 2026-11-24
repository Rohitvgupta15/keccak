module keccak_rho (
    input  wire [1599:0] state_in,
    output wire [1599:0] state_out
);
    wire [63:0] in  [0:4][0:4];
    wire [63:0] out [0:4][0:4];
    function [5:0] rho_offset;
        input [4:0] lane;
        begin
            case (lane)
                5'd0: rho_offset = 6'd0;
                5'd1: rho_offset = 6'd1;
                5'd2: rho_offset = 6'd62;
                5'd3: rho_offset = 6'd28;
                5'd4: rho_offset = 6'd27;
                5'd5: rho_offset = 6'd36;
                5'd6: rho_offset = 6'd44;
                5'd7: rho_offset = 6'd6;
                5'd8: rho_offset = 6'd55;
                5'd9: rho_offset = 6'd20;
                5'd10: rho_offset = 6'd3;
                5'd11: rho_offset = 6'd10;
                5'd12: rho_offset = 6'd43;
                5'd13: rho_offset = 6'd25;
                5'd14: rho_offset = 6'd39;
                5'd15: rho_offset = 6'd41;
                5'd16: rho_offset = 6'd45;
                5'd17: rho_offset = 6'd15;
                5'd18: rho_offset = 6'd21;
                5'd19: rho_offset = 6'd8;
                5'd20: rho_offset = 6'd18;
                5'd21: rho_offset = 6'd2;
                5'd22: rho_offset = 6'd61;
                5'd23: rho_offset = 6'd56;
                5'd24: rho_offset = 6'd14;
                default: rho_offset = 6'd0;
            endcase
        end
    endfunction

    function automatic [63:0] one_bit_rotate;
        input [63:0] lane;
        input [5:0] shift_amount;
        begin
            if(shift_amount == 0)
                one_bit_rotate = lane;
            else 
                one_bit_rotate = (lane << shift_amount) | (lane >> (64 - shift_amount));
        end
    endfunction

    genvar i, j;
    generate
        for (i = 0; i < 5; i = i + 1) begin : gen_unpack_x
            for (j = 0; j < 5; j = j + 1) begin : gen_unpack_y
                assign in[i][j]  = state_in[(i + 5*j)*64 +: 64];
                assign out[i][j] =  one_bit_rotate(in[i][j] , rho_offset(i + 5*j));
                assign state_out[(i + 5*j)*64 +: 64] = out[i][j];
            end
        end
    endgenerate
endmodule

// module tb_keccak;

// reg  [1599:0] state_in;
// wire [1599:0] state_out;

// keccak_rho q1(
//     state_in,
//     state_out
// );

// integer l,m;
//     initial begin
//         state_in = 1600'ha3a3a3a3a3a3a3a3e4e4e4e4e4e4e4e447474747474747474747474747474747a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3e4e4e4e4e4e4e4e44747474747474747e4e4e4e4e4e4e4e4000000000000000000000000000000004747474747474747e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000004747474747474747e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4000000000000000000000000000000004747474747474747e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e40000000000000000;
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
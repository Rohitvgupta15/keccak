module keccak_round (
    input                      clk,
    input                    rst_n,
    input                    start,
    input  wire [1599:0]  state_in,
    output      [1599:0] state_out,
    output reg                done
);
    reg  [1599:0] state;
    wire [1599:0] next_state;
    reg  [4:0]    round;
    reg           busy;

    keccak_one_round u1(
        .state_in(state),
        .round(round),
        .state_out(next_state)
    );

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            round     <= 5'b0;
            state     <=  'd0;
            busy      <= 1'd0;
            done      <= 1'd0;
        end
        else begin
            if(start && !busy)begin
                    state <= state_in;
                    busy  <= 1'd1;
                    round <= 5'd0;
                    done  <= 1'd0;
            end else if(busy) begin
                state <= next_state;
                if(round == 5'd23) begin
                    busy <= 1'd0;
                    done <= 1'd1;
                end else begin
                    round <= round + 5'd1;
                    done  <= 1'd0;
                end
            end
        end
    end
    assign state_out = done ? state : 'd0;
endmodule

`ifdef DEBUG
module tb_keccak;
reg clk;
reg rst_n;
reg start;
reg  [1599:0] state_in;
wire [1599:0] state_out;
wire done;

keccak_round q1(
    clk,
    rst_n,
    start,
    state_in,
    state_out,
    done
);

integer l,m;
always #5 clk = ~clk;
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(1, tb_keccak);
end
    initial begin
        rst_n = 1'd0; clk = 0; start = 1'd0;
        #10;
        rst_n = 1'd1;
        @(negedge clk);
   state_in = {
    // y = 4
    64'h0000000000000000, // [4,4]
    64'h0000000000000000, // [3,4]
    64'h0000000000000000, // [2,4]
    64'h0000000000000000, // [1,4]
    64'h0000000000000000, // [0,4]

    // y = 3
    64'h0000000000000000, // [4,3]
    64'h0000000000000000, // [3,3]
    64'h0000000000000000, // [2,3]
    64'hA3A3A3A3A3A3A3A3, // [1,3]
    64'hA3A3A3A3A3A3A3A3, // [0,3]

    // y = 2
    64'hA3A3A3A3A3A3A3A3, // [4,2]
    64'hA3A3A3A3A3A3A3A3, // [3,2]
    64'hA3A3A3A3A3A3A3A3, // [2,2]
    64'hA3A3A3A3A3A3A3A3, // [1,2]
    64'hA3A3A3A3A3A3A3A3, // [0,2]

    // y = 1
    64'hA3A3A3A3A3A3A3A3, // [4,1]
    64'hA3A3A3A3A3A3A3A3, // [3,1]
    64'hA3A3A3A3A3A3A3A3, // [2,1]
    64'hA3A3A3A3A3A3A3A3, // [1,1]
    64'hA3A3A3A3A3A3A3A3, // [0,1]

    // y = 0
    64'hA3A3A3A3A3A3A3A3, // [4,0]
    64'hA3A3A3A3A3A3A3A3, // [3,0]
    64'hA3A3A3A3A3A3A3A3, // [2,0]
    64'hA3A3A3A3A3A3A3A3, // [1,0]
    64'hA3A3A3A3A3A3A3A3  // [0,0]
   };
        $display({100{"="}});
        $display("time = %0t | input = %h",$time,state_in);
        $display({100{"="}});
        start = 1'd1;                 // one-cycle start pulse
        @(negedge clk) start = 1'd0;
        wait(done == 1);
        @(negedge clk);               // sample away from the clock edge
        $display("time = %0t | Output = %h",$time, state_out);
        $display({100{"="}});

    state_in = {

    // y = 4
    64'h211E0B7352E9ECCE, // [4,4]
    64'hF0D326F1AA0C9B88, // [3,4]
    64'h2F0F7368EE6C0DA2, // [2,4]
    64'h75CA4C391523FE44, // [1,4]
    64'h0E88386CB3348EE5, // [0,4]

    // y = 3
    64'h2A38BA62D281D2C7, // [4,3]
    64'h0C342CE5BDE6111A, // [3,3]
    64'hBFE2EAB3A6DEC312, // [2,3]
    64'h8F1E89D983EE2D2F, // [1,3]
    64'h80F50BC239CF4F2E, // [0,3]

    // y = 2
    64'hE5E638FBA5A32142, // [4,2]
    64'h2573687FF364D517, // [3,2]
    64'hD58F03EF430F3959, // [2,2]
    64'h4F0314546A2DD285, // [1,2]
    64'h62E4A80832CEDBE9, // [0,2]

    // y = 1
    64'hA479475227751621, // [4,1]
    64'hECEACFE4E9B4B5DD, // [3,1]
    64'h9FBD85347E7C9972, // [2,1]
    64'hD0694D66316E9A68, // [1,1]
    64'hD8BA0AF556875736, // [0,1]

    // y = 0
    64'h7F3A5D86679BD604, // [4,0]
    64'hF67B9B9B9CEE7E30, // [3,0]
    64'h1EED4F770CF33CC5, // [2,0]
    64'h61525B169D1A2F3C, // [1,0]
    64'h843990DE19924D79  // [0,0]
};
        $display({100{"="}});
        $display("time = %0t | input = %h",$time,state_in);
        $display({100{"="}});
        start = 1'd1;                 
        @(negedge clk) 
        start = 1'd0;
        if (done !== 1'b0) $display("ERROR: done not cleared on new start");
        wait(done == 1);
        @(negedge clk);
        $display("time = %0t | Output = %h",$time, state_out);
        $display({100{"="}});
        $finish;
    end

endmodule
`endif 
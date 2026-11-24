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
            end else if(busy) begin
                state <= next_state;
                if(round == 5'd23) begin
                    busy <= 1'd0;
                    done <= 1'd1;
                end else begin
                    round <= round + 5'd1;
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
        rst_n = 1'd0; clk = 0;
        #10;
        rst_n = 1'd1;
        start = 1'd1;
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
        // repeat(24)begin
        // #10;
        // $display(" %0t | round = %0d |Output = %h",$time,q1.round, state_out);
        // end
        wait(done == 1);
        @(posedge clk);
        $display("time = %0t | Output = %h",$time, state_out);
         $display({100{"="}});
        $finish;
    end

endmodule
`endif 
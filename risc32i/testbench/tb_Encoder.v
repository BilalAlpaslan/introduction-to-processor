`include "Encoder.v"

`timescale 1ns / 100ps 

module tb_Encoders;
    reg [15:0] in = 0;
    reg [1:0] out;

    Encoder_4 encoder(in[3:0], out);

    initial begin
        in = 16'b0000000000000000; #20;
        $display("out = %d", out);
        in = 16'b0000000000000001; #20;
        $display("out = %d", out);
        in = 16'b0000000000000010; #20;
        $display("out = %d", out);
        in = 16'b0000000000000100; #20;
        $display("out = %d", out);
        in = 16'b0000000000001000; #20;
        $display("out = %d", out);
        in = 16'b0000000000010000; #20;
        $display("out = %d", out);
        in = 16'b0000000000100000; #20;
        $display("out = %d", out);
        in = 16'b0000000001000000; #20;
        $display("out = %d", out);
        in = 16'b0000000010000000; #20;
        $display("out = %d", out);
        in = 16'b0000000100000000; #20;
        $display("out = %d", out);
        in = 16'b0000001000000000; #20;
        $display("out = %d", out);
        in = 16'b0000010000000000; #20;
        $display("out = %d", out);
        in = 16'b0000100000000000; #20;
        $display("out = %d", out);
        in = 16'b0001000000000000; #20;
        $display("out = %d", out);
        in = 16'b0010000000000000; #20;
        $display("out = %d", out);
        in = 16'b0100000000000000; #20;
        $display("out = %d", out);
        in = 16'b1000000000000000; #20;
        $display("out = %d", out);
        in = 16'b1000000000000001; #20;
        $display("out = %d", out);
        in = 16'b0000000100000001; #20;
        $display("out = %d", out);
        in = 16'b0000000000000011; #20;
        $display("out = %d", out);
        in = 16'b0000000000000000; #20;
        $display("out = %d", out);
    end

    // to run:
    //    iverilog -g2005-sv -I ../src/ -o output/encoder.out tb_Encoder.v && vvp output/encoder.out

    // initial begin
    //     $dumpfile("vcd/encoders.vcd");
    //     $dumpvars(0, tb_Encoders);
    // end

endmodule

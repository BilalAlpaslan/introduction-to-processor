`include "ROM.v"
`timescale 1ns / 100ps 

module tb_ROM;
    reg [9:0] ADDRESS;
    reg [31:0] DATA_OUT;

    ROM rom(ADDRESS, DATA_OUT);

    initial begin
        ADDRESS = 0; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 1; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 2; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 3; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 4; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 5; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 6; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 7; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 8; #20;
        $display("DATA_OUT = %b", DATA_OUT);
        ADDRESS = 9; #20;
        $display("DATA_OUT = %b", DATA_OUT);
    end

    // to run:
    //   iverilog -g2005-sv -I ../src/ -o output/rom.out tb_ROM.v && vvp output/rom.out

    // initial begin
    //     $dumpfile("vcd/rom.vcd");
    //     $dumpvars(0, tb_ROM);
    // end
endmodule
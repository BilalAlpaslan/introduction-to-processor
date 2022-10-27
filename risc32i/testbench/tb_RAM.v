`include "RAM.v"
`timescale 1ns / 100ps 

module tb_RAM;
    reg [9:0] ADDRESS;
    reg [31:0] DATA_IN;
    reg WRITE_ENABLE;
    reg CLK;

    reg [31:0] DATA_OUT;

    RAM ram(ADDRESS, DATA_IN, WRITE_ENABLE, CLK, DATA_OUT);

    initial begin
        // Write #1
        ADDRESS = 1;
        DATA_IN = 24;
        WRITE_ENABLE = 1;
        CLK = 1; #20; CLK = 0; #20;

        // Write #2
        ADDRESS = 2;
        DATA_IN = 61;
        WRITE_ENABLE = 1;
        CLK = 1; #20; CLK = 0; #20;

        // Read #1
        ADDRESS = 1;
        DATA_IN = 0;
        WRITE_ENABLE = 0;
        CLK = 1; #20; CLK = 0; #20;
        $display("DATA_OUT = %d", DATA_OUT); //24

        // Read #2
        ADDRESS = 2;
        DATA_IN = 0;
        WRITE_ENABLE = 0;
        CLK = 1; #20; CLK = 0; #20;
        $display("DATA_OUT = %d", DATA_OUT); //61

        // write #2 again
        ADDRESS = 2;
        DATA_IN = 62;
        WRITE_ENABLE = 1;
        CLK = 1; #20; CLK = 0; #20;

        // Read #2 again
        ADDRESS = 2;
        DATA_IN = 0;
        WRITE_ENABLE = 0;
        CLK = 1; #20; CLK = 0; #20;
        $display("DATA_OUT = %d", DATA_OUT); //62
    end

    // to run:
    //    iverilog -g2005-sv -I ../src/ -o output/ram.out tb_RAM.v && vvp output/ram.out

    // initial begin
    //     $dumpfile("vcd/ram.vcd");
    //     $dumpvars(0, tb_RAM);
    // end
endmodule

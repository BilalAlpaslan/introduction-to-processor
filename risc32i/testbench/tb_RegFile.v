`include "RegFile.v"
`timescale 1ns / 100ps 

module tb_RegFile;
    reg [4:0]R1;
    reg [4:0]R2;
    reg [4:0]RD;
    reg [31:0]RD_DATA;
    reg reg_write_enable;

    wire [31:0]R1_data;
    wire [31:0]R2_data;

    RegFile regfile(R1, R2, RD, RD_DATA, reg_write_enable, R1_data, R2_data );

    initial begin
        R1 = 0;
        R2 = 0;
        RD = 0;
        RD_DATA = 0;
        reg_write_enable = 0;
        #20;
        $display("R1_data = %b", R1_data);
        $display("R2_data = %b", R2_data);

        R1 = 0;
        R2 = 0;
        RD = 1;
        RD_DATA = 5;
        reg_write_enable = 1;
        #20;
        $display("R1_data = %b", R1_data);
        $display("R2_data = %b", R2_data);

        R1 = 1;
        R2 = 0;
        RD = 2;
        RD_DATA = 10;
        reg_write_enable = 1;
        #20;
        $display("R1_data = %b", R1_data);
        $display("R2_data = %b", R2_data);

        R1 = 1;
        R2 = 2;
        RD = 0;
        RD_DATA = 0;
        reg_write_enable = 0;
        #20;
        $display("R1_data = %b", R1_data);
        $display("R2_data = %b", R2_data);
    end

    // to run:
    //     iverilog -g2005-sv -I ../src/ -o output/regfile.out tb_RegFile.v && vvp output/regfile.out

    // initial begin
    //     $dumpfile("vcd/regfile.vcd");
    //     $dumpvars(0, tb_RegFile);
    // end
endmodule
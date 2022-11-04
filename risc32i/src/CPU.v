

module CPU (
    input [31:0] RAM_READ_DATA,
    input [31:0] INSTRUCTION,
    input CLK,

    output [9:0] RAM_ADDR,         
    output reg [31:0] RAM_WRITE_DATA,
    output RAM_WRITE_ENABLE,
    output [9:0] INSTRUCTION_ADDR,  
    output reg [31:0] GPIO
);
    // -- OPCODE DEFINES:
    integer OP_R_TYPE           = 7'h33;
    integer OP_I_TYPE_LOAD      = 7'h03;
    integer OP_I_TYPE_OTHER     = 7'h13;
    integer OP_I_TYPE_JUMP      = 7'h6F;
    integer OP_S_TYPE           = 7'h23;
    integer OP_B_TYPE           = 7'h63;
    integer OP_U_TYPE_LOAD      = 7'h37;
    integer OP_U_TYPE_JUMP      = 7'h67;
    integer OP_U_TYPE_AUIPC     = 7'h17;
    // -- PIPELINE HAZARD INSTRUCTION TYPE DEFINES:
    integer TYPE_REGISTER       = 0;
    integer TYPE_LOAD           = 1;
    integer TYPE_STORE          = 2;
    integer TYPE_IMMEDIATE      = 3;
    integer TYPE_UPPERIMMEDIATE = 4;
    integer TYPE_BRANCH         = 5;
    // -- PIPELINE STAGES
    integer DECODE      = 0;
    integer EXECUTE     = 1;
    integer MEMORY      = 2;
    integer WRITEBACK   = 3;


    // == ==========================================================
    //                                  PIPELINING
    // == ==========================================================

    //-- Fetch Stage
    reg [9:0]  PC = 0;
    assign INSTRUCTION_ADDR = PC;

    always @(posedge CLK) begin
        PC <= PC + 1;
    end

    //-- Decode Stage
    reg [9:0]  PC_DECODE_2 = 0;
    reg[31:0]  INSTRUCTION_DECODE_2 = 0;

    always @(posedge CLK) begin
        PC_DECODE_2 <= PC;
        INSTRUCTION_DECODE_2 <= INSTRUCTION;
    end

    //-- Execute Stage
    reg [9:0]  PC_EXECUTE_3 = 0;
    reg[31:0]  INSTRUCTION_EXECUTE_3 = 0;

    always @(posedge CLK) begin
        PC_EXECUTE_3 <= PC_DECODE_2;
        INSTRUCTION_EXECUTE_3 <= INSTRUCTION_DECODE_2;
    end

    //-- Memory Stage
    reg [9:0]  PC_MEMORY_4 = 0;
    reg[31:0]  INSTRUCTION_MEMORY_4 = 0;
    reg [31:0] ALU_OUT_MEMORY_4 = 0;

    always @(posedge CLK) begin
        PC_MEMORY_4 <= PC_EXECUTE_3;
        INSTRUCTION_MEMORY_4 <= INSTRUCTION_EXECUTE_3;
        ALU_OUT_MEMORY_4 <= ALU_OUT;
    end

    //-- Writeback Stage
    reg[31:0]  INSTRUCTION_WRITEBACK_5 = 0;
    reg [31:0] REG_WRITE_DATA_WRITEBACK_5 = 0;
    reg [31:0] RAM_READ_DATA_WRITEBACK_5 = 0;

    always @(posedge CLK) begin
        INSTRUCTION_WRITEBACK_5 <= INSTRUCTION_MEMORY_4;
        RAM_READ_DATA_WRITEBACK_5  <= RAM_READ_DATA;
        REG_WRITE_DATA_WRITEBACK_5 <= PC_MEMORY_4 + 4;
    end
endmodule


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
endmodule
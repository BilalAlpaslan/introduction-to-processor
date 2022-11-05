

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

    // WIRE DEFINITIONS:
    wire [6:0] OPCODE   = INSTRUCTION[6:0];
    wire [4:0] RD       = INSTRUCTION[11:7];
    wire [2:0] FUNCT3   = INSTRUCTION[14:12];
    wire [4:0] R1       = INSTRUCTION[19:15];
    wire [4:0] R2       = INSTRUCTION[24:20];
    wire [6:0] FUNCT7   = INSTRUCTION[31:25];

    wire R_TYPE         = OPCODE == OP_R_TYPE;
    wire I_TYPE_LOAD    = OPCODE == OP_I_TYPE_LOAD;
    wire I_TYPE_OTHER   = OPCODE == OP_I_TYPE_OTHER;
    wire I_TYPE_JUMP    = OPCODE == OP_I_TYPE_JUMP;
    wire I_TYPE         = I_TYPE_JUMP || I_TYPE_LOAD || I_TYPE_OTHER;
    wire S_TYPE         = OPCODE == OP_S_TYPE;
    wire B_TYPE         = OPCODE == OP_B_TYPE;
    wire U_TYPE_LOAD    = OPCODE == OP_U_TYPE_LOAD;
    wire U_TYPE_JUMP    = OPCODE == OP_U_TYPE_JUMP;
    wire U_TYPE_AUIPC   = OPCODE == OP_U_TYPE_AUIPC;
    wire U_TYPE         = U_TYPE_JUMP || U_TYPE_LOAD || U_TYPE_AUIPC;

    // -- Register-Register Types (R-Type)    
    // ---- RV32I:
    wire R_add      = R_TYPE && FUNCT3 == 3'h0 && FUNCT7 == 7'h00;
    wire R_sub      = R_TYPE && FUNCT3 == 3'h0 && FUNCT7 == 7'h20;
    wire R_sll      = R_TYPE && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire R_slt      = R_TYPE && FUNCT3 == 3'h2 && FUNCT7 == 7'h00;
    wire R_sltu     = R_TYPE && FUNCT3 == 3'h3 && FUNCT7 == 7'h00;
    wire R_xor      = R_TYPE && FUNCT3 == 3'h4 && FUNCT7 == 7'h00;
    wire R_srl      = R_TYPE && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire R_sra      = R_TYPE && FUNCT3 == 3'h5 && FUNCT7 == 7'h20;
    wire R_or       = R_TYPE && FUNCT3 == 3'h6 && FUNCT7 == 7'h00;
    wire R_and      = R_TYPE && FUNCT3 == 3'h7 && FUNCT7 == 7'h00;
    

    // -- Immediate Types (I-Type)
    // ---- RV32I:
    wire I_addi     = I_TYPE_OTHER && FUNCT3 == 3'h0;
    wire I_slli     = I_TYPE_OTHER && FUNCT3 == 3'h1 && FUNCT7 == 7'h00;
    wire I_slti     = I_TYPE_OTHER && FUNCT3 == 3'h2;
    wire I_sltiu    = I_TYPE_OTHER && FUNCT3 == 3'h3;
    wire I_xori     = I_TYPE_OTHER && FUNCT3 == 3'h4;
    wire I_srli     = I_TYPE_OTHER && FUNCT3 == 3'h5 && FUNCT7 == 7'h00;
    wire I_srai     = I_TYPE_OTHER && FUNCT3 == 3'h5 && FUNCT7 == 7'h10;
    wire I_ori      = I_TYPE_OTHER && FUNCT3 == 3'h6;
    wire I_andi     = I_TYPE_OTHER && FUNCT3 == 3'h7;
    // ---- Load
    wire I_lb       = INSTRUCTION[6:0] == OP_I_TYPE_LOAD && INSTRUCTION[14:12] == 3'h0;
    wire I_lh       = INSTRUCTION[6:0] == OP_I_TYPE_LOAD && INSTRUCTION[14:12] == 3'h1;
    wire I_lw       = INSTRUCTION[6:0] == OP_I_TYPE_LOAD && INSTRUCTION[14:12] == 3'h2;
    // ---- Jump
    wire I_jalr     = I_TYPE_JUMP;


    // -- Upper Immediate Types (U-Type)
    wire U_lui      = U_TYPE_LOAD;
    wire U_auipc    = U_TYPE_AUIPC;
    wire U_jal      = U_TYPE_JUMP;


    // -- Store Types (S-Type)
    wire S_sb       = INSTRUCTION[6:0] == OP_S_TYPE && INSTRUCTION[14:12] == 3'h0;
    wire S_sh       = INSTRUCTION[6:0] == OP_S_TYPE && INSTRUCTION[14:12] == 3'h1;
    wire S_sw       = INSTRUCTION[6:0] == OP_S_TYPE && INSTRUCTION[14:12] == 3'h2;


    // -- Branch Types (B-Type)
    wire B_beq      = B_TYPE && FUNCT3 == 0;
    wire B_bne      = B_TYPE && FUNCT3 == 1;
    wire B_blt      = B_TYPE && FUNCT3 == 4;
    wire B_bge      = B_TYPE && FUNCT3 == 5;
    wire B_bltu     = B_TYPE && FUNCT3 == 6;
    wire B_bgeu     = B_TYPE && FUNCT3 == 7;

    // -- PC Get Data From ALU Switch
    wire signed [31:0] R1_DATA;
    wire signed [31:0] R2_DATA;
    wire [31:0] R1_DATA_UNSIGNED = R1_DATA;
    wire [31:0] R2_DATA_UNSIGNED = R2_DATA;

    wire PC_ALU_SEL =   (B_beq && R1_DATA == R2_DATA)
                        || (B_bne && R1_DATA != R2_DATA)
                        || (B_blt && R1_DATA <  R2_DATA)
                        || (B_bge && R1_DATA >= R2_DATA)
                        || (B_bltu && R1_DATA_UNSIGNED <  R2_DATA_UNSIGNED)
                        || (B_bgeu && R1_DATA_UNSIGNED >= R2_DATA_UNSIGNED)
                        || I_jalr
                        || U_jal
                        ;
    
    // -- RAM Read & Write Enable Pins
    assign RAM_WRITE_ENABLE     = INSTRUCTION[6:0] == OP_S_TYPE;
    assign RAM_ADDR             = ALU_OUT[9:0];


    // -- PIPELINING HAZARDS
    // ---- DATA HAZARD CONTROL REGISTERS
    reg [4:0] R1_PIPELINE[3:0];        // R1 Register of the current stage.
    reg [4:0] R2_PIPELINE[3:0];        // R2 Register of the current stage.
    reg [4:0] RD_PIPELINE[3:0];        // RD Register of the current stage.
    reg [2:0] TYPE_PIPELINE[3:0];      // Instruction Types of the current stage. [R-Type=0, Load=1, Store=2, Immediate or UpperImmediate=3, Branch=4]


    // COMPONENT DEFINITIONS (IMMEDIATE EXTRACTOR, ALU, REGFILE):
    // -- Immediate Extractor
    wire [31:0] IMMEDIATE_VALUE;
    wire [2:0] IMMEDIATE_SELECTION;
    wire [7:0] immediateSelectionInputs;

    assign immediateSelectionInputs[0] = 0;
    assign immediateSelectionInputs[1] = I_TYPE;
    assign immediateSelectionInputs[2] = U_TYPE_LOAD || U_TYPE_AUIPC;
    assign immediateSelectionInputs[3] = S_TYPE;
    assign immediateSelectionInputs[4] = B_TYPE;
    assign immediateSelectionInputs[5] = U_TYPE_JUMP;
    assign immediateSelectionInputs[6] = 0;
    assign immediateSelectionInputs[7] = 0;
    Encoder_8 immediateSelectionEncoder(immediateSelectionInputs, IMMEDIATE_SELECTION);
    
    ImmediateExtractor immediateExtractor(INSTRUCTION, IMMEDIATE_SELECTION, IMMEDIATE_VALUE);


    // -- ALU Operation Selection
    wire [15:0] aluOpEncoderInputs;
    wire [3:0] ALU_OP;
    
    assign aluOpEncoderInputs[0] = R_add || I_addi;
    assign aluOpEncoderInputs[1] = R_sub;
    assign aluOpEncoderInputs[2] = R_and || I_andi;
    assign aluOpEncoderInputs[3] = R_or || I_ori;
    assign aluOpEncoderInputs[4] = R_xor || I_xori;
    assign aluOpEncoderInputs[5] = R_sll || I_slli;
    assign aluOpEncoderInputs[6] = R_srl || I_srli;
    assign aluOpEncoderInputs[7] = R_sra || I_srai;
    assign aluOpEncoderInputs[8] = R_slt || I_slti;
    assign aluOpEncoderInputs[9] = R_sltu || I_sltiu;
    assign aluOpEncoderInputs[10] = 0;
    assign aluOpEncoderInputs[11] = 0;
    assign aluOpEncoderInputs[12] = 0;
    assign aluOpEncoderInputs[13] = 0;
    assign aluOpEncoderInputs[14] = 0;
    assign aluOpEncoderInputs[15] = 0;
    Encoder_16 aluOpEncoder(aluOpEncoderInputs, ALU_OP);

    // -- ALU Input Selection Encoders
    wire [3:0] aluX1SelectionInputs;
    wire [3:0] aluX2SelectionInputs;
    wire [1:0] ALU_X1_SEL;
    wire [1:0] ALU_X2_SEL;
    
    assign aluX1SelectionInputs[0] = 1;
    assign aluX1SelectionInputs[1] = B_TYPE || U_TYPE_JUMP || U_TYPE_AUIPC || I_TYPE_JUMP;
    assign aluX1SelectionInputs[2] = U_TYPE_LOAD;
    assign aluX1SelectionInputs[3] = 0;

    assign aluX2SelectionInputs[0] = 1;
    assign aluX2SelectionInputs[1] = S_TYPE || I_TYPE || B_TYPE || U_TYPE;    
    assign aluX2SelectionInputs[2] = 0;
    assign aluX2SelectionInputs[3] = 0;
    Encoder_4 aluX1SelectionEncoder(aluX1SelectionInputs, ALU_X1_SEL);
    Encoder_4 aluX2SelectionEncoder(aluX2SelectionInputs, ALU_X2_SEL);

    // -- ALU
    reg [31:0] ALU_X1;
    reg [31:0] ALU_X2;
    wire [31:0] ALU_OUT;
    wire isALUEqual;
    ALU alu(ALU_X1, ALU_X2, ALU_OP, ALU_OUT, isALUEqual);

    always @(*) begin
        case(ALU_X1_SEL)
            0: ALU_X1 <= R1_DATA;
            1: ALU_X1 <= PC;
            default: ALU_X1 <= 0;
        endcase

        case(ALU_X2_SEL)
            0: ALU_X2 <= R2_DATA;
            1: ALU_X2 <= IMMEDIATE_VALUE;
            default: ALU_X2 <= 0;
        endcase
    end


    // -- RegFile
    // Decoding OPCODE for 5th stage of pipeline.
    wire [6:0] OPCODE_WRITEBACK_5 = INSTRUCTION_WRITEBACK_5[6:0];
    wire WB_R_TYPE         = OPCODE_WRITEBACK_5 == OP_R_TYPE;
    wire WB_I_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_I_TYPE_LOAD;
    wire WB_I_TYPE_OTHER   = OPCODE_WRITEBACK_5 == OP_I_TYPE_OTHER;
    wire WB_I_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_I_TYPE_JUMP;
    wire WB_I_TYPE         = WB_I_TYPE_JUMP || WB_I_TYPE_LOAD || WB_I_TYPE_OTHER;
    wire WB_U_TYPE_LOAD    = OPCODE_WRITEBACK_5 == OP_U_TYPE_LOAD;
    wire WB_U_TYPE_JUMP    = OPCODE_WRITEBACK_5 == OP_U_TYPE_JUMP;
    wire WB_U_TYPE_AUIPC   = OPCODE_WRITEBACK_5 == OP_U_TYPE_AUIPC;
    wire WB_U_TYPE         = WB_U_TYPE_JUMP || WB_U_TYPE_LOAD || WB_U_TYPE_AUIPC;

    wire REG_WRITE_ENABLE = WB_R_TYPE || WB_I_TYPE || WB_U_TYPE;

    // -- Register Write Back Selection Encoder
    wire [3:0] regWritebackSelectionInputs;
    wire [1:0] REG_WRITEBACK_SELECTION;

    assign regWritebackSelectionInputs[0] = 0;
    assign regWritebackSelectionInputs[1] = WB_R_TYPE || WB_U_TYPE_LOAD || WB_I_TYPE_OTHER;
    assign regWritebackSelectionInputs[2] = WB_U_TYPE_JUMP || WB_I_TYPE_JUMP;
    assign regWritebackSelectionInputs[3] = WB_I_TYPE_LOAD;
    
    Encoder_4 writeBackSelectionEncoder(regWritebackSelectionInputs, REG_WRITEBACK_SELECTION);    


    wire signed[31:0] R1_DATA;
    wire signed [31:0] R2_DATA;

    wire [31:0] REG_WRITE_DATA = REG_WRITEBACK_SELECTION == 3 ? RAM_READ_DATA_WRITEBACK_5 : REG_WRITE_DATA_WRITEBACK_5;

    RegFile regFile(R1, R2, RD, REG_WRITE_DATA, REG_WRITE_ENABLE, R1_DATA, R2_DATA);


    // == ==========================================================
    //                                  PIPELINING
    // == ==========================================================

    //-- Fetch Stage
    // reg [9:0]  PC = 0;
    // assign INSTRUCTION_ADDR = PC; // assign INSTRUCTION_ADDR = PC >> 2; ???

    // always @(posedge CLK) begin
    //     PC <= PC + 1;
    // end

    // //-- Decode Stage
    // reg [9:0]  PC_DECODE_2 = 0;
    // reg[31:0]  INSTRUCTION_DECODE_2 = 0;

    // always @(posedge CLK) begin
    //     PC_DECODE_2 <= PC;
    //     INSTRUCTION_DECODE_2 <= INSTRUCTION;
    // end

    // //-- Execute Stage
    // reg [9:0]  PC_EXECUTE_3 = 0;
    // reg[31:0]  INSTRUCTION_EXECUTE_3 = 0;

    // always @(posedge CLK) begin
    //     PC_EXECUTE_3 <= PC_DECODE_2;
    //     INSTRUCTION_EXECUTE_3 <= INSTRUCTION_DECODE_2;
    // end

    // //-- Memory Stage
    // reg [9:0]  PC_MEMORY_4 = 0;
    // reg[31:0]  INSTRUCTION_MEMORY_4 = 0;
    // reg [31:0] ALU_OUT_MEMORY_4 = 0;

    // always @(posedge CLK) begin
    //     PC_MEMORY_4 <= PC_EXECUTE_3;
    //     INSTRUCTION_MEMORY_4 <= INSTRUCTION_EXECUTE_3;
    //     ALU_OUT_MEMORY_4 <= ALU_OUT;
    // end

    // //-- Writeback Stage
    // reg[31:0]  INSTRUCTION_WRITEBACK_5 = 0;
    // reg [31:0] REG_WRITE_DATA_WRITEBACK_5 = 0;
    // reg [31:0] RAM_READ_DATA_WRITEBACK_5 = 0;

    // always @(posedge CLK) begin
    //     INSTRUCTION_WRITEBACK_5 <= INSTRUCTION_MEMORY_4;
    //     RAM_READ_DATA_WRITEBACK_5  <= RAM_READ_DATA;
    //     REG_WRITE_DATA_WRITEBACK_5 <= PC_MEMORY_4 + 4;
    // end
endmodule
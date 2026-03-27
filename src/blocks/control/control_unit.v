`timescale 1ns/1ps

module control_unit (
    input  wire [31:0] instr,

    output reg  RegWEn,
    output reg  MemRW,
    output reg [1:0] WBSel,
    output reg [2:0] ImmSel,
    output reg  ASel,
    output reg BSel,
    output reg [3:0] ALUSel,
    output reg BrUn,
    output reg Branch,
    output reg Jump,
    output reg Jalr
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // opcde for the instruction types
    localparam [6:0] OP_RTYPE = 7'b0110011;
    localparam [6:0] OP_ITYPE = 7'b0010011;
    localparam [6:0] OP_LOAD = 7'b0000011;
    localparam [6:0] OP_STORE = 7'b0100011;
    localparam [6:0] OP_BRANCH = 7'b1100011;
    localparam [6:0] OP_JAL = 7'b1101111;
    localparam [6:0] OP_JALR = 7'b1100111;
    localparam [6:0] OP_LUI = 7'b0110111;
    localparam [6:0] OP_AUIPC = 7'b0010111;

    // immediate controls 
    localparam [2:0] IMM_I = 3'd0;
    localparam [2:0] IMM_S = 3'd1;
    localparam [2:0] IMM_B = 3'd2;
    localparam [2:0] IMM_U = 3'd3;
    localparam [2:0] IMM_J = 3'd4;

    // alu bits control
    localparam [3:0] ALU_ADD    = 4'd0;
    localparam [3:0] ALU_SUB    = 4'd1;
    localparam [3:0] ALU_AND    = 4'd2;
    localparam [3:0] ALU_OR     = 4'd3;
    localparam [3:0] ALU_XOR    = 4'd4;
    localparam [3:0] ALU_SLL    = 4'd5;
    localparam [3:0] ALU_SRL    = 4'd6;
    localparam [3:0] ALU_SRA    = 4'd7;
    localparam [3:0] ALU_SLT    = 4'd8;
    localparam [3:0] ALU_SLTU   = 4'd9;
    localparam [3:0] ALU_PASS_B = 4'd10;

    // wb bits control
    localparam [1:0] WB_MEM = 2'd0;
    localparam [1:0] WB_ALU = 2'd1;
    localparam [1:0] WB_PC4 = 2'd2;

    always @(*) begin
        //default 
        RegWEn = 1'b0;
        MemRW  = 1'b0;
        WBSel  = WB_ALU;
        ImmSel = IMM_I;
        ASel   = 1'b0;
        BSel   = 1'b0;
        ALUSel = ALU_ADD;
        BrUn   = 1'b0;
        Branch = 1'b0;
        Jump   = 1'b0;
        Jalr   = 1'b0;

        case (opcode)
            OP_RTYPE: begin
                RegWEn = 1'b1;
                WBSel  = WB_ALU;
                ASel   = 1'b0;
                BSel   = 1'b0;
                case (funct3)
                    3'b000: ALUSel = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b111: ALUSel = ALU_AND;
                    3'b110: ALUSel = ALU_OR;
                    3'b100: ALUSel = ALU_XOR;
                    3'b001: ALUSel = ALU_SLL;
                    3'b101: ALUSel = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b010: ALUSel = ALU_SLT;
                    3'b011: ALUSel = ALU_SLTU;
                    default: ALUSel = ALU_ADD;
                endcase
            end

            OP_ITYPE: begin
                RegWEn = 1'b1;
                WBSel  = WB_ALU;
                ImmSel = IMM_I;
                ASel   = 1'b0;
                BSel   = 1'b1;
                case (funct3)
                    3'b000: ALUSel = ALU_ADD;
                    3'b111: ALUSel = ALU_AND;
                    3'b110: ALUSel = ALU_OR;
                    3'b100: ALUSel = ALU_XOR;
                    3'b010: ALUSel = ALU_SLT;
                    3'b011: ALUSel = ALU_SLTU;
                    3'b001: ALUSel = ALU_SLL;
                    3'b101: ALUSel = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    default: ALUSel = ALU_ADD;
                endcase
            end

            OP_LOAD: begin
                RegWEn = 1'b1;
                MemRW  = 1'b0;
                WBSel  = WB_MEM;
                ImmSel = IMM_I;
                ASel   = 1'b0;
                BSel   = 1'b1;
                ALUSel = ALU_ADD;
            end

            OP_STORE: begin
                RegWEn = 1'b0;
                MemRW  = 1'b1;
                ImmSel = IMM_S;
                ASel   = 1'b0;
                BSel   = 1'b1;
                ALUSel = ALU_ADD;
            end

            OP_BRANCH: begin
                Branch = 1'b1;
                ImmSel = IMM_B;
                ASel   = 1'b1;  // PC
                BSel   = 1'b1;  // imm
                ALUSel = ALU_ADD;
                BrUn   = (funct3 == 3'b110) || (funct3 == 3'b111);
            end

            OP_JAL: begin
                RegWEn = 1'b1;
                Jump   = 1'b1;
                WBSel  = WB_PC4;
                ImmSel = IMM_J;
                ASel   = 1'b1;
                BSel   = 1'b1;
                ALUSel = ALU_ADD;
            end

            OP_JALR: begin
                RegWEn = 1'b1;
                Jump   = 1'b1;
                Jalr   = 1'b1;
                WBSel  = WB_PC4;
                ImmSel = IMM_I;
                ASel   = 1'b0;
                BSel   = 1'b1;
                ALUSel = ALU_ADD;
            end

            OP_LUI: begin
                RegWEn = 1'b1;
                WBSel  = WB_ALU;
                ImmSel = IMM_U;
                ASel   = 1'b0;
                BSel   = 1'b1;
                ALUSel = ALU_PASS_B;
            end

            OP_AUIPC: begin
                RegWEn = 1'b1;
                WBSel  = WB_ALU;
                ImmSel = IMM_U;
                ASel   = 1'b1;
                BSel   = 1'b1;
                ALUSel = ALU_ADD;
            end

            default: begin
            end
        endcase
    end

endmodule

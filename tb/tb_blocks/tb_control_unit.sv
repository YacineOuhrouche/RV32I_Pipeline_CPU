`timescale 1ns/1ps

module tb_control_unit;

    reg [31:0] instr;

    wire RegWEn;
    wire MemRW;
    wire [1:0] WBSel;
    wire [2:0] ImmSel;
    wire ASel;
    wire BSel;
    wire [3:0] ALUSel;
    wire BrUn;
    wire Branch;
    wire Jump;
    wire Jalr;

    integer errors;

    localparam [2:0] IMM_I = 3'd0;
    localparam [2:0] IMM_S = 3'd1;
    localparam [2:0] IMM_B = 3'd2;
    localparam [2:0] IMM_U = 3'd3;
    localparam [2:0] IMM_J = 3'd4;

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

    localparam [1:0] WB_MEM = 2'd0;
    localparam [1:0] WB_ALU = 2'd1;
    localparam [1:0] WB_PC4 = 2'd2;

    control_unit dut (
        .instr(instr),
        .RegWEn(RegWEn),
        .MemRW(MemRW),
        .WBSel(WBSel),
        .ImmSel(ImmSel),
        .ASel(ASel),
        .BSel(BSel),
        .ALUSel(ALUSel),
        .BrUn(BrUn),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr)
    );

    control_unit_sva assertions_inst (
        .instr(instr),
        .RegWEn(RegWEn),
        .MemRW(MemRW),
        .WBSel(WBSel),
        .ImmSel(ImmSel),
        .ASel(ASel),
        .BSel(BSel),
        .ALUSel(ALUSel),
        .BrUn(BrUn),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr)
    );

    task apply_and_check;
        input [31:0] t_instr;
        input t_RegWEn;
        input t_MemRW;
        input [1:0] t_WBSel;
        input [2:0] t_ImmSel;
        input t_ASel;
        input t_BSel;
        input [3:0] t_ALUSel;
        input t_BrUn;
        input t_Branch;
        input t_Jump;
        input t_Jalr;
        input [255:0] msg;
        begin
instr = t_instr;
            #1;
            if (RegWEn !== t_RegWEn || MemRW !== t_MemRW || WBSel !== t_WBSel ||
                ImmSel !== t_ImmSel || ASel !== t_ASel || BSel !== t_BSel ||
                ALUSel !== t_ALUSel || BrUn !== t_BrUn || Branch !== t_Branch ||
                Jump !== t_Jump || Jalr !== t_Jalr) begin
                $display("ERROR %0s time=%0t", msg, $time);
                $display("Expected RegWEn=%b MemRW=%b WBSel=%b ImmSel=%b ASel=%b BSel=%b ALUSel=%h BrUn=%b Branch=%b Jump=%b Jalr=%b",
                         t_RegWEn, t_MemRW, t_WBSel, t_ImmSel, t_ASel, t_BSel, t_ALUSel, t_BrUn, t_Branch, t_Jump, t_Jalr);
                $display("Got      RegWEn=%b MemRW=%b WBSel=%b ImmSel=%b ASel=%b BSel=%b ALUSel=%h BrUn=%b Branch=%b Jump=%b Jalr=%b",
                         RegWEn, MemRW, WBSel, ImmSel, ASel, BSel, ALUSel, BrUn, Branch, Jump, Jalr);
                errors = errors + 1;
            end
            else begin
                $display("PASS %0s", msg);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/control_unit/control_unit.vcd");
        $dumpvars(0, tb_control_unit);

        errors = 0;

        apply_and_check(
            32'b0000000_00011_00010_000_00001_0110011,
            1'b1, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b0, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "R ADD"
        );

        apply_and_check(
            32'b0100000_00011_00010_000_00001_0110011,
            1'b1, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b0, ALU_SUB, 1'b0, 1'b0, 1'b0, 1'b0,
            "R SUB"
        );

        apply_and_check(
            32'b0000000_00011_00010_111_00001_0110011,
            1'b1, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b0, ALU_AND, 1'b0, 1'b0, 1'b0, 1'b0,
            "R AND"
        );

        apply_and_check(
            32'b000000000001_00010_000_00001_0010011,
            1'b1, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "ADDI"
        );

        apply_and_check(
            32'b0100000_00011_00010_101_00001_0010011,
            1'b1, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b1, ALU_SRA, 1'b0, 1'b0, 1'b0, 1'b0,
            "SRAI"
        );

        apply_and_check(
            32'b000000000100_00010_010_00001_0000011,
            1'b1, 1'b0, WB_MEM, IMM_I, 1'b0, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "LW"
        );

        apply_and_check(
            32'b0000000_00011_00010_010_00001_0100011,
            1'b0, 1'b1, WB_ALU, IMM_S, 1'b0, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "SW"
        );

        apply_and_check(
            32'b0000000_00011_00010_000_00001_1100011,
            1'b0, 1'b0, WB_ALU, IMM_B, 1'b1, 1'b1, ALU_ADD, 1'b0, 1'b1, 1'b0, 1'b0,
            "BEQ"
        );

        apply_and_check(
            32'b0000000_00011_00010_110_00001_1100011,
            1'b0, 1'b0, WB_ALU, IMM_B, 1'b1, 1'b1, ALU_ADD, 1'b1, 1'b1, 1'b0, 1'b0,
            "BLTU"
        );

        apply_and_check(
            32'b00000000000100000000_00001_1101111,
            1'b1, 1'b0, WB_PC4, IMM_J, 1'b1, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b1, 1'b0,
            "JAL"
        );

        apply_and_check(
            32'b000000000100_00010_000_00001_1100111,
            1'b1, 1'b0, WB_PC4, IMM_I, 1'b0, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b1, 1'b1,
            "JALR"
        );

        apply_and_check(
            32'b00000000000000000001_00001_0110111,
            1'b1, 1'b0, WB_ALU, IMM_U, 1'b0, 1'b1, ALU_PASS_B, 1'b0, 1'b0, 1'b0, 1'b0,
            "LUI"
        );

        apply_and_check(
            32'b00000000000000000001_00001_0010111,
            1'b1, 1'b0, WB_ALU, IMM_U, 1'b1, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "AUIPC"
        );

        apply_and_check(
            32'hFFFFFFFF,
            1'b0, 1'b0, WB_ALU, IMM_I, 1'b0, 1'b0, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0,
            "DEFAULT"
        );

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("Tests FAILED with %0d errors", errors);

        $finish;
    end

endmodule

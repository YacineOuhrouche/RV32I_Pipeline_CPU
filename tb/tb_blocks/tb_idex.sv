`timescale 1ns/1ps

module tb_idex;

 
    reg clk;
    reg  rst;
    reg  flush;

    reg [31:0] pc_in;
    reg  [31:0] pc4_in;
    reg [31:0] rs1_val_in;
    reg  [31:0] rs2_val_in;
    reg  [31:0] imm_in;

    reg [4:0] rs1_in;
    reg  [4:0] rs2_in;
    reg [4:0] rd_in;
    reg  [2:0] funct3_in;

    reg RegWEn_in;
    reg  MemRW_in;
    reg [1:0]  WBSel_in;
    reg  ASel_in;
    reg  BSel_in;
    reg  [3:0]  ALUSel_in;
    reg  BrUn_in;
    reg  Branch_in;
    reg  Jump_in;
    reg  Jalr_in;


    wire [31:0] pc_out;
    wire [31:0] pc4_out;
    wire [31:0] rs1_val_out;
    wire [31:0] rs2_val_out;
    wire [31:0] imm_out;

    wire [4:0] rs1_out;
    wire [4:0] rs2_out;
    wire [4:0] rd_out;
    wire [2:0] funct3_out;

    wire RegWEn_out;
    wire MemRW_out;
    wire [1:0] WBSel_out;
    wire  ASel_out;
    wire BSel_out;
    wire [3:0] ALUSel_out;
    wire BrUn_out;
    wire  Branch_out;
    wire Jump_out;
    wire  Jalr_out;

    // DUT
    id_ex_reg dut (
        .clk(clk),
        .rst(rst),
        .flush(flush),

        .pc_in(pc_in),
        .pc4_in(pc4_in),
        .rs1_val_in(rs1_val_in),
        .rs2_val_in(rs2_val_in),
        .imm_in(imm_in),

        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),
        .funct3_in(funct3_in),

        .RegWEn_in(RegWEn_in),
        .MemRW_in(MemRW_in),
        .WBSel_in(WBSel_in),
        .ASel_in(ASel_in),
        .BSel_in(BSel_in),
        .ALUSel_in(ALUSel_in),
        .BrUn_in(BrUn_in),
        .Branch_in(Branch_in),
        .Jump_in(Jump_in),
        .Jalr_in(Jalr_in),

        .pc_out(pc_out),
        .pc4_out(pc4_out),
        .rs1_val_out(rs1_val_out),
        .rs2_val_out(rs2_val_out),
        .imm_out(imm_out),

        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
        .funct3_out(funct3_out),

        .RegWEn_out(RegWEn_out),
        .MemRW_out(MemRW_out),
        .WBSel_out(WBSel_out),
        .ASel_out(ASel_out),
        .BSel_out(BSel_out),
        .ALUSel_out(ALUSel_out),
        .BrUn_out(BrUn_out),
        .Branch_out(Branch_out),
        .Jump_out(Jump_out),
        .Jalr_out(Jalr_out)
    );

    // Checker
    id_ex_sva assertions_inst (
        .clk(clk),
        .rst(rst),
        .flush(flush),

        .pc_in(pc_in),
        .pc4_in(pc4_in),
        .rs1_val_in(rs1_val_in),
        .rs2_val_in(rs2_val_in),
        .imm_in(imm_in),

        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),
        .funct3_in(funct3_in),

        .RegWEn_in(RegWEn_in),
        .MemRW_in(MemRW_in),
        .WBSel_in(WBSel_in),
        .ASel_in(ASel_in),
        .BSel_in(BSel_in),
        .ALUSel_in(ALUSel_in),
        .BrUn_in(BrUn_in),
        .Branch_in(Branch_in),
        .Jump_in(Jump_in),
        .Jalr_in(Jalr_in),

        .pc_out(pc_out),
        .pc4_out(pc4_out),
        .rs1_val_out(rs1_val_out),
        .rs2_val_out(rs2_val_out),
        .imm_out(imm_out),

        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),
        .funct3_out(funct3_out),

        .RegWEn_out(RegWEn_out),
        .MemRW_out(MemRW_out),
        .WBSel_out(WBSel_out),
        .ASel_out(ASel_out),
        .BSel_out(BSel_out),
        .ALUSel_out(ALUSel_out),
        .BrUn_out(BrUn_out),
        .Branch_out(Branch_out),
        .Jump_out(Jump_out),
        .Jalr_out(Jalr_out)
    );

    // clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_all;
        input [31:0] exp_pc;
        input [31:0] exp_pc4;
        input [31:0] exp_rs1_val;
        input [31:0] exp_rs2_val;
        input [31:0] exp_imm;
        input [4:0] exp_rs1;
        input [4:0] exp_rs2;
        input [4:0] exp_rd;
        input [2:0] exp_funct3;
        input exp_RegWEn;
        input   exp_MemRW;
        input [1:0]  exp_WBSel;
        input exp_ASel;
        input   exp_BSel;
        input [3:0]  exp_ALUSel;
        input exp_BrUn;
        input  exp_Branch;
        input exp_Jump;
        input   exp_Jalr;
        input [255:0] msg;
        begin
            if (pc_out      !== exp_pc      ||
                pc4_out     !== exp_pc4     ||
                rs1_val_out !== exp_rs1_val ||
                rs2_val_out !== exp_rs2_val ||
                imm_out     !== exp_imm     ||
                rs1_out     !== exp_rs1     ||
                rs2_out     !== exp_rs2     ||
                rd_out      !== exp_rd      ||
                funct3_out  !== exp_funct3  ||
                RegWEn_out  !== exp_RegWEn  ||
                MemRW_out   !== exp_MemRW   ||
                WBSel_out   !== exp_WBSel   ||
                ASel_out    !== exp_ASel    ||
                BSel_out    !== exp_BSel    ||
                ALUSel_out  !== exp_ALUSel  ||
                BrUn_out    !== exp_BrUn    ||
                Branch_out  !== exp_Branch  ||
                Jump_out    !== exp_Jump    ||
                Jalr_out    !== exp_Jalr) begin

                $display("FAIL | %0s", msg);
                $display("pc_out=%h exp=%h", pc_out, exp_pc);
                $display("pc4_out=%h exp=%h", pc4_out, exp_pc4);
                $display("rs1_val_out=%h exp=%h", rs1_val_out, exp_rs1_val);
                $display("rs2_val_out=%h exp=%h", rs2_val_out, exp_rs2_val);
                $display("imm_out=%h exp=%h", imm_out, exp_imm);
                $display("rs1_out=%h exp=%h", rs1_out, exp_rs1);
                $display("rs2_out=%h exp=%h", rs2_out, exp_rs2);
                $display("rd_out=%h exp=%h", rd_out, exp_rd);
                $display("funct3_out=%h exp=%h", funct3_out, exp_funct3);
                $display("RegWEn_out=%b exp=%b", RegWEn_out, exp_RegWEn);
                $display("MemRW_out=%b exp=%b", MemRW_out, exp_MemRW);
                $display("WBSel_out=%b exp=%b", WBSel_out, exp_WBSel);
                $display("ASel_out=%b exp=%b", ASel_out, exp_ASel);
                $display("BSel_out=%b exp=%b", BSel_out, exp_BSel);
                $display("ALUSel_out=%h exp=%h", ALUSel_out, exp_ALUSel);
                $display("BrUn_out=%b exp=%b", BrUn_out, exp_BrUn);
                $display("Branch_out=%b exp=%b", Branch_out, exp_Branch);
                $display("Jump_out=%b exp=%b", Jump_out, exp_Jump);
                $display("Jalr_out=%b exp=%b", Jalr_out, exp_Jalr);
                $fatal;
            end else begin
                $display("PASS | %0s", msg);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/pipeline/id_ex_reg.vcd");
        $dumpvars(0, tb_idex);

        $display("Starting id_ex_reg TB");

        // init
        rst = 0;
        flush  = 0;
        pc_in = 0;
        pc4_in = 0;
        rs1_val_in = 0;
        rs2_val_in = 0;
        imm_in  = 0;
        rs1_in = 0;
        rs2_in = 0;
        rd_in = 0;
        funct3_in = 0;
        RegWEn_in = 0;
        MemRW_in = 0;
        WBSel_in = 0;
        ASel_in = 0;
        BSel_in = 0;
        ALUSel_in = 0;
        BrUn_in = 0;
        Branch_in = 0;
        Jump_in = 0;
        Jalr_in  = 0;

        // test 1: reset clears all
        rst = 1;
        @(posedge clk);
        #1;
        check_all(
            32'h0, 32'h0, 32'h0, 32'h0, 32'h0,
            5'h0, 5'h0, 5'h0, 3'h0,
            1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 4'h0, 1'b0, 1'b0, 1'b0, 1'b0,
            "reset clears outputs"
        );

        // test 2: normal load
        rst = 0;
        flush = 0;
        pc_in = 32'h00000020;
        pc4_in = 32'h00000024;
        rs1_val_in = 32'h11111111;
        rs2_val_in = 32'h22222222;
        imm_in = 32'h00000010;
        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in = 5'd3;
        funct3_in = 3'b000;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b0;
        WBSel_in = 2'b01;
        ASel_in = 1'b0;
        BSel_in = 1'b1;
        ALUSel_in = 4'b0010;
        BrUn_in  = 1'b0;
        Branch_in = 1'b0;
        Jump_in  = 1'b0;
        Jalr_in  = 1'b0;

        @(posedge clk);
        #1;
        check_all(
            32'h00000020, 32'h00000024, 32'h11111111, 32'h22222222, 32'h00000010,
            5'd1, 5'd2, 5'd3, 3'b000,
            1'b1, 1'b0, 2'b01, 1'b0, 1'b1, 4'b0010, 1'b0, 1'b0, 1'b0, 1'b0,
            "normal load"
        );

        // test 3: flush clears all
        flush  = 1;
        pc_in = 32'hDEADBEEF;
        pc4_in = 32'hCAFEBABE;
        rs1_val_in = 32'hAAAAAAAA;
        rs2_val_in = 32'hBBBBBBBB;
        imm_in = 32'hCCCCCCCC;
        rs1_in  = 5'd10;
        rs2_in = 5'd11;
        rd_in = 5'd12;
        funct3_in = 3'b111;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b1;
        WBSel_in = 2'b10;
        ASel_in = 1'b1;
        BSel_in = 1'b1;
        ALUSel_in = 4'b1111;
        BrUn_in = 1'b1;
        Branch_in = 1'b1;
        Jump_in = 1'b1;
        Jalr_in = 1'b1;

        @(posedge clk);
        #1;
        check_all(
            32'h0, 32'h0, 32'h0, 32'h0, 32'h0,
            5'h0, 5'h0, 5'h0, 3'h0,
            1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 4'h0, 1'b0, 1'b0, 1'b0, 1'b0,
            "flush clears outputs"
        );

        // test 4: load branch/jump style controls
        flush = 0;
        pc_in  = 32'h00000100;
        pc4_in = 32'h00000104;
        rs1_val_in = 32'h12345678;
        rs2_val_in = 32'h87654321;
        imm_in = 32'h00000040;
        rs1_in  = 5'd4;
        rs2_in = 5'd5;
        rd_in  = 5'd6;
        funct3_in = 3'b101;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b1;
        WBSel_in = 2'b10;
        ASel_in = 1'b1;
        BSel_in = 1'b0;
        ALUSel_in = 4'b0110;
        BrUn_in = 1'b1;
        Branch_in = 1'b1;
        Jump_in = 1'b0;
        Jalr_in = 1'b1;

        @(posedge clk);
        #1;
        check_all(
            32'h00000100, 32'h00000104, 32'h12345678, 32'h87654321, 32'h00000040,
            5'd4, 5'd5, 5'd6, 3'b101,
            1'b1, 1'b1, 2'b10, 1'b1, 1'b0, 4'b0110, 1'b1, 1'b1, 1'b0, 1'b1,
            "load all fields"
        );

        // test 5: reset priority over flush/data
        rst = 1;
        flush  = 1;
        pc_in = 32'hFFFFFFFF;
        pc4_in  = 32'hFFFFFFFF;
        rs1_val_in = 32'hFFFFFFFF;
        rs2_val_in = 32'hFFFFFFFF;
        imm_in  = 32'hFFFFFFFF;
        rs1_in  = 5'h1F;
        rs2_in = 5'h1F;
        rd_in  = 5'h1F;
        funct3_in = 3'b111;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b1;
        WBSel_in = 2'b11;
        ASel_in = 1'b1;
        BSel_in  = 1'b1;
        ALUSel_in = 4'hF;
        BrUn_in = 1'b1;
        Branch_in = 1'b1;
        Jump_in = 1'b1;
        Jalr_in  = 1'b1;

        @(posedge clk);
        #1;
        check_all(
            32'h0, 32'h0, 32'h0, 32'h0, 32'h0,
            5'h0, 5'h0, 5'h0, 3'h0,
            1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 4'h0, 1'b0, 1'b0, 1'b0, 1'b0,
            "reset priority"
        );

        $display("All id_ex_reg tests PASSED!");
        $finish;
    end

endmodule

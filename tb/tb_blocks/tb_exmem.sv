`timescale 1ns/1ps

module tb_exmem;

    reg clk;
    reg rst;

    reg [31:0] pc4_in;
    reg [31:0] alu_result_in;
    reg [31:0] rs2_fwd_in;
    reg [4:0] rd_in;
    reg [2:0] funct3_in;

    reg RegWEn_in;
    reg MemRW_in;
    reg [1:0] WBSel_in;

    wire [31:0] pc4_out;
    wire [31:0] alu_result_out;
    wire [31:0] rs2_fwd_out;
    wire [4:0] rd_out;
    wire [2:0] funct3_out;

    wire RegWEn_out;
    wire MemRW_out;
    wire [1:0] WBSel_out;

    ex_mem_reg dut(
        .clk(clk),
        .rst(rst),

        .pc4_in(pc4_in),
        .alu_result_in(alu_result_in),
        .rs2_fwd_in(rs2_fwd_in),
        .rd_in(rd_in),
        .funct3_in(funct3_in),

        .RegWEn_in(RegWEn_in),
        .MemRW_in(MemRW_in),
        .WBSel_in(WBSel_in),

        .pc4_out(pc4_out),
        .alu_result_out(alu_result_out),
        .rs2_fwd_out(rs2_fwd_out),
        .rd_out(rd_out),
        .funct3_out(funct3_out),

        .RegWEn_out(RegWEn_out),
        .MemRW_out(MemRW_out),
        .WBSel_out(WBSel_out)
    );

    ex_mem_sva assertions_inst(
        .clk(clk),
        .rst(rst),

        .pc4_in(pc4_in),
        .alu_result_in(alu_result_in),
        .rs2_fwd_in(rs2_fwd_in),
        .rd_in(rd_in),
        .funct3_in(funct3_in),

        .RegWEn_in(RegWEn_in),
        .MemRW_in(MemRW_in),
        .WBSel_in(WBSel_in),

        .pc4_out(pc4_out),
        .alu_result_out(alu_result_out),
        .rs2_fwd_out(rs2_fwd_out),
        .rd_out(rd_out),
        .funct3_out(funct3_out),

        .RegWEn_out(RegWEn_out),
        .MemRW_out(MemRW_out),
        .WBSel_out(WBSel_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check_outputs;
        input [31:0] exp_pc4;
        input [31:0] exp_alu_result;
        input [31:0] exp_rs2_fwd;
        input [4:0] exp_rd;
        input [2:0] exp_funct3;
        input exp_RegWEn;
        input exp_MemRW;
        input [1:0] exp_WBSel;
        input [255:0] msg;
        begin
            if (pc4_out !== exp_pc4 ||
                alu_result_out !== exp_alu_result ||
                rs2_fwd_out !== exp_rs2_fwd ||
                rd_out !== exp_rd ||
                funct3_out !== exp_funct3 ||
                RegWEn_out !== exp_RegWEn ||
                MemRW_out !== exp_MemRW ||
                WBSel_out !== exp_WBSel) begin
                $display("FAIL | %0s", msg);
                $display("pc4_out=%h exp=%h", pc4_out, exp_pc4);
                $display("alu_result_out=%h exp=%h", alu_result_out, exp_alu_result);
                $display("rs2_fwd_out=%h exp=%h", rs2_fwd_out, exp_rs2_fwd);
                $display("rd_out=%h exp=%h", rd_out, exp_rd);
                $display("funct3_out=%h exp=%h", funct3_out, exp_funct3);
                $display("RegWEn_out=%b exp=%b", RegWEn_out, exp_RegWEn);
                $display("MemRW_out=%b exp=%b", MemRW_out, exp_MemRW);
                $display("WBSel_out=%b exp=%b", WBSel_out, exp_WBSel);
                $fatal;
            end
            else begin
                $display("PASS | %0s", msg);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/pipeline/ex_mem_reg.vcd");
        $dumpvars(0, tb_exmem);

        $display("Starting ex_mem_reg TB");

        rst = 0;
        pc4_in = 32'h0;
        alu_result_in = 32'h0;
        rs2_fwd_in = 32'h0;
        rd_in = 5'h0;
        funct3_in = 3'h0;
        RegWEn_in = 1'b0;
        MemRW_in = 1'b0;
        WBSel_in = 2'b00;

        // Test 1: reset clears outputs
        rst = 1;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000000,
            32'h00000000,
            32'h00000000,
            5'h00,
            3'h0,
            1'b0,
            1'b0,
            2'b00,
            "reset clears outputs"
        );

        // Test 2: normal propagation
        rst = 0;
        pc4_in = 32'h00000024;
        alu_result_in = 32'h12345678;
        rs2_fwd_in = 32'hDEADBEEF;
        rd_in = 5'd7;
        funct3_in = 3'b010;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b0;
        WBSel_in = 2'b01;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000024,
            32'h12345678,
            32'hDEADBEEF,
            5'd7,
            3'b010,
            1'b1,
            1'b0,
            2'b01,
            "normal propagation"
        );

        // Test 3: store-style case
        pc4_in = 32'h00000104;
        alu_result_in = 32'h00000080;
        rs2_fwd_in = 32'hCAFEBABE;
        rd_in = 5'd12;
        funct3_in = 3'b010;
        RegWEn_in = 1'b0;
        MemRW_in = 1'b1;
        WBSel_in = 2'b00;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000104,
            32'h00000080,
            32'hCAFEBABE,
            5'd12,
            3'b010,
            1'b0,
            1'b1,
            2'b00,
            "store-style propagation"
        );

        // Test 4: another mixed pattern
        pc4_in = 32'h00000204;
        alu_result_in = 32'hABCDEF01;
        rs2_fwd_in = 32'h11112222;
        rd_in = 5'd3;
        funct3_in = 3'b000;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b1;
        WBSel_in = 2'b10;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000204,
            32'hABCDEF01,
            32'h11112222,
            5'd3,
            3'b000,
            1'b1,
            1'b1,
            2'b10,
            "all fields propagate"
        );

        // Test 5: reset priority
        rst = 1;
        pc4_in = 32'hFFFFFFFF;
        alu_result_in = 32'hFFFFFFFF;
        rs2_fwd_in = 32'hFFFFFFFF;
        rd_in = 5'h1F;
        funct3_in = 3'b111;
        RegWEn_in = 1'b1;
        MemRW_in = 1'b1;
        WBSel_in = 2'b11;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000000,
            32'h00000000,
            32'h00000000,
            5'h00,
            3'h0,
            1'b0,
            1'b0,
            2'b00,
            "reset priority over inputs"
        );

        $display("All ex_mem_reg tests PASSED!");
        $finish;
    end

endmodule

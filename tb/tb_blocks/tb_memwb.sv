`timescale 1ns/1ps

module tb_memwb;

    reg clk;
    reg rst;

    reg [31:0] pc4_in;
    reg [31:0] alu_result_in;
    reg [31:0] mem_rdata_in;
    reg [4:0] rd_in;

    reg RegWEn_in;
    reg [1:0] WBSel_in;

    wire [31:0] pc4_out;
    wire [31:0] alu_result_out;
    wire [31:0] mem_rdata_out;
    wire [4:0] rd_out;

    wire RegWEn_out;
    wire [1:0] WBSel_out;

    mem_wb_reg dut(
        .clk(clk),
        .rst(rst),

        .pc4_in(pc4_in),
        .alu_result_in(alu_result_in),
        .mem_rdata_in(mem_rdata_in),
        .rd_in(rd_in),

        .RegWEn_in(RegWEn_in),
        .WBSel_in(WBSel_in),

        .pc4_out(pc4_out),
        .alu_result_out(alu_result_out),
        .mem_rdata_out(mem_rdata_out),
        .rd_out(rd_out),

        .RegWEn_out(RegWEn_out),
        .WBSel_out(WBSel_out)
    );

    mem_wb_sva assertions_inst(
        .clk(clk),
        .rst(rst),

        .pc4_in(pc4_in),
        .alu_result_in(alu_result_in),
        .mem_rdata_in(mem_rdata_in),
        .rd_in(rd_in),

        .RegWEn_in(RegWEn_in),
        .WBSel_in(WBSel_in),

        .pc4_out(pc4_out),
        .alu_result_out(alu_result_out),
        .mem_rdata_out(mem_rdata_out),
        .rd_out(rd_out),

        .RegWEn_out(RegWEn_out),
        .WBSel_out(WBSel_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check_outputs;
        input [31:0] exp_pc4;
        input [31:0] exp_alu_result;
        input [31:0] exp_mem_rdata;
        input [4:0] exp_rd;
        input exp_RegWEn;
        input [1:0] exp_WBSel;
        input [255:0] msg;
        begin
            if (pc4_out !== exp_pc4 ||
                alu_result_out !== exp_alu_result ||
                mem_rdata_out !== exp_mem_rdata ||
                rd_out !== exp_rd ||
                RegWEn_out !== exp_RegWEn ||
                WBSel_out !== exp_WBSel) begin
                $display("FAIL | %0s", msg);
                $display("pc4_out=%h exp=%h", pc4_out, exp_pc4);
                $display("alu_result_out=%h exp=%h", alu_result_out, exp_alu_result);
                $display("mem_rdata_out=%h exp=%h", mem_rdata_out, exp_mem_rdata);
                $display("rd_out=%h exp=%h", rd_out, exp_rd);
                $display("RegWEn_out=%b exp=%b", RegWEn_out, exp_RegWEn);
                $display("WBSel_out=%b exp=%b", WBSel_out, exp_WBSel);
                $fatal;
            end
            else begin
                $display("PASS | %0s", msg);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/pipeline/mem_wb_reg.vcd");
        $dumpvars(0, tb_memwb);

        $display("Starting mem_wb_reg TB");

        rst = 0;
        pc4_in = 32'h0;
        alu_result_in = 32'h0;
        mem_rdata_in = 32'h0;
        rd_in = 5'h0;
        RegWEn_in = 1'b0;
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
            1'b0,
            2'b00,
            "reset clears outputs"
        );

        // Test 2: ALU writeback case
        rst = 0;
        pc4_in = 32'h00000024;
        alu_result_in = 32'h12345678;
        mem_rdata_in = 32'hDEADBEEF;
        rd_in = 5'd7;
        RegWEn_in = 1'b1;
        WBSel_in = 2'b01;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000024,
            32'h12345678,
            32'hDEADBEEF,
            5'd7,
            1'b1,
            2'b01,
            "normal propagation"
        );

        // Test 3: memory read style case
        pc4_in = 32'h00000104;
        alu_result_in = 32'h00000080;
        mem_rdata_in = 32'hCAFEBABE;
        rd_in = 5'd12;
        RegWEn_in = 1'b1;
        WBSel_in = 2'b00;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000104,
            32'h00000080,
            32'hCAFEBABE,
            5'd12,
            1'b1,
            2'b00,
            "memory read propagation"
        );

        // Test 4: PC+4 writeback style case
        pc4_in = 32'h00000204;
        alu_result_in = 32'hABCDEF01;
        mem_rdata_in = 32'h11112222;
        rd_in = 5'd3;
        RegWEn_in = 1'b1;
        WBSel_in = 2'b10;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000204,
            32'hABCDEF01,
            32'h11112222,
            5'd3,
            1'b1,
            2'b10,
            "pc4 writeback propagation"
        );

        // Test 5: RegWEn low case
        pc4_in = 32'h00000304;
        alu_result_in = 32'h22223333;
        mem_rdata_in = 32'h44445555;
        rd_in = 5'd9;
        RegWEn_in = 1'b0;
        WBSel_in = 2'b01;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000304,
            32'h22223333,
            32'h44445555,
            5'd9,
            1'b0,
            2'b01,
            "RegWEn low propagation"
        );

        // Test 6: reset priority
        rst = 1;
        pc4_in = 32'hFFFFFFFF;
        alu_result_in = 32'hFFFFFFFF;
        mem_rdata_in = 32'hFFFFFFFF;
        rd_in = 5'h1F;
        RegWEn_in = 1'b1;
        WBSel_in = 2'b11;
        @(posedge clk);
        #1;
        check_outputs(
            32'h00000000,
            32'h00000000,
            32'h00000000,
            5'h00,
            1'b0,
            2'b00,
            "reset priority over inputs"
        );

        $display("All mem_wb_reg tests PASSED!");
        $finish;
    end

endmodule

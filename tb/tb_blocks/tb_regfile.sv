`timescale 1ns/1ps


module tb_regfile;

    logic clk;
    logic  rst;
    logic  write_enable;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] write_data;

    wire  [31:0] rd1;
    wire  [31:0] rd2;

    integer errors = 0;

    //instantiate top
    reg_file dut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    // instantiate assertions
    reg_file_sva assertions_inst (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // if fails? 
    task automatic check_reads(
        input logic [31:0] expected_rd1,
        input logic [31:0] expected_rd2
    );
    begin
        #1;
        if ((rd1 !== expected_rd1) || (rd2 !== expected_rd2)) begin
            $display("FAIL | rs1=%0d rs2=%0d rd=%0d we=%b wd=%h | rd1=%h exp=%h | rd2=%h exp=%h",
                     rs1, rs2, rd, write_enable, write_data,
                     rd1, expected_rd1, rd2, expected_rd2);
            errors = errors + 1;
        end
        else begin
            $display("PASS | rs1=%0d rs2=%0d | rd1=%h rd2=%h",
                     rs1, rs2, rd1, rd2);
        end
    end
    endtask


    // start test
    task automatic write_reg(
        input logic [4:0]  w_rd,
        input logic [31:0] w_data
    );
    begin
        @(negedge clk);
        write_enable = 1'b1;
        rd           = w_rd;
        write_data   = w_data;

        @(posedge clk);
        #1;

        @(negedge clk);
        write_enable = 1'b0;
        rd           = 5'd0;
        write_data   = 32'd0;
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/reg_file/regfile.vcd");
        $dumpvars(0, tb_regfile);

        $display("Starting reg_file testbench...");

        rst          = 1'b1;
        write_enable = 1'b0;
        rs1          = 5'd0;
        rs2          = 5'd0;
        rd           = 5'd0;
        write_data   = 32'd0;

        @(posedge clk);
        #1;
        check_reads(32'd0, 32'd0);

        @(negedge clk);
        rst = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd1;
        #1;
        check_reads(32'd0, 32'd0);

        write_reg(5'd5, 32'h1234_5678);
        rs1 = 5'd5;
        rs2 = 5'd0;
        #1;
        check_reads(32'h1234_5678, 32'd0);

        write_reg(5'd10, 32'hDEAD_BEEF);
        rs1 = 5'd10;
        rs2 = 5'd5;
        #1;
        check_reads(32'hDEAD_BEEF, 32'h1234_5678);

        write_reg(5'd0, 32'hFFFF_FFFF);
        rs1 = 5'd0;
        rs2 = 5'd10;
        #1;
        check_reads(32'd0, 32'hDEAD_BEEF);

        write_reg(5'd5, 32'hAAAA_5555);
        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;
        check_reads(32'hAAAA_5555, 32'hDEAD_BEEF);

        @(negedge clk);
        rst          = 1'b1;
        write_enable = 1'b0;

        @(posedge clk);
        #1;

        @(negedge clk);
        rst = 1'b0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;
        check_reads(32'd0, 32'd0);


        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("%0d tests FAILED.", errors);

        $finish;
    end

endmodule


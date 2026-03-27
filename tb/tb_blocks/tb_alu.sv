`timescale 1ns/1ps

module tb_alu; 

    logic clk; 
    logic [31:0] a; 
    logic [31:0] b; 
    logic [3:0] alu_sel; 

    wire [31:0] y; 
    wire zero; 
    wire lt_signed; 
    wire lt_unsigned; 

    integer errors = 0; 

    alu dut(
        .a(a), 
        .b(b), 
        .alu_sel(alu_sel), 
        .y(y), 
        .zero(zero), 
        .lt_signed(lt_signed), 
        .lt_unsigned(lt_unsigned)
    );

    //sva
    alu_sva assertions_inst (
        .clk(clk),
        .a(a),
        .b(b),
        .alu_sel(alu_sel),
        .y(y),
        .zero(zero),
        .lt_signed(lt_signed),
        .lt_unsigned(lt_unsigned)
    );

    //clock for assertion 
    initial clk = 0; 
    always #5 clk = ~clk; 

    // check task 
        task automatic check(
        input logic [31:0] expected_y,
        input logic expected_zero,
        input logic expected_lt_signed,
        input logic expected_lt_unsigned
    );
    begin
        #2;
        if ((y !== expected_y) ||
            (zero !== expected_zero) ||
            (lt_signed !== expected_lt_signed) ||
            (lt_unsigned !== expected_lt_unsigned)) begin

            $display("FAIL | a=%h b=%h sel=%0d | y=%h exp=%h | zero=%b exp=%b | lts=%b exp=%b | ltu=%b exp=%b",
                     a, b, alu_sel,
                     y, expected_y,
                     zero, expected_zero,
                     lt_signed, expected_lt_signed,
                     lt_unsigned, expected_lt_unsigned);
            errors = errors + 1;
        end
        else begin
            $display("PASS | a=%h b=%h sel=%0d | y=%h zero=%b lts=%b ltu=%b",
                     a, b, alu_sel, y, zero, lt_signed, lt_unsigned);
        end
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/alu.vcd");
        $dumpvars(0, tb_alu);

        $display("Starting ALU Testbench...");

        // ADD (sel=0)
        a = 32'd5;b = 32'd7; alu_sel = 4'd0;
        check(32'd12, 1'b0, 1'b1, 1'b1);

        // SUB (sel=1)
        a = 32'd10; b = 32'd3;alu_sel = 4'd1;
        check(32'd7, 1'b0, 1'b0, 1'b0);

        // AND (sel=2)
        a = 32'hF0F0_F0F0; b = 32'h0FF0_00FF; alu_sel = 4'd2;
        check(32'h00F0_00F0, 1'b0, 1'b1, 1'b0);

        // OR (sel=3)
        a = 32'h0000_00F0;b = 32'h0000_000F; alu_sel = 4'd3;
        check(32'h0000_00FF, 1'b0, 1'b0, 1'b0);

        // XOR (sel=4)
        a = 32'hAAAA_AAAA; b = 32'hFFFF_0000; alu_sel = 4'd4;
        check(32'h5555_AAAA, 1'b0, 1'b1, 1'b1);

        // SLL (sel=5), shift by 4
        a = 32'h0000_0001; b = 32'd4; alu_sel = 4'd5;
        check(32'h0000_0010, 1'b0, 1'b1, 1'b1);

        // SRL (sel=6), shift by 4
        a = 32'h0000_0100; b = 32'd4; alu_sel = 4'd6;
        check(32'h0000_0010, 1'b0, 1'b0, 1'b0);

        // SRA (sel=7), arithmetic right shift
        a = 32'hFFFF_FF80; b = 32'd4; alu_sel = 4'd7;
        check(32'hFFFF_FFF8, 1'b0, 1'b1, 1'b0);

        // SLT signed (sel=8): -1 < 1 => 1
        a = 32'hFFFF_FFFF; b = 32'd1; alu_sel = 4'd8;
        check(32'd1, 1'b0, 1'b1, 1'b0);

        // SLTU unsigned (sel=9): 0xFFFFFFFF < 1 => 0
        a = 32'hFFFF_FFFF;b = 32'd1; alu_sel = 4'd9;
        check(32'd0, 1'b1, 1'b1, 1'b0);

        // PASS_B (sel=10)
        a = 32'h1234_5678; b = 32'hDEAD_BEEF; alu_sel = 4'd10;
        check(32'hDEAD_BEEF, 1'b0, 1'b0, 1'b1);

        #10;

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("%0d tests FAILED.", errors);

        $finish;
    end


endmodule 

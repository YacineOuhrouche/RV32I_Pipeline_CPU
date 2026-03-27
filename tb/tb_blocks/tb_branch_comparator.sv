`timescale 1ns/1ps

module tb_branch_comparator; 

    logic clk; 
    logic [31:0] a; 
    logic [31:0] b; 
    logic BrUn; 
    

    wire BrEq; 
    wire BrLT; 

    integer errors  = 0; 

    branch_comparator dut(
        .a(a), 
        .b(b),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
    );

    branch_comparator_sva assertions_inst (
        .clk(clk),
        .a(a),
        .b(b),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check(
        input logic expected_eq,
        input logic expected_lt
    );
    begin
        #2;
        if ((BrEq !== expected_eq) || (BrLT !== expected_lt)) begin
            $display("FAIL | a=%h b=%h BrUn=%b | BrEq=%b exp=%b | BrLT=%b exp=%b",
                     a, b, BrUn, BrEq, expected_eq, BrLT, expected_lt);
            errors = errors + 1;
        end
        else begin
            $display("PASS | a=%h b=%h BrUn=%b | BrEq=%b BrLT=%b",
                     a, b, BrUn, BrEq, BrLT);
        end
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/branch_comparator/branch_comparator.vcd");
        $dumpvars(0, tb_branch_comparator);

        $display("Starting branch_comparator testbench...");

        // Equal values
        a = 32'd5; b = 32'd5;BrUn = 1'b0; 
        check(1'b1, 1'b0);
        a = 32'd5; b = 32'd5; BrUn = 1'b1; 
        check(1'b1, 1'b0);

        // Signed compare: -1 < 1 => true
        a = 32'hFFFF_FFFF; b = 32'd1;BrUn = 1'b0; 
        check(1'b0, 1'b1);

        // Unsigned compare: 0xFFFFFFFF < 1 => false
        a = 32'hFFFF_FFFF;  b = 32'd1; BrUn = 1'b1;
         check(1'b0, 1'b0);

        // Signed compare: -8 < -4 => true
        a = 32'hFFFF_FFF8; b = 32'hFFFF_FFFC; BrUn = 1'b0; 
        check(1'b0, 1'b1);

        // Unsigned compare: large > smaller => false
        a = 32'h8000_0000; b = 32'h7FFF_FFFF; BrUn = 1'b1; 
        check(1'b0, 1'b0);

        // Signed compare: -2147483648 < 2147483647 => true
        a = 32'h8000_0000;b = 32'h7FFF_FFFF;BrUn = 1'b0;
         check(1'b0, 1'b1);

        // Unsigned compare: 3 < 7 => true
        a = 32'd3; b = 32'd7; BrUn = 1'b1;
         check(1'b0, 1'b1);

        // Signed compare: 9 < 2 => false
        a = 32'd9;  b = 32'd2; BrUn = 1'b0; 
        check(1'b0, 1'b0);

        // Zero and equal
        a = 32'd0;  b = 32'd0; BrUn = 1'b0;
         check(1'b1, 1'b0);

        #10;

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("%0d tests FAILED.", errors);

        $finish;
    end

endmodule


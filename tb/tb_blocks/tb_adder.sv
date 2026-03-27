`timescale 1ns/1ps

module tb_adder;

    logic clk;
    logic [31:0] a;
    logic [31:0] b;
    wire  [31:0] sum;

    int errors = 0;

    // isntantiale .v 
    adder dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    // instantiate sva
    adder_sva assertions_inst (
        .clk(clk),
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/sim_blocks/adder.vcd");
        $dumpvars(0, tb_adder);
    end

    // what to do if fail
    task automatic test_case(
        input logic [31:0] ta,
        input logic [31:0] tb,
        input logic [31:0] exp
    );
    begin
        a = ta;
        b = tb;

        #2;

        if (sum !== exp) begin
            $display("FAIL | a=%h b=%h | sum=%h expected=%h",
                     a, b, sum, exp);
            errors++;
        end else begin
            $display("PASS | a=%h b=%h | sum=%h",
                     a, b, sum);
        end
    end
    endtask

    // start of test
    initial begin
        $display("starting adder tb");

        test_case(32'd5, 32'd7, 32'd12);
        test_case(32'd10,32'd20,32'd30);
        test_case(32'hFFFF_FFFF, 32'd1,32'd0);
        test_case(32'd100, 32'd300,  32'd400);
        test_case(32'h1234_5678, 32'h1111_1111, 32'h2345_6789);

        #10;

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule

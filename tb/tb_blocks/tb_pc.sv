`timescale 1ns/1ps

module tb_pc;

    reg clk;
    reg rst;
    reg en;
    reg [31:0] next_pc;
    wire [31:0] pc_current;

    integer errors;

    pc dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .next_pc(next_pc),
        .pc_current(pc_current)
    );

    pc_sva assertions_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .next_pc(next_pc),
        .pc_current(pc_current)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] msg;
        begin
            if (actual !== expected) begin
                $display("ERROR %0s actual=%h expected=%h time=%0t", msg, actual, expected, $time);
                errors = errors + 1;
            end
            else begin
                $display("PASS %0s value=%h", msg, actual);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/pc/pc.vcd");
        $dumpvars(0, tb_pc);

        errors = 0;

        rst = 1'b1;
        en = 1'b1;
        next_pc = 32'h00000004;

        // Reset test
        @(posedge clk);
        #1;
        check(pc_current, 32'h00000000, "reset sets PC to 0");

        // Normal update
        rst = 1'b0;
        @(negedge clk);
next_pc = 32'h00000004;
en = 1'b1;

        @(posedge clk);
        #1;
        check(pc_current, 32'h00000004, "PC updates to next_pc");

        // Another normal update
        @(negedge clk);
next_pc = 32'h00000008;
en = 1'b1;

        @(posedge clk);
        #1;
        check(pc_current, 32'h00000008, "PC updates again");

        // Stall test
        @(negedge clk);
next_pc = 32'h0000000C;
en = 1'b0;

        @(posedge clk);
        #1;
        check(pc_current, 32'h00000008, "PC holds when en is 0");

        // Resume after stall
        @(negedge clk);
next_pc = 32'h0000000C;
en = 1'b1;

        @(posedge clk);
        #1;
        check(pc_current, 32'h0000000C, "PC resumes when en is 1");

        // Reset priority over enable
        @(negedge clk);
rst = 1'b1;
en = 1'b0;
next_pc = 32'h00000020;

        @(posedge clk);
        #1;
        check(pc_current, 32'h00000000, "reset has priority over enable");

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("Tests FAILED with %0d errors", errors);

        $finish;
    end

endmodule

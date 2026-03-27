`timescale 1ns/1ps

module tb_mux2;

    logic [31:0] a;
    logic [31:0] b;
    logic sel;
    wire  [31:0] y;

    integer errors;

    mux2 dut (
        .a (a),
        .b (b),
        .sel (sel),
        .y (y)
    );

    mux2_sva assertions_inst (
        .a (a),
        .b (b),
        .sel (sel),
        .y (y)
    );

    task check(input [31:0] expected);
    begin
        if (y !== expected) begin
            $display("FAIL | sel=%b a=%h b=%h y=%h expected=%h",
                     sel, a, b, y, expected);
            errors = errors + 1;
        end
        else begin
            $display("PASS | sel=%b y=%h", sel, y);
        end
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/muxes/mux2.vcd");
        $dumpvars(0, tb_mux2);

        $display("Starting mux2 TB");

        errors = 0;

        a   = 32'hAAAA_AAAA;
        b   = 32'h5555_5555;
        sel = 1'b0;
        #1;
        check(a);

        sel = 1'b1;
        #1;
        check(b);

        a   = 32'h1234_5678;
        b   = 32'hDEAD_BEEF;
        sel = 1'b0;
        #1;
        check(a);

        sel = 1'b1;
        #1;
        check(b);

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("All tests completed with %0d error(s).", errors);

        $finish;
    end

endmodule

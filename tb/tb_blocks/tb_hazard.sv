`timescale 1ns/1ps

module tb_hazard;

    logic clk;
    logic idex_is_load;
    logic [4:0] idex_rd;
    logic [4:0]  ifid_rs1;
    logic [4:0] ifid_rs2;
    wire  stall;

    integer pass_count;
    integer fail_count;

    // DUT
    hazard_unit dut (
        .idex_is_load(idex_is_load),
        .idex_rd  (idex_rd),
        .ifid_rs1(ifid_rs1),
        .ifid_rs2(ifid_rs2),
        .stall(stall)
    );

    // Attach assertions
    hazard_sva assertions_inst (
        .clk(clk),
        .idex_is_load(idex_is_load),
        .idex_rd(idex_rd),
        .ifid_rs1(ifid_rs1),
        .ifid_rs2(ifid_rs2),
        .stall (stall)
    );

    // Clock for SVA sampling
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task
    task automatic run_test(
        input logic t_idex_is_load,
        input logic [4:0] t_idex_rd,
        input logic [4:0] t_ifid_rs1,
        input logic [4:0] t_ifid_rs2,
        input logic expected_stall,
        input string test_name
    );
    begin
        idex_is_load = t_idex_is_load;
        idex_rd  = t_idex_rd;
        ifid_rs1 = t_ifid_rs1;
        ifid_rs2 = t_ifid_rs2;

        // wait for combinational settle, then sample
        #1;

        if (stall !== expected_stall) begin
            $display("FAIL | %s | load=%0b rd=%0d rs1=%0d rs2=%0d | stall=%0b expected=%0b",
                     test_name, idex_is_load, idex_rd, ifid_rs1, ifid_rs2, stall, expected_stall);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS | %s | load=%0b rd=%0d rs1=%0d rs2=%0d | stall=%0b",
                     test_name, idex_is_load, idex_rd, ifid_rs1, ifid_rs2, stall);
            pass_count = pass_count + 1;
        end

        // allow one clock edge for SVA to sample
        @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/hazard/hazard_unit.vcd");
        $dumpvars(0, tb_hazard);

        $display("Starting hazard_unit TB");

        pass_count = 0;
        fail_count = 0;

        idex_is_load = 0;
        idex_rd = 5'd0;
        ifid_rs1  = 5'd0;
        ifid_rs2  = 5'd0;

        @(posedge clk);

        // No load -> no stall
        run_test(1'b0, 5'd5, 5'd5, 5'd0, 1'b0, "no load, rs1 match");
        run_test(1'b0, 5'd5, 5'd0, 5'd5, 1'b0, "no load, rs2 match");
        run_test(1'b0, 5'd5, 5'd5, 5'd5, 1'b0, "no load, both match");

        // Load but rd = x0 -> no stall
        run_test(1'b1, 5'd0, 5'd0, 5'd0, 1'b0, "load with rd=x0");
        run_test(1'b1, 5'd0, 5'd3, 5'd4, 1'b0, "load with rd=x0, no dependency");

        // Load-use hazard on rs1
        run_test(1'b1, 5'd7, 5'd7, 5'd2, 1'b1, "hazard on rs1");

        // Load-use hazard on rs2
        run_test(1'b1, 5'd8, 5'd1, 5'd8, 1'b1, "hazard on rs2");

        // Load-use hazard on both
        run_test(1'b1, 5'd9, 5'd9, 5'd9, 1'b1, "hazard on both rs1 and rs2");

        // No dependency -> no stall
        run_test(1'b1, 5'd10, 5'd1, 5'd2, 1'b0, "load, no dependency");

        // Additional edge cases
        run_test(1'b1, 5'd31, 5'd31, 5'd0, 1'b1, "max reg match rs1");
        run_test(1'b1, 5'd31, 5'd0, 5'd31, 1'b1, "max reg match rs2");
        run_test(1'b1, 5'd15, 5'd14, 5'd13, 1'b0, "different registers");

        $display("TB done | PASS=%0d FAIL=%0d", pass_count, fail_count);
    

        if (fail_count == 0)
            $display("All tests PASSED!");
        else
            $display("Some tests FAILED!");

        $finish;
    end

endmodule

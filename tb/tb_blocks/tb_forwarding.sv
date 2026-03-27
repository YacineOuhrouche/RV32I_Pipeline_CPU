`timescale 1ns/1ps

module tb_forwarding;

    logic clk;
    logic  exmem_regwrite;
    logic [4:0] exmem_rd;
    logic   memwb_regwrite;
    logic [4:0] memwb_rd;
    logic [4:0] idex_rs1;
    logic [4:0] idex_rs2;
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    integer pass_count;
    integer fail_count;

    // DUT
    forwarding_unit dut (
        .exmem_regwrite(exmem_regwrite),
        .exmem_rd  (exmem_rd),
        .memwb_regwrite(memwb_regwrite),
        .memwb_rd(memwb_rd),
        .idex_rs1 (idex_rs1),
        .idex_rs2 (idex_rs2),
        .forwardA  (forwardA),
        .forwardB (forwardB)
    );

    // Checker
    forwarding_sva assertions_inst (
        .clk  (clk),
        .exmem_regwrite(exmem_regwrite),
        .exmem_rd (exmem_rd),
        .memwb_regwrite(memwb_regwrite),
        .memwb_rd (memwb_rd),
        .idex_rs1  (idex_rs1),
        .idex_rs2 (idex_rs2),
        .forwardA  (forwardA),
        .forwardB  (forwardB)
    );

    // Clock for sampled checker
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic run_test(
        input logic t_exmem_regwrite,
        input logic [4:0] t_exmem_rd,
        input logic t_memwb_regwrite,
        input logic [4:0] t_memwb_rd,
        input logic [4:0] t_idex_rs1,
        input logic [4:0] t_idex_rs2,
        input logic [1:0] exp_forwardA,
        input logic [1:0] exp_forwardB,
        input string      test_name
    );
    begin
        exmem_regwrite = t_exmem_regwrite;
        exmem_rd = t_exmem_rd;
        memwb_regwrite = t_memwb_regwrite;
        memwb_rd = t_memwb_rd;
        idex_rs1 = t_idex_rs1;
        idex_rs2  = t_idex_rs2;

        #1; // allow combinational logic to settle

        if ((forwardA !== exp_forwardA) || (forwardB !== exp_forwardB)) begin
            $display("FAIL | %s | exmem_we=%0b exmem_rd=%0d memwb_we=%0b memwb_rd=%0d rs1=%0d rs2=%0d | A=%b expA=%b B=%b expB=%b",
                     test_name,
                     exmem_regwrite, exmem_rd,
                     memwb_regwrite, memwb_rd,
                     idex_rs1, idex_rs2,
                     forwardA, exp_forwardA, forwardB, exp_forwardB);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS | %s | A=%b B=%b",
                     test_name, forwardA, forwardB);
            pass_count = pass_count + 1;
        end

        @(posedge clk); // let checker sample
    end
    endtask

    initial begin
        $dumpfile("sim/sim_blocks/forwarding/forwarding_unit.vcd");
        $dumpvars(0, tb_forwarding);

        $display("Starting forwarding_unit TB");

        pass_count = 0;
        fail_count = 0;

        exmem_regwrite = 0;
        exmem_rd  = 5'd0;
        memwb_regwrite = 0;
        memwb_rd  = 5'd0;
        idex_rs1 = 5'd0;
        idex_rs2  = 5'd0;

        @(posedge clk);

        // No writes -> no forwarding
        run_test(1'b0, 5'd0, 1'b0, 5'd0, 5'd1, 5'd2, 2'b00, 2'b00, "no forwarding");

        // EX/MEM forwards to rs1
        run_test(1'b1, 5'd5, 1'b0, 5'd0, 5'd5, 5'd2, 2'b10, 2'b00, "exmem -> rs1");

        // EX/MEM forwards to rs2
        run_test(1'b1, 5'd8, 1'b0, 5'd0, 5'd1, 5'd8, 2'b00, 2'b10, "exmem -> rs2");

        // EX/MEM forwards to both
        run_test(1'b1, 5'd9, 1'b0, 5'd0, 5'd9, 5'd9, 2'b10, 2'b10, "exmem -> both");

        // MEM/WB forwards to rs1
        run_test(1'b0, 5'd0, 1'b1, 5'd6, 5'd6, 5'd3, 2'b01, 2'b00, "memwb -> rs1");

        // MEM/WB forwards to rs2
        run_test(1'b0, 5'd0, 1'b1, 5'd7, 5'd4, 5'd7, 2'b00, 2'b01, "memwb -> rs2");

        // MEM/WB forwards to both
        run_test(1'b0, 5'd0, 1'b1, 5'd10, 5'd10, 5'd10, 2'b01, 2'b01, "memwb -> both");

        // EX/MEM has priority over MEM/WB for rs1
        run_test(1'b1, 5'd11, 1'b1, 5'd11, 5'd11, 5'd2, 2'b10, 2'b00, "priority rs1 exmem over memwb");

        // EX/MEM has priority over MEM/WB for rs2
        run_test(1'b1, 5'd12, 1'b1, 5'd12, 5'd1, 5'd12, 2'b00, 2'b10, "priority rs2 exmem over memwb");

        // Different sources from different stages
        run_test(1'b1, 5'd13, 1'b1, 5'd14, 5'd13, 5'd14, 2'b10, 2'b01, "rs1 exmem, rs2 memwb");

        // x0 should never forward from EX/MEM
        run_test(1'b1, 5'd0, 1'b0, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, "exmem rd=x0 ignored");

        // x0 should never forward from MEM/WB
        run_test(1'b0, 5'd0, 1'b1, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, "memwb rd=x0 ignored");

        // No matches
        run_test(1'b1, 5'd15, 1'b1, 5'd16, 5'd1, 5'd2, 2'b00, 2'b00, "no matches");

        $display("TB done | PASS=%0d FAIL=%0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("All tests PASSED!");
        else
            $display("Some tests FAILED!");

        $finish;
    end

endmodule

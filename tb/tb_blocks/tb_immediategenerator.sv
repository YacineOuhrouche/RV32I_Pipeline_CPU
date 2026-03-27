`timescale 1ns/1ps


module tb_immediategenerator;

    logic [31:0] instr;
    logic [2:0]  imm_sel;
    wire  [31:0] imm;

    integer errors = 0;

    // instantiate top
    immediate_generator dut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    // instantiate sva
    immediate_generator_sva assertions_inst (
        .instr(instr),
        .imm_sel (imm_sel),
        .imm  (imm)
    );

    // if failed
    task automatic check(
        input logic [31:0] t_instr,
        input logic [2:0]  t_imm_sel,
        input logic [31:0] expected_imm,
        input string test_name
    );
    begin
        instr = t_instr;
        imm_sel = t_imm_sel;
        #1;

        if (imm !== expected_imm) begin
            $display("FAIL | %s | instr=%h imm_sel=%b | imm=%h expected=%h",
                     test_name, instr, imm_sel, imm, expected_imm);
            errors = errors + 1;
        end
        else begin
            $display("PASS | %s | instr=%h imm_sel=%b | imm=%h",
                     test_name, instr, imm_sel, imm);
        end
    end
    endtask


    // start test
    initial begin
        $dumpfile("sim/sim_blocks/immediate_generator/immediate_generator.vcd");
        $dumpvars(0, tb_immediategenerator);

        $display("Starting immediate_generator testbench...");

        check(32'h07F00013, 3'b000, 32'h0000007F, "I-type positive");
        check(32'hFFF00013, 3'b000, 32'hFFFFFFFF, "I-type negative");

        check(32'h020001A3, 3'b001, 32'h00000023, "S-type positive");
        check(32'hFE000FA3, 3'b001, 32'hFFFFFFFF, "S-type negative");

        check(32'h00000863, 3'b010, 32'h00000010, "B-type positive");
        check(32'hFE0008E3, 3'b010, 32'hFFFFFFF0, "B-type negative");

        check(32'h12345037, 3'b011, 32'h12345000, "U-type");

        check(32'h0080006F, 3'b100, 32'h00000008, "J-type positive");
        check(32'hFF9FF06F, 3'b100, 32'hFFFFFFF8, "J-type negative");

        check(32'h12345678, 3'b111, 32'h00000000, "Default case");

        if (errors == 0)
            $display("All tests PASSED!");
        else
            $display("%0d tests FAILED.", errors);

        $finish;
    end

endmodule


`timescale 1ns/1ps

module tb_ifid;

    logic clk;
    logic rst;
    logic  en;
    logic flush;
    logic [31:0] pc_in;
    logic [31:0] pc4_in;
    logic [31:0] instr_in;

    wire [31:0] pc_out;
    wire [31:0] pc4_out;
    wire [31:0] instr_out;


    // DUT instantiation
    if_id_reg dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .flush(flush),
        .pc_in(pc_in),
        .pc4_in(pc4_in),
        .instr_in(instr_in),
        .pc_out(pc_out),
        .pc4_out(pc4_out),
        .instr_out(instr_out)
    );

    // SVA instantiation
    if_id_sva assertions_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .flush(flush),
        .pc_in(pc_in),
        .pc4_in(pc4_in),
        .instr_in(instr_in),
        .pc_out(pc_out),
        .pc4_out(pc4_out),
        .instr_out(instr_out)
    );

    // Clock generation 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Task check outputs
    task automatic check_outputs(
        input [31:0] exp_pc,
        input [31:0] exp_pc4,
        input [31:0] exp_instr,
        input string msg
    );
        begin
            if ((pc_out !== exp_pc) || (pc4_out !== exp_pc4) || (instr_out !== exp_instr)) begin
                $display("FAIL | %s | pc_out=%h exp=%h | pc4_out=%h exp=%h | instr_out=%h exp=%h",
                         msg, pc_out, exp_pc, pc4_out, exp_pc4, instr_out, exp_instr);
                $fatal;
            end
            else begin
                $display("PASS | %s | pc_out=%h pc4_out=%h instr_out=%h",
                         msg, pc_out, pc4_out, instr_out);
            end
        end
    endtask


    initial begin
        $dumpfile("sim/sim_blocks/pipeline/if_id_reg.vcd");
        $dumpvars(0, tb_ifid);

        $display("Starting IF/ID register TB");

        rst = 0;
        en = 0;
        flush = 0;
        pc_in = 32'h00000000;
        pc4_in = 32'h00000004;
        instr_in= 32'h00000013;

  
        // Test 1: Reset clears outputs
        rst = 1;
        @(posedge clk);
        #1;
        check_outputs(32'h00000000, 32'h00000000, 32'h00000013, "reset clears register");


        // Test 2: Load when en=1
        rst = 0;
        en  = 1;
        flush  = 0;
        pc_in  = 32'h00000020;
        pc4_in = 32'h00000024;
        instr_in = 32'h00A00093; // addi x1, x0, 10
        @(posedge clk);
        #1;
        check_outputs(32'h00000020, 32'h00000024, 32'h00A00093, "load values when en=1");

       
        // Test 3: Hold when en=0
        en = 0;
        pc_in  = 32'h00000040;
        pc4_in = 32'h00000044;
        instr_in = 32'h12345678;
        @(posedge clk);
        #1;
        check_outputs(32'h00000020, 32'h00000024, 32'h00A00093, "hold values when en=0");

 
        // Test 4: Flush overrides load
        en  = 1;
        flush = 1;
        pc_in  = 32'h00000080;
        pc4_in = 32'h00000084;
        instr_in = 32'hDEADBEEF;
        @(posedge clk);
        #1;
        check_outputs(32'h00000000, 32'h00000000, 32'h00000013, "flush inserts NOP");

       
        // Test 5: Load again after flush
        flush = 0;
        en  = 1;
        pc_in = 32'h00000100;
        pc4_in = 32'h00000104;
        instr_in = 32'h00410133; // add x2, x2, x4 (example)
        @(posedge clk);
        #1;
        check_outputs(32'h00000100, 32'h00000104, 32'h00410133, "load after flush");


        // Test 6: Reset has priority over en
        rst = 1;
        en   = 1;
        flush  = 0;
        pc_in = 32'hABCDEF00;
        pc4_in  = 32'hABCDEF04;
        instr_in = 32'hFFFFFFFF;
        @(posedge clk);
        #1;
        check_outputs(32'h00000000, 32'h00000000, 32'h00000013, "reset priority over en");

        $display("All IF/ID register tests PASSED!");
        $finish;
    end

endmodule

`timescale 1ns/1ps

module tb_riscv_core;

    // ---------------- Clock / Reset ----------------
    reg clk;
    reg rst;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ---------------- Interconnect ----------------
    wire [31:0] pc;
    wire [31:0] instr;

    wire        memrw;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [31:0] mem_rdata;
    wire [2:0]  mem_funct3;

    integer cycle;

    // ---------------- DUT ----------------
    riscv_core_pipelined dut (
        .clk       (clk),
        .rst       (rst),
        .instr     (instr),
        .mem_rdata (mem_rdata),
        .pc        (pc),
        .memrw     (memrw),
        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_funct3(mem_funct3)
    );

    // ---------------- Instruction ROM ----------------
    instruction_rom #(
        .MEM_DEPTH(1024),
        .MEM_FILE ("programs/flush.hex")
    ) imem (
        .addr  (pc),
        .instr (instr)
    );

    // ---------------- Data RAM ----------------
    data_ram #(
        .MEM_BYTES(4096),
        .MEM_FILE ("")
    ) dmem (
        .clk   (clk),
        .memrw (memrw),
        .addr  (mem_addr),
        .wdata (mem_wdata),
        .funct3(mem_funct3),
        .rdata (mem_rdata)
    );

    // ---------------- Reset / setup ----------------
    initial begin
        cycle = 0;
        rst   = 1'b1;

        $dumpfile("sim/sim_final/tb_riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);

        repeat (3) @(posedge clk);
        rst = 1'b0;

        repeat (100) @(posedge clk);
        $display("Simulation finished.");
        $finish;
    end

    // ---------------- Cycle counter ----------------
    always @(posedge clk) begin
        if (!rst)
            cycle <= cycle + 1;
    end

    // ---------------- Minimal output ----------------
    always @(posedge clk) begin
        if (!rst) begin
            $display("cycle=%0d pc=%08h instr=%08h memrw=%b mem_addr=%08h mem_wdata=%08h mem_rdata=%08h",
                     cycle, pc, instr, memrw, mem_addr, mem_wdata, mem_rdata);
        end
    end

endmodule

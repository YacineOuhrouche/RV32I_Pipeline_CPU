`timescale 1ns/1ps

module riscv_core_pipelined (
    input  wire  clk,
    input  wire        rst,

    input  wire [31:0] instr,
    input  wire [31:0] mem_rdata,

    output wire [31:0] pc,
    output wire        memrw,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire [2:0]  mem_funct3
);

    localparam [1:0] WB_MEM = 2'd0;
    localparam [1:0] WB_ALU = 2'd1;
    localparam [1:0] WB_PC4 = 2'd2;

    // ---------------- IF ----------------
    wire [31:0] pc_if;
    wire [31:0] pc_plus4_if;
    wire [31:0] pc_next;
    wire        pc_en;

    pc u_pc (
        .clk       (clk),
        .rst       (rst),
        .en        (pc_en),
        .next_pc   (pc_next),
        .pc_current(pc_if)
    );

    adder u_pc4 (
        .a  (pc_if),
        .b  (32'd4),
        .sum(pc_plus4_if)
    );

    assign pc = pc_if;

    // ---------------- IF/ID ----------------
    wire [31:0] ifid_pc, ifid_pc4, ifid_instr;
    wire        ifid_en;
    wire        ifid_flush;

    if_id_reg u_ifid (
        .clk      (clk),
        .rst      (rst),
        .en       (ifid_en),
        .flush    (ifid_flush),
        .pc_in    (pc_if),
        .pc4_in   (pc_plus4_if),
        .instr_in (instr),
        .pc_out   (ifid_pc),
        .pc4_out  (ifid_pc4),
        .instr_out(ifid_instr)
    );

    wire [4:0] ifid_rs1    = ifid_instr[19:15];
    wire [4:0] ifid_rs2    = ifid_instr[24:20];
    wire [4:0] ifid_rd     = ifid_instr[11:7];
    wire [2:0] ifid_funct3 = ifid_instr[14:12];
    wire [6:0] id_opcode   = ifid_instr[6:0];

    // ---------------- ID ----------------
    wire        id_RegWEn, id_MemRW, id_ASel, id_BSel, id_BrUn, id_Branch, id_Jump, id_Jalr;
    wire [1:0]  id_WBSel;
    wire [2:0]  id_ImmSel;
    wire [3:0]  id_ALUSel;
    wire [31:0] id_imm;
    wire [31:0] rf_rs1_val, rf_rs2_val;

    control_unit u_ctrl (
        .instr  (ifid_instr),
        .RegWEn (id_RegWEn),
        .MemRW  (id_MemRW),
        .WBSel  (id_WBSel),
        .ImmSel (id_ImmSel),
        .ASel   (id_ASel),
        .BSel   (id_BSel),
        .ALUSel (id_ALUSel),
        .BrUn   (id_BrUn),
        .Branch (id_Branch),
        .Jump   (id_Jump),
        .Jalr   (id_Jalr)
    );

    immediate_generator u_imm (
        .instr   (ifid_instr),
        .imm_sel (id_ImmSel),
        .imm     (id_imm)
    );

    wire [31:0] wb_data;
    wire        wb_RegWEn;
    wire [4:0]  wb_rd;

    reg_file u_rf (
        .clk         (clk),
        .rst         (rst),
        .write_enable(wb_RegWEn),
        .rs1         (ifid_rs1),
        .rs2         (ifid_rs2),
        .rd          (wb_rd),
        .write_data  (wb_data),
        .rd1         (rf_rs1_val),
        .rd2         (rf_rs2_val)
    );

    // ---------------- Hazard detection ----------------
    wire       stall;
    wire       idex_is_load;
    wire [4:0] idex_rd_for_hazard;

    reg id_uses_rs1;
    reg id_uses_rs2;

    always @(*) begin
        id_uses_rs1 = 1'b0;
        id_uses_rs2 = 1'b0;

        case (id_opcode)
            7'b0110011: begin // R-type
                id_uses_rs1 = 1'b1;
                id_uses_rs2 = 1'b1;
            end

            7'b0010011: begin // I-type ALU
                id_uses_rs1 = 1'b1;
            end

            7'b0000011: begin // Loads
                id_uses_rs1 = 1'b1;
            end

            7'b0100011: begin // Stores
                id_uses_rs1 = 1'b1;
                id_uses_rs2 = 1'b1;
            end

            7'b1100011: begin // Branches
                id_uses_rs1 = 1'b1;
                id_uses_rs2 = 1'b1;
            end

            7'b1100111: begin // JALR
                id_uses_rs1 = 1'b1;
            end

            default: begin
                id_uses_rs1 = 1'b0;
                id_uses_rs2 = 1'b0;
            end
        endcase
    end

    // load-use hazard detection:
    // if instruction in ID/EX is a load, and IF/ID uses that rd as rs1/rs2, stall
    assign idex_is_load       = idex_RegWEn && (idex_WBSel == WB_MEM);
    assign idex_rd_for_hazard = idex_rd;

    hazard_unit u_hazard (
        .idex_is_load  (idex_is_load),
        .idex_rd       (idex_rd_for_hazard),
        .ifid_rs1      (ifid_rs1),
        .ifid_rs2      (ifid_rs2),
        .ifid_uses_rs1 (id_uses_rs1),
        .ifid_uses_rs2 (id_uses_rs2),
        .stall         (stall)
    );

    // ---------------- ID/EX ----------------
    wire [31:0] idex_pc, idex_pc4, idex_rs1_val, idex_rs2_val, idex_imm;
    wire [4:0]  idex_rs1, idex_rs2, idex_rd;
    wire [2:0]  idex_funct3;
    wire        idex_RegWEn, idex_MemRW, idex_ASel, idex_BSel, idex_BrUn, idex_Branch, idex_Jump, idex_Jalr;
    wire [1:0]  idex_WBSel;
    wire [3:0]  idex_ALUSel;

    wire idex_flush;

    id_ex_reg u_idex (
        .clk        (clk),
        .rst        (rst),
        .flush      (idex_flush),

        .pc_in      (ifid_pc),
        .pc4_in     (ifid_pc4),
        .rs1_val_in (rf_rs1_val),
        .rs2_val_in (rf_rs2_val),
        .imm_in     (id_imm),

        .rs1_in     (ifid_rs1),
        .rs2_in     (ifid_rs2),
        .rd_in      (ifid_rd),
        .funct3_in  (ifid_funct3),

        .RegWEn_in  (id_RegWEn),
        .MemRW_in   (id_MemRW),
        .WBSel_in   (id_WBSel),
        .ASel_in    (id_ASel),
        .BSel_in    (id_BSel),
        .ALUSel_in  (id_ALUSel),
        .BrUn_in    (id_BrUn),
        .Branch_in  (id_Branch),
        .Jump_in    (id_Jump),
        .Jalr_in    (id_Jalr),

        .pc_out     (idex_pc),
        .pc4_out    (idex_pc4),
        .rs1_val_out(idex_rs1_val),
        .rs2_val_out(idex_rs2_val),
        .imm_out    (idex_imm),

        .rs1_out    (idex_rs1),
        .rs2_out    (idex_rs2),
        .rd_out     (idex_rd),
        .funct3_out (idex_funct3),

        .RegWEn_out (idex_RegWEn),
        .MemRW_out  (idex_MemRW),
        .WBSel_out  (idex_WBSel),
        .ASel_out   (idex_ASel),
        .BSel_out   (idex_BSel),
        .ALUSel_out (idex_ALUSel),
        .BrUn_out   (idex_BrUn),
        .Branch_out (idex_Branch),
        .Jump_out   (idex_Jump),
        .Jalr_out   (idex_Jalr)
    );

    // ---------------- EX forwarding ----------------
    wire [1:0] forwardA, forwardB;

    wire       exmem_RegWEn_for_fwd;
    wire [4:0] exmem_rd_for_fwd;
    wire       memwb_RegWEn_for_fwd;
    wire [4:0] memwb_rd_for_fwd;

    forwarding_unit u_fwd (
        .exmem_regwrite (exmem_RegWEn_for_fwd),
        .exmem_rd       (exmem_rd_for_fwd),
        .memwb_regwrite (memwb_RegWEn_for_fwd),
        .memwb_rd       (memwb_rd_for_fwd),
        .idex_rs1       (idex_rs1),
        .idex_rs2       (idex_rs2),
        .forwardA       (forwardA),
        .forwardB       (forwardB)
    );

    wire [31:0] ex_srcA_raw =
        (forwardA == 2'b10) ? exmem_alu_result :
        (forwardA == 2'b01) ? wb_data :
                              idex_rs1_val;

    wire [31:0] ex_srcB_raw =
        (forwardB == 2'b10) ? exmem_alu_result :
        (forwardB == 2'b01) ? wb_data :
                              idex_rs2_val;

    // ---------------- EX ----------------
    wire ex_BrEq, ex_BrLT;

    branch_comparator u_bcmp (
        .a    (ex_srcA_raw),
        .b    (ex_srcB_raw),
        .BrUn (idex_BrUn),
        .BrEq (ex_BrEq),
        .BrLT (ex_BrLT)
    );

    reg ex_take_branch;
    always @(*) begin
        case (idex_funct3)
            3'b000: ex_take_branch =  ex_BrEq; // BEQ
            3'b001: ex_take_branch = ~ex_BrEq; // BNE
            3'b100: ex_take_branch =  ex_BrLT; // BLT
            3'b101: ex_take_branch = ~ex_BrLT; // BGE / BGEU depending on BrUn
            3'b110: ex_take_branch =  ex_BrLT; // BLTU
            3'b111: ex_take_branch = ~ex_BrLT; // BGEU
            default: ex_take_branch = 1'b0;
        endcase
    end

    wire [31:0] ex_alu_a = idex_ASel ? idex_pc  : ex_srcA_raw;
    wire [31:0] ex_alu_b = idex_BSel ? idex_imm : ex_srcB_raw;

    wire [31:0] ex_alu_result;
    wire        ex_zero, ex_lt_signed, ex_lt_unsigned;

    alu u_alu (
        .a          (ex_alu_a),
        .b          (ex_alu_b),
        .alu_sel    (idex_ALUSel),
        .y          (ex_alu_result),
        .zero       (ex_zero),
        .lt_signed  (ex_lt_signed),
        .lt_unsigned(ex_lt_unsigned)
    );

    wire        ex_pcsel  = (idex_Branch && ex_take_branch) || idex_Jump;
    wire [31:0] ex_target = idex_Jalr ? {ex_alu_result[31:1], 1'b0} : ex_alu_result;

    // ---------------- EX/MEM ----------------
    wire [31:0] exmem_pc4, exmem_alu_result, exmem_rs2_fwd;
    wire [4:0]  exmem_rd;
    wire [2:0]  exmem_funct3;
    wire        exmem_RegWEn, exmem_MemRW;
    wire [1:0]  exmem_WBSel;

    ex_mem_reg u_exmem (
        .clk           (clk),
        .rst           (rst),
        .pc4_in        (idex_pc4),
        .alu_result_in (ex_alu_result),
        .rs2_fwd_in    (ex_srcB_raw),
        .rd_in         (idex_rd),
        .funct3_in     (idex_funct3),
        .RegWEn_in     (idex_RegWEn),
        .MemRW_in      (idex_MemRW),
        .WBSel_in      (idex_WBSel),
        .pc4_out       (exmem_pc4),
        .alu_result_out(exmem_alu_result),
        .rs2_fwd_out   (exmem_rs2_fwd),
        .rd_out        (exmem_rd),
        .funct3_out    (exmem_funct3),
        .RegWEn_out    (exmem_RegWEn),
        .MemRW_out     (exmem_MemRW),
        .WBSel_out     (exmem_WBSel)
    );

    assign exmem_RegWEn_for_fwd = exmem_RegWEn;
    assign exmem_rd_for_fwd     = exmem_rd;

    // ---------------- MEM ----------------
    assign memrw      = exmem_MemRW;
    assign mem_addr   = exmem_alu_result;
    assign mem_wdata  = exmem_rs2_fwd;
    assign mem_funct3 = exmem_funct3;

    // ---------------- MEM/WB ----------------
    wire [31:0] memwb_pc4, memwb_alu_result, memwb_mem_rdata;
    wire [4:0]  memwb_rd;
    wire        memwb_RegWEn;
    wire [1:0]  memwb_WBSel;

    mem_wb_reg u_memwb (
        .clk           (clk),
        .rst           (rst),
        .pc4_in        (exmem_pc4),
        .alu_result_in (exmem_alu_result),
        .mem_rdata_in  (mem_rdata),
        .rd_in         (exmem_rd),
        .RegWEn_in     (exmem_RegWEn),
        .WBSel_in      (exmem_WBSel),
        .pc4_out       (memwb_pc4),
        .alu_result_out(memwb_alu_result),
        .mem_rdata_out (memwb_mem_rdata),
        .rd_out        (memwb_rd),
        .RegWEn_out    (memwb_RegWEn),
        .WBSel_out     (memwb_WBSel)
    );

    assign memwb_RegWEn_for_fwd = memwb_RegWEn;
    assign memwb_rd_for_fwd     = memwb_rd;

    // ---------------- WB ----------------
    assign wb_RegWEn = memwb_RegWEn;
    assign wb_rd     = memwb_rd;

    assign wb_data =
        (memwb_WBSel == WB_MEM) ? memwb_mem_rdata :
        (memwb_WBSel == WB_ALU) ? memwb_alu_result :
        (memwb_WBSel == WB_PC4) ? memwb_pc4 :
                                  32'b0;

    // ---------------- Global pipeline control ----------------
    assign pc_en      = ~stall;
    assign ifid_en    = ~stall;
    assign ifid_flush = ex_pcsel;
    assign idex_flush = stall | ex_pcsel;
    assign pc_next    = ex_pcsel ? ex_target : pc_plus4_if;

endmodule

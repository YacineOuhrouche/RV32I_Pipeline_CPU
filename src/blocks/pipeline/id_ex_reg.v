`timescale 1ns/1ps

module id_ex_reg (
    input  wire clk,
    input  wire rst,
    input  wire flush,

    input  wire [31:0] pc_in,
    input  wire [31:0] pc4_in,
    input  wire [31:0] rs1_val_in,
    input  wire [31:0] rs2_val_in,
    input  wire [31:0] imm_in,

    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,
    input  wire [2:0]  funct3_in,

    input  wire  RegWEn_in,
    input  wire  MemRW_in,
    input  wire [1:0]  WBSel_in,
    input  wire  ASel_in,
    input  wire  BSel_in,
    input  wire [3:0]  ALUSel_in,
    input  wire  BrUn_in,
    input  wire  Branch_in,
    input  wire  Jump_in,
    input  wire   Jalr_in,

    output reg  [31:0] pc_out,
    output reg  [31:0] pc4_out,
    output reg  [31:0] rs1_val_out,
    output reg  [31:0] rs2_val_out,
    output reg  [31:0] imm_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,

    output reg RegWEn_out,
    output reg   MemRW_out,
    output reg  [1:0]  WBSel_out,
    output reg ASel_out,
    output reg BSel_out,
    output reg  [3:0]  ALUSel_out,
    output reg BrUn_out,
    output reg Branch_out,
    output reg Jump_out,
    output reg Jalr_out
);

    always @(posedge clk) begin
        if (rst || flush) begin
            pc_out  <= 32'b0;
            pc4_out <= 32'b0;
            rs1_val_out <= 32'b0;
            rs2_val_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out  <= 5'b0;
            funct3_out   <= 3'b0;
            RegWEn_out   <= 1'b0;
            MemRW_out    <= 1'b0;
            WBSel_out    <= 2'b0;
            ASel_out     <= 1'b0;
            BSel_out     <= 1'b0;
            ALUSel_out   <= 4'b0;
            BrUn_out     <= 1'b0;
            Branch_out   <= 1'b0;
            Jump_out     <= 1'b0;
            Jalr_out     <= 1'b0;
            
        end else begin
            pc_out  <= pc_in;
            pc4_out  <= pc4_in;
            rs1_val_out <= rs1_val_in;
            rs2_val_out  <= rs2_val_in;
            imm_out <= imm_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            funct3_out <= funct3_in;
            RegWEn_out <= RegWEn_in;
            MemRW_out <= MemRW_in;
            WBSel_out <= WBSel_in;
            ASel_out <= ASel_in;
            BSel_out <= BSel_in;
            ALUSel_out <= ALUSel_in;
            BrUn_out <= BrUn_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
            Jalr_out <= Jalr_in;
        end
    end

endmodule

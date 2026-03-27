`timescale 1ns/1ps

module ex_mem_reg (
    input  wire  clk,
    input  wire   rst,

    input  wire [31:0] pc4_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_fwd_in,
    input wire [4:0]  rd_in,
    input  wire [2:0]  funct3_in,

    input  wire RegWEn_in,
    input wire MemRW_in,
    input  wire [1:0]  WBSel_in,

    output reg [31:0] pc4_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_fwd_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,

    output reg RegWEn_out,
    output reg MemRW_out,
    output reg [1:0] WBSel_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc4_out  <= 32'b0;
            alu_result_out <= 32'b0;
            rs2_fwd_out <= 32'b0;
            rd_out <= 5'b0;
            funct3_out <= 3'b0;
            RegWEn_out <= 1'b0;
            MemRW_out <= 1'b0;
            WBSel_out <= 2'b0;
        end else begin
            pc4_out <= pc4_in;
            alu_result_out <= alu_result_in;
            rs2_fwd_out <= rs2_fwd_in;
            rd_out <= rd_in;
            funct3_out <= funct3_in;
            RegWEn_out  <= RegWEn_in;
            MemRW_out <= MemRW_in;
            WBSel_out  <= WBSel_in;
        end
    end

endmodule

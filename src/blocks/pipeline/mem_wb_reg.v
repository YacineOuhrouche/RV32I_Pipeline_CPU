`timescale 1ns/1ps

module mem_wb_reg (
    input  wire   clk,
    input  wire rst,

    input  wire [31:0] pc4_in,
    input wire [31:0] alu_result_in,
    input  wire [31:0] mem_rdata_in,
    input  wire [4:0]  rd_in,

    input wire RegWEn_in,
    input  wire [1:0]  WBSel_in,

    output reg  [31:0] pc4_out,
    output reg [31:0] alu_result_out,
    output reg  [31:0] mem_rdata_out,
    output reg  [4:0]  rd_out,

    output reg  RegWEn_out,
    output reg  [1:0]  WBSel_out
);

    always @(posedge clk) begin
        if (rst) begin
            pc4_out  <= 32'b0;
            alu_result_out<= 32'b0;
            mem_rdata_out <= 32'b0;
            rd_out <= 5'b0;
            RegWEn_out <= 1'b0;
            WBSel_out <= 2'b0;
        end else begin
            pc4_out  <= pc4_in;
            alu_result_out <= alu_result_in;
            mem_rdata_out  <= mem_rdata_in;
            rd_out <= rd_in;
            RegWEn_out  <= RegWEn_in;
            WBSel_out <= WBSel_in;
        end
    end

endmodule

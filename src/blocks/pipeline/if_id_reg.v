`timescale 1ns/1ps

module if_id_reg (
    input  wire clk,
    input  wire rst,
    input  wire en,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] pc4_in,
    input wire [31:0] instr_in,
    
    output reg  [31:0] pc_out,
    output reg  [31:0] pc4_out,
    output reg  [31:0] instr_out
);

    always @(posedge clk) begin
        if (rst || flush) begin
            pc_out <= 32'b0;
            pc4_out <= 32'b0;
            instr_out <= 32'h00000013; // NOP
        end else if (en) begin
            pc_out  <= pc_in;
            pc4_out <= pc4_in;
            instr_out <= instr_in;
        end
    end

endmodule

`timescale 1ns/1ps

module forwarding_unit (
    input  wire exmem_regwrite,
    input  wire [4:0] exmem_rd,
    input wire  memwb_regwrite,
    input  wire [4:0] memwb_rd,
    input wire [4:0] idex_rs1,
    input  wire [4:0] idex_rs2,
    output reg  [1:0] forwardA,
    output reg  [1:0] forwardB
);

    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;

        // Forward for rs1
        if (exmem_regwrite && (exmem_rd != 5'd0) && (exmem_rd == idex_rs1))
            forwardA = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 5'd0) && (memwb_rd == idex_rs1))
            forwardA = 2'b01;

        // Forward for rs2
        if (exmem_regwrite && (exmem_rd != 5'd0) && (exmem_rd == idex_rs2))
            forwardB = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 5'd0) && (memwb_rd == idex_rs2))
            forwardB = 2'b01;
    end

endmodule

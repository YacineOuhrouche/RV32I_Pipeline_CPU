`timescale 1ns/1ps

module pc(
    input  wire  clk,
    input  wire  rst,
    input  wire  en,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc_current
);

    always @(posedge clk) begin
        if (rst)
            pc_current <= 32'b0;
        else if (en)
            pc_current <= next_pc;
    end

endmodule

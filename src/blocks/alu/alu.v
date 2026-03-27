`timescale 1ns/1ps


module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_sel,     // from Control Unit
    output reg  [31:0] y,
    output wire  zero,         // high if y == 0
    output wire  lt_signed,
    output wire  lt_unsigned
);

    assign lt_signed  = ($signed(a) < $signed(b));
    assign lt_unsigned = (a < b);
    assign zero  = (y == 32'b0);

    wire [4:0] shamt = b[4:0];

    
    always @(*) begin
        y = 32'b0;
        case (alu_sel)
            4'd0: y = a + b; 
            4'd1: y = a - b; 
            4'd2: y = a & b; 
            4'd3: y = a | b; 
            4'd4: y = a ^ b; 
            4'd5: y = a << shamt; 
            4'd6: y = a >> shamt; 
            4'd7: y = $signed(a) >>> shamt; 
            4'd8: y = {31'b0, lt_signed};  
            4'd9: y = {31'b0, lt_unsigned}; 
            4'd10: y = b;  
            default: y = 32'b0;
        endcase
    end

endmodule


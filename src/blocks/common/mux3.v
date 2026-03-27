`timescale 1ns/1ps

module mux3 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [1:0]  sel,
    output wire [31:0] y
);

assign y = (sel == 2'b00) ? a :
           (sel == 2'b01) ? b :
                             c;

endmodule

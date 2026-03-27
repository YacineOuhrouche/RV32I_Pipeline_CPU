`timescale 1ns/1ps

module branch_comparator(
    input wire [31:0] a, 
    input wire [31:0] b, 
    input wire BrUn, 

    output wire BrEq, 
    output wire BrLT
);

    assign BrEq = ( a==b);

    assign BrLT = BrUn ? (a < b) : ($signed(a) < $signed(b));
endmodule 

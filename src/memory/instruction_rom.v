`timescale 1ns/1ps

module instruction_rom #(
    parameter integer MEM_DEPTH = 1024,
    parameter MEM_FILE  = "programs/normal.hex"
)(
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    localparam integer ADDR_W = $clog2(MEM_DEPTH);

    reg [31:0] memory [0:MEM_DEPTH-1];
    wire [ADDR_W-1:0] word_index;

    assign word_index = addr[ADDR_W+1:2];

    initial begin
        $readmemh(MEM_FILE, memory);
    end

    assign instr = (addr < MEM_DEPTH*4) ? memory[word_index] : 32'h00000013;

endmodule

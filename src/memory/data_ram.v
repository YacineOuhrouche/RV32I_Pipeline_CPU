`timescale 1ns/1ps

/* verilator lint_off UNUSEDSIGNAL */
module data_ram #(
    parameter integer MEM_BYTES = 4096,
    parameter MEM_FILE = ""
)(
    input wire clk,
    input wire memrw,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire [2:0] funct3,
    output wire [31:0] rdata
);
/* verilator lint_on UNUSEDSIGNAL */

    localparam integer ADDR_W = $clog2(MEM_BYTES);

    reg [7:0] mem [0:MEM_BYTES-1];
    integer i;

    wire [ADDR_W-1:0] a0;
    wire [ADDR_W-1:0] a1;
    wire [ADDR_W-1:0] a2;
    wire [ADDR_W-1:0] a3;

    wire [7:0] b0;
    wire [7:0] b1;
    wire [7:0] b2;
    wire [7:0] b3;

    wire [15:0] half;
    wire [31:0] word;

    reg [31:0] load_val;

    initial begin
        if (MEM_FILE != "") begin
            $readmemh(MEM_FILE, mem);
        end
        else begin
            for (i = 0; i < MEM_BYTES; i = i + 1)
                mem[i] = 8'h00;
        end
    end

    assign a0 = addr[ADDR_W-1:0];
    assign a1 = a0 + {{(ADDR_W-1){1'b0}}, 1'b1};
    assign a2 = a0 + {{(ADDR_W-2){1'b0}}, 2'd2};
    assign a3 = a0 + {{(ADDR_W-2){1'b0}}, 2'd3};

    assign b0 = mem[a0];
    assign b1 = mem[a1];
    assign b2 = mem[a2];
    assign b3 = mem[a3];

    assign half = {b1, b0};
    assign word = {b3, b2, b1, b0};

    always @(*) begin
        case (funct3)
            3'b000: load_val = {{24{b0[7]}}, b0};
            3'b001: load_val = {{16{half[15]}}, half};
            3'b010: load_val = word;
            3'b100: load_val = {24'b0, b0};
            3'b101: load_val = {16'b0, half};
            default: load_val = word;
        endcase
    end

    assign rdata = load_val;

    always @(posedge clk) begin
        if (memrw) begin
            case (funct3)
                3'b000: mem[a0] <= wdata[7:0];
                3'b001: begin
                    mem[a0] <= wdata[7:0];
                    mem[a1] <= wdata[15:8];
                end
                3'b010: begin
                    mem[a0] <= wdata[7:0];
                    mem[a1] <= wdata[15:8];
                    mem[a2] <= wdata[23:16];
                    mem[a3] <= wdata[31:24];
                end
                default: begin
                end
            endcase
        end
    end

endmodule

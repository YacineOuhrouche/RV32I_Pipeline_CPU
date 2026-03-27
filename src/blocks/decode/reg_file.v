`timescale 1ns/1ps


module reg_file(
    input  wire clk,
    input  wire rst,
    input  wire write_enable,
    input  wire [4:0] rs1,
    input  wire [4:0] rs2,
    input  wire [4:0] rd,
    input  wire [31:0] write_data,

    output wire [31:0] rd1,
    output wire [31:0] rd2
);

    reg [31:0] regs [0:31];
    integer i;

    // async read
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            if (write_enable && (rd != 5'd0))
                regs[rd] <= write_data;

            // hardwire x0 to 0
            regs[0] <= 32'b0;
        end
    end

endmodule


`timescale 1ns/1ps

module tb_mux3;

logic [31:0] a;
logic [31:0] b;
logic [31:0] c;
logic [1:0]  sel;

wire [31:0] y;

integer errors;

mux3 dut (
    .a(a),
    .b(b),
    .c(c),
    .sel(sel),
    .y(y)
);

mux3_sva assertions_inst (
    .a(a),
    .b(b),
    .c(c),
    .sel(sel),
    .y(y)
);


task check(input [31:0] expected);
begin

    if (y !== expected) begin
        $display("FAIL | sel=%b a=%h b=%h c=%h y=%h expected=%h",
                 sel,a,b,c,y,expected);
        errors++;
    end

    else
        $display("PASS | sel=%b y=%h",sel,y);

end
endtask


initial begin

$dumpfile("sim/sim_blocks/muxes/mux3.vcd");
$dumpvars(0,tb_mux3);

$display("Starting mux3 TB");

errors = 0;

a = 32'hAAAAAAAA;
b = 32'h55555555;
c = 32'hDEADBEEF;

sel = 2'b00;
#1;
check(a);

sel = 2'b01;
#1;
check(b);

sel = 2'b10;
#1;
check(c);

sel = 2'b11;
#1;
check(c);


a = 32'h12345678;
b = 32'hABCDEF01;
c = 32'hCAFEBABE;

sel = 2'b00;
#1;
check(a);

sel = 2'b01;
#1;
check(b);

sel = 2'b10;
#1;
check(c);


if(errors == 0)
    $display("All tests PASSED!");
else
    $display("%0d tests FAILED",errors);

$finish;

end

endmodule

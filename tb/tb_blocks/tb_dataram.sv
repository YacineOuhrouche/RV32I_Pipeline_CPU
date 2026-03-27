`timescale 1ns/1ps

module tb_dataram;

    localparam MEM_BYTES = 64;

    reg clk;
    reg memrw;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg [2:0] funct3;
    wire [31:0] rdata;

    integer errors;

    data_ram #(
        .MEM_BYTES(MEM_BYTES),
        .MEM_FILE("")
    ) dut (
        .clk(clk),
        .memrw(memrw),
        .addr(addr),
        .wdata(wdata),
        .funct3(funct3),
        .rdata(rdata)
    );

    data_ram_sva assertions_inst (
        .clk(clk),
        .memrw(memrw),
        .addr(addr),
        .funct3(funct3),
        .rdata(rdata)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task check;
        input [31:0] actual;
        input [31:0] expected;
        input [255:0] msg;
        begin
            if (actual !== expected) begin
                $error("TB FAIL: %0s | actual=%h expected=%h time=%0t", msg, actual, expected, $time);
                errors = errors + 1;
            end
            else begin
                $display("TB PASS: %0s | value=%h time=%0t", msg, actual, $time);
            end
        end
    endtask


    initial begin
        $dumpfile("sim/sim_blocks/ram/data_ram.vcd");
        $dumpvars(0, tb_dataram);

        errors = 0;

        memrw = 0;
        addr = 0;
        wdata = 0;
        funct3 = 3'b010;

        $display("Starting data_ram TB");


        // =========================
        // SW test
        // =========================

        @(negedge clk);
addr = 32'd8;
wdata = 32'hA1B2C3D4;
funct3 = 3'b010;
memrw = 1;

        @(posedge clk);
        #1;
memrw = 0;

        addr = 32'd8;
        funct3 = 3'b010;
        #1;
        check(rdata, 32'hA1B2C3D4, "LW after SW");

        addr = 32'd8;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h000000D4, "LBU byte0");

        addr = 32'd9;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h000000C3, "LBU byte1");

        addr = 32'd10;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h000000B2, "LBU byte2");

        addr = 32'd11;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h000000A1, "LBU byte3");



        // Signed loads

        addr = 32'd8;
        funct3 = 3'b000;
        #1;
        check(rdata, 32'hFFFFFFD4, "LB signed");

        addr = 32'd8;
        funct3 = 3'b001;
        #1;
        check(rdata, 32'hFFFFC3D4, "LH signed");

        addr = 32'd8;
        funct3 = 3'b101;
        #1;
        check(rdata, 32'h0000C3D4, "LHU unsigned");


        // =========================
        // SH test
    

        @(negedge clk);
        addr = 32'd20;
        wdata = 32'h00001122;
        funct3 = 3'b001;
        memrw = 1;

        @(posedge clk);
        #1;
memrw = 0;

        addr = 32'd20;
        funct3 = 3'b101;
        #1;
        check(rdata, 32'h00001122, "LHU after SH");


      
        // SB tes

        @(negedge clk);
        addr = 32'd30;
        wdata = 32'h00000080;
        funct3 = 3'b000;
        memrw = 1;

        @(posedge clk);
        #1;
memrw = 0;

        addr = 32'd30;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h00000080, "LBU after SB");

        addr = 32'd30;
        funct3 = 3'b000;
        #1;
        check(rdata, 32'hFFFFFF80, "LB after SB");


    
        // memrw disable test


        addr = 32'd40;
        funct3 = 3'b100;
        #1;
        check(rdata, 32'h00000000, "Initial value");

        @(negedge clk);
        addr = 32'd40;
        wdata = 32'hDEADBEEF;
        funct3 = 3'b010;
        memrw = 0;

        @(posedge clk);
        #1;

        addr = 32'd40;
        funct3 = 3'b010;
        #1;
        check(rdata, 32'h00000000, "Write disabled");


        if (errors == 0)
            $display("All tests PASSED");
        else
            $display("Tests FAILED errors=%0d", errors);

        $finish;

    end

endmodule

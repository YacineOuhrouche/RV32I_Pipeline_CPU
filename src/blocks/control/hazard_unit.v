module hazard_unit (
    input  wire idex_is_load,
    input  wire [4:0] idex_rd,

    input  wire [4:0] ifid_rs1,
    input wire [4:0] ifid_rs2,
    input wire  ifid_uses_rs1,
    input  wire  ifid_uses_rs2,

    output wire   stall
);

    assign stall =
        idex_is_load &&
        (idex_rd != 5'd0) &&
        (
            (ifid_uses_rs1 && (idex_rd == ifid_rs1)) ||
            (ifid_uses_rs2 && (idex_rd == ifid_rs2))
        );

endmodule

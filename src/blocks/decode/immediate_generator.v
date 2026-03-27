`timescale 1ns/1ps
/* verilator lint_off UNUSEDSIGNAL */
module immediate_generator(
    input  logic [31:0] instr,
    input  logic [2:0]  imm_sel,
    output logic [31:0] imm
);

    always @(*) begin
        case (imm_sel)

            // I  immediate
            3'b000: imm = {{20{instr[31]}}, instr[31:20]};

            // S immediate
            3'b001: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B immediate
            3'b010: imm = {{19{instr[31]}}, instr[31], instr[7],
                           instr[30:25], instr[11:8], 1'b0};

            // U type immediate
            3'b011: imm = {instr[31:12], 12'b0};

            // J- immediate
            3'b100: imm = {{11{instr[31]}}, instr[31],
                           instr[19:12], instr[20],
                           instr[30:21], 1'b0};

            default: imm = 32'b0;
        endcase
    end

endmodule
/* verilator lint_on UNUSEDSIGNAL */

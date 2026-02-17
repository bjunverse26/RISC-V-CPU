module imm_gen(
    input [31:0]        instr,
    input [2:0]         imm_sel,
    output [31:0]       ext_imm
);

localparam [2:0] IMM_I    = 3'd0;
localparam [2:0] IMM_S    = 3'd1;
localparam [2:0] IMM_B    = 3'd2;
localparam [2:0] IMM_U    = 3'd3;
localparam [2:0] IMM_J    = 3'd4;
localparam [2:0] IMM_NONE = 3'd7;

wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
wire [31:0] imm_u = {instr[31:12], 12'b0};
wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

assign ext_imm =
    (imm_sel == IMM_I)    ? imm_i :
    (imm_sel == IMM_S)    ? imm_s :
    (imm_sel == IMM_B)    ? imm_b :
    (imm_sel == IMM_U)    ? imm_u :
    (imm_sel == IMM_J)    ? imm_j :
    (imm_sel == IMM_NONE) ? 32'b0 :
                            32'b0;

endmodule

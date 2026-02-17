module Control_unit(
    input [31:0]            instr,
    output reg              reg_write,
    output reg              alu_mux_src1,
    output reg              alu_mux_src2,
    output reg [3:0]        alu_ctrl,
    output reg              branch_en,
    output reg [2:0]        branch_type,
    output reg [2:0]        imm_sel,
    output reg [1:0]        wb_mux_sel,
    output reg              data_mem_write,
    output reg              data_mem_read,
    output reg              jump_en,
    output reg              jal_mux_sel,
    output reg [2:0]        load_type,
    output reg [1:0]        store_type
);

wire [6:0] opcode = instr[6:0];
wire [6:0] func7  = instr[31:25];
wire [2:0] func3  = instr[14:12];

localparam [6:0] OPCODE_LUI    = 7'b0110111;
localparam [6:0] OPCODE_AUIPC  = 7'b0010111;
localparam [6:0] OPCODE_JAL    = 7'b1101111;
localparam [6:0] OPCODE_JALR   = 7'b1100111;
localparam [6:0] OPCODE_BRANCH = 7'b1100011;
localparam [6:0] OPCODE_LOAD   = 7'b0000011;
localparam [6:0] OPCODE_STORE  = 7'b0100011;
localparam [6:0] OPCODE_OP_IMM = 7'b0010011;
localparam [6:0] OPCODE_OP     = 7'b0110011;

localparam [3:0] ALU_ADD    = 4'd0;
localparam [3:0] ALU_SUB    = 4'd1;
localparam [3:0] ALU_SLL    = 4'd2;
localparam [3:0] ALU_SLT    = 4'd3;
localparam [3:0] ALU_SLTU   = 4'd4;
localparam [3:0] ALU_XOR    = 4'd5;
localparam [3:0] ALU_SRL    = 4'd6;
localparam [3:0] ALU_SRA    = 4'd7;
localparam [3:0] ALU_OR     = 4'd8;
localparam [3:0] ALU_AND    = 4'd9;
localparam [3:0] ALU_PASS_B = 4'd10;

localparam [2:0] IMM_I    = 3'd0;
localparam [2:0] IMM_S    = 3'd1;
localparam [2:0] IMM_B    = 3'd2;
localparam [2:0] IMM_U    = 3'd3;
localparam [2:0] IMM_J    = 3'd4;
localparam [2:0] IMM_NONE = 3'd7;

localparam [1:0] WB_ALU = 2'd0;
localparam [1:0] WB_MEM = 2'd1;
localparam [1:0] WB_PC4 = 2'd2;

localparam [1:0] STORE_B = 2'd0;
localparam [1:0] STORE_H = 2'd1;
localparam [1:0] STORE_W = 2'd2;

localparam [2:0] BR_BEQ  = 3'b000;
localparam [2:0] BR_BNE  = 3'b001;
localparam [2:0] BR_BLT  = 3'b100;
localparam [2:0] BR_BGE  = 3'b101;
localparam [2:0] BR_BLTU = 3'b110;
localparam [2:0] BR_BGEU = 3'b111;

localparam [2:0] LOAD_B  = 3'b000;
localparam [2:0] LOAD_H  = 3'b001;
localparam [2:0] LOAD_W  = 3'b010;
localparam [2:0] LOAD_BU = 3'b100;
localparam [2:0] LOAD_HU = 3'b101;

always @(*) begin
    reg_write       = 1'b0;
    alu_mux_src1    = 1'b0;
    alu_mux_src2    = 1'b0;
    alu_ctrl        = ALU_ADD;
    branch_en       = 1'b0;
    branch_type     = BR_BEQ;
    imm_sel         = IMM_NONE;
    wb_mux_sel      = WB_ALU;
    data_mem_write  = 1'b0;
    data_mem_read   = 1'b0;
    jump_en         = 1'b0;
    jal_mux_sel     = 1'b0;
    load_type       = LOAD_W;
    store_type      = STORE_W;

    case (opcode)
        OPCODE_OP: begin
            reg_write    = 1'b1;
            wb_mux_sel   = WB_ALU;
            alu_mux_src1 = 1'b0;
            alu_mux_src2 = 1'b0;
            case (func3)
                3'b000: alu_ctrl = (func7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                3'b001: alu_ctrl = ALU_SLL;
                3'b010: alu_ctrl = ALU_SLT;
                3'b011: alu_ctrl = ALU_SLTU;
                3'b100: alu_ctrl = ALU_XOR;
                3'b101: alu_ctrl = (func7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                3'b110: alu_ctrl = ALU_OR;
                3'b111: alu_ctrl = ALU_AND;
                default: alu_ctrl = ALU_ADD;
            endcase
        end

        OPCODE_OP_IMM: begin
            reg_write    = 1'b1;
            wb_mux_sel   = WB_ALU;
            imm_sel      = IMM_I;
            alu_mux_src1 = 1'b0;
            alu_mux_src2 = 1'b1;
            case (func3)
                3'b000: alu_ctrl = ALU_ADD;
                3'b010: alu_ctrl = ALU_SLT;
                3'b011: alu_ctrl = ALU_SLTU;
                3'b100: alu_ctrl = ALU_XOR;
                3'b110: alu_ctrl = ALU_OR;
                3'b111: alu_ctrl = ALU_AND;
                3'b001: alu_ctrl = (func7 == 7'b0000000) ? ALU_SLL : ALU_ADD;
                3'b101: alu_ctrl = (func7 == 7'b0000000) ? ALU_SRL :
                                   (func7 == 7'b0100000) ? ALU_SRA : ALU_ADD;
                default: alu_ctrl = ALU_ADD;
            endcase
        end

        OPCODE_LOAD: begin
            reg_write      = 1'b1;
            imm_sel        = IMM_I;
            wb_mux_sel     = WB_MEM;
            alu_mux_src1   = 1'b0;
            alu_mux_src2   = 1'b1;
            alu_ctrl       = ALU_ADD;
            data_mem_read  = 1'b1;
            load_type      = func3;
        end

        OPCODE_STORE: begin
            imm_sel         = IMM_S;
            alu_mux_src1    = 1'b0;
            alu_mux_src2    = 1'b1;
            alu_ctrl        = ALU_ADD;
            data_mem_write  = 1'b1;
            case (func3)
                3'b000: store_type = STORE_B;
                3'b001: store_type = STORE_H;
                default: store_type = STORE_W;
            endcase
        end

        OPCODE_BRANCH: begin
            imm_sel      = IMM_B;
            branch_en    = 1'b1;
            branch_type  = func3;
            alu_mux_src1 = 1'b0;
            alu_mux_src2 = 1'b0;
            alu_ctrl     = ALU_SUB;
        end

        OPCODE_JAL: begin
            reg_write    = 1'b1;
            jump_en      = 1'b1;
            jal_mux_sel  = 1'b0;
            imm_sel      = IMM_J;
            wb_mux_sel   = WB_PC4;
        end

        OPCODE_JALR: begin
            reg_write    = 1'b1;
            jump_en      = 1'b1;
            jal_mux_sel  = 1'b1;
            imm_sel      = IMM_I;
            wb_mux_sel   = WB_PC4;
        end

        OPCODE_AUIPC: begin
            reg_write    = 1'b1;
            imm_sel      = IMM_U;
            wb_mux_sel   = WB_ALU;
            alu_mux_src1 = 1'b1;
            alu_mux_src2 = 1'b1;
            alu_ctrl     = ALU_ADD;
        end

        OPCODE_LUI: begin
            reg_write    = 1'b1;
            imm_sel      = IMM_U;
            wb_mux_sel   = WB_ALU;
            alu_mux_src1 = 1'b0;
            alu_mux_src2 = 1'b1;
            alu_ctrl     = ALU_PASS_B;
        end

        default: begin
        end
    endcase
end

endmodule

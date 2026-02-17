module Data_Path(
    input               clk,
    input               reset_n,
    output [31:0]       debug_pc,
    output [31:0]       debug_instr
);

wire [31:0] current_pc;
wire [31:0] next_pc;
wire [31:0] pc_plus4;
wire [31:0] instr;

wire              reg_write;
wire              alu_mux_src1;
wire              alu_mux_src2;
wire [3:0]        alu_ctrl;
wire              branch_en;
wire [2:0]        branch_type;
wire [2:0]        imm_sel;
wire [1:0]        wb_mux_sel;
wire              data_mem_write;
wire              data_mem_read;
wire              jump_en;
wire              jal_mux_sel;
wire [2:0]        load_type;
wire [1:0]        store_type;

wire [4:0] rs1_addr = instr[19:15];
wire [4:0] rs2_addr = instr[24:20];
wire [4:0] rd_addr  = instr[11:7];

wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] ext_imm;

wire [31:0] alu_src_a;
wire [31:0] alu_src_b;
wire [31:0] alu_result;
wire        alu_flag;

wire [31:0] data_mem_out;
wire [31:0] wb_data;

wire        branch_taken;
wire [31:0] branch_target;
wire [31:0] jal_target;

assign pc_plus4      = current_pc + 32'd4;
assign alu_src_a     = alu_mux_src1 ? current_pc : rs1_data;
assign alu_src_b     = alu_mux_src2 ? ext_imm    : rs2_data;
assign branch_taken  = branch_en & alu_flag;
assign branch_target = current_pc + ext_imm;
assign jal_target    = jal_mux_sel ? ((rs1_data + ext_imm) & 32'hFFFFFFFE)
                                   : (current_pc + ext_imm);

assign wb_data = (wb_mux_sel == 2'd0) ? alu_result :
                 (wb_mux_sel == 2'd1) ? data_mem_out :
                 (wb_mux_sel == 2'd2) ? pc_plus4 :
                                        32'd0;

assign next_pc = jump_en      ? jal_target :
                 branch_taken ? branch_target :
                                pc_plus4;

assign debug_pc    = current_pc;
assign debug_instr = instr;

pc u_pc (
    .clk(clk),
    .reset_n(reset_n),
    .next_pc(next_pc),
    .current_pc(current_pc)
);

Instruction_Memory u_imem (
    .instr_addr(current_pc),
    .instr(instr)
);

Control_unit u_ctrl (
    .instr(instr),
    .reg_write(reg_write),
    .alu_mux_src1(alu_mux_src1),
    .alu_mux_src2(alu_mux_src2),
    .alu_ctrl(alu_ctrl),
    .branch_en(branch_en),
    .branch_type(branch_type),
    .imm_sel(imm_sel),
    .wb_mux_sel(wb_mux_sel),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .jump_en(jump_en),
    .jal_mux_sel(jal_mux_sel),
    .load_type(load_type),
    .store_type(store_type)
);

register_file u_regfile (
    .clk(clk),
    .reset_n(reset_n),
    .reg_out_addr1(rs1_addr),
    .reg_out_addr2(rs2_addr),
    .reg_in_addr(rd_addr),
    .reg_write(reg_write),
    .reg_data_in(wb_data),
    .reg_data_out1(rs1_data),
    .reg_data_out2(rs2_data)
);

imm_gen u_imm_gen (
    .instr(instr),
    .imm_sel(imm_sel),
    .ext_imm(ext_imm)
);

alu u_alu (
    .a(alu_src_a),
    .b(alu_src_b),
    .branch_type(branch_type),
    .alu_ctrl(alu_ctrl),
    .alu_result(alu_result),
    .alu_flag(alu_flag)
);

Data_Memory u_dmem (
    .clk(clk),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .data_mem_addr(alu_result),
    .store_type(store_type),
    .load_type(load_type),
    .write_data(rs2_data),
    .read_data(data_mem_out)
);

endmodule

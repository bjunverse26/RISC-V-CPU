module RV32I_Core(
    input               clk,
    input               reset_n,
    input [31:0]        instr,
    input [31:0]        read_data,
    output [31:0]       instr_addr,
    output              data_mem_write,
    output              data_mem_read,
    output [31:0]       data_mem_addr,
    output [1:0]        store_type,
    output [2:0]        load_type,
    output [31:0]       write_data
);

wire              reg_write;
wire              alu_mux_src1;
wire              alu_mux_src2;
wire [3:0]        alu_ctrl;
wire              branch_en;
wire [2:0]        branch_type;
wire [2:0]        imm_sel;
wire [1:0]        wb_mux_sel;
wire              jump_en;
wire              jal_mux_sel;

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

Data_Path u_datapath (
    .clk(clk),
    .reset_n(reset_n),
    .instr(instr),
    .read_data(read_data),
    .reg_write(reg_write),
    .alu_mux_src1(alu_mux_src1),
    .alu_mux_src2(alu_mux_src2),
    .alu_ctrl(alu_ctrl),
    .branch_en(branch_en),
    .branch_type(branch_type),
    .imm_sel(imm_sel),
    .wb_mux_sel(wb_mux_sel),
    .jump_en(jump_en),
    .jal_mux_sel(jal_mux_sel),
    .instr_addr(instr_addr),
    .data_mem_addr(data_mem_addr),
    .write_data(write_data)
);

endmodule
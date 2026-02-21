module RV32I_Top(
    input clk,
    input reset_btn,
    output [3:0] led
);

wire reset_n;

wire [31:0] instr;
wire [31:0] read_data;
wire [31:0] instr_addr;
wire        data_mem_write;
wire        data_mem_read;
wire [31:0] data_mem_addr;
wire [1:0]  store_type;
wire [2:0]  load_type;
wire [31:0] write_data;

assign reset_n = ~reset_btn;
assign led = instr_addr[5:2];

RV32I_Core u_core (
    .clk(clk),
    .reset_n(reset_n),
    .instr(instr),
    .read_data(read_data),
    .instr_addr(instr_addr),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .data_mem_addr(data_mem_addr),
    .store_type(store_type),
    .load_type(load_type),
    .write_data(write_data)
);

Instruction_Memory #(
    .MEM_INIT_FILE("program.hex")
) u_imem (
    .instr_addr(instr_addr),
    .instr(instr)
);

Data_Memory u_dmem (
    .clk(clk),
    .data_mem_write(data_mem_write),
    .data_mem_read(data_mem_read),
    .data_mem_addr(data_mem_addr),
    .store_type(store_type),
    .load_type(load_type),
    .write_data(write_data),
    .read_data(read_data)
);

endmodule
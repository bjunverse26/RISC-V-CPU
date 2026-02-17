module Data_Memory(
    input               clk,
    input               data_mem_write,
    input               data_mem_read,
    input [31:0]        data_mem_addr,
    input [1:0]         store_type,
    input [2:0]         load_type,
    input [31:0]        write_data,
    output [31:0]       read_data
);

localparam integer MEM_WORDS = 256;
localparam integer ADDR_W    = 8;

reg [31:0] ram[0:MEM_WORDS-1];
integer i;

wire [ADDR_W-1:0] word_addr = data_mem_addr[ADDR_W+1:2];
wire [31:0] mem_wdata;
wire [3:0]  mem_wstrb;
wire [31:0] mem_rword;
wire [31:0] load_data_int;

store_gen u_store_gen (
    .store_data(write_data),
    .addr(data_mem_addr),
    .store_type(store_type),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb)
);

load_gen u_load_gen (
    .mem_rdata(mem_rword),
    .addr(data_mem_addr),
    .load_type(load_type),
    .load_data(load_data_int)
);

initial begin
    for (i = 0; i < MEM_WORDS; i = i + 1)
        ram[i] = 32'd0;
end

always @(posedge clk) begin
    if (data_mem_write) begin
        if (mem_wstrb[0]) ram[word_addr][7:0]   <= mem_wdata[7:0];
        if (mem_wstrb[1]) ram[word_addr][15:8]  <= mem_wdata[15:8];
        if (mem_wstrb[2]) ram[word_addr][23:16] <= mem_wdata[23:16];
        if (mem_wstrb[3]) ram[word_addr][31:24] <= mem_wdata[31:24];
    end
end

assign mem_rword = ram[word_addr];
assign read_data = data_mem_read ? load_data_int : 32'd0;

endmodule

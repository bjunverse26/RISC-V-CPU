module register_file(
    input               clk,
    input               reset_n,
    input [4:0]         reg_out_addr1,
    input [4:0]         reg_out_addr2,
    input [4:0]         reg_in_addr,
    input               reg_write,
    input [31:0]        reg_data_in,
    output [31:0]       reg_data_out1,
    output [31:0]       reg_data_out2
);

reg [31:0] register[31:0];
integer i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (i = 0; i < 32; i = i + 1)
            register[i] <= 32'd0;
    end else if (reg_write && (reg_in_addr[4:0] != 5'd0)) begin
        register[reg_in_addr[4:0]] <= reg_data_in;
    end
end

assign reg_data_out1 = (reg_out_addr1[4:0] == 5'd0) ? 32'd0 : register[reg_out_addr1[4:0]];
assign reg_data_out2 = (reg_out_addr2[4:0] == 5'd0) ? 32'd0 : register[reg_out_addr2[4:0]];

endmodule

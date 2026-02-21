module pc(
    input               clk,
    input               reset_n,
    input [31:0]        next_pc,
    output [31:0]       current_pc
);

reg [31:0] pc_reg;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        pc_reg <= 32'b0;
    else
        pc_reg <= next_pc;
end

assign current_pc = pc_reg;

endmodule
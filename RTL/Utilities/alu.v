module alu(
    input [31:0]        a,
    input [31:0]        b,
    input [2:0]         branch_type,
    input [3:0]         alu_ctrl,
    output reg [31:0]   alu_result,
    output reg          alu_flag
);

wire eq_flag    = (a == b);
wire slt_flag   = ($signed(a) < $signed(b));
wire sltu_flag  = (a < b);

always @(*) begin
    case (alu_ctrl)
        4'd0:  alu_result = a + b;
        4'd1:  alu_result = a - b;
        4'd2:  alu_result = a << b[4:0];
        4'd3:  alu_result = {31'd0, slt_flag};
        4'd4:  alu_result = {31'd0, sltu_flag};
        4'd5:  alu_result = a ^ b;
        4'd6:  alu_result = a >> b[4:0];
        4'd7:  alu_result = $signed(a) >>> b[4:0];
        4'd8:  alu_result = a | b;
        4'd9:  alu_result = a & b;
        4'd10: alu_result = b;
        default: alu_result = 32'd0;
    endcase
end

always @(*) begin
    case (branch_type)
        3'b000: alu_flag = eq_flag;
        3'b001: alu_flag = ~eq_flag;
        3'b100: alu_flag = slt_flag;
        3'b101: alu_flag = ~slt_flag;
        3'b110: alu_flag = sltu_flag;
        3'b111: alu_flag = ~sltu_flag;
        default: alu_flag = 1'b0;
    endcase
end


endmodule
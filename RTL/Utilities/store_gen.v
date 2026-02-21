module store_gen(
    input [31:0]        store_data,
    input [31:0]        addr,
    input [1:0]         store_type,
    output reg [31:0]   mem_wdata,
    output reg [3:0]    mem_wstrb
);

localparam [1:0] STORE_B = 2'd0;
localparam [1:0] STORE_H = 2'd1;
localparam [1:0] STORE_W = 2'd2;

always @(*) begin
    mem_wdata = 32'd0;
    mem_wstrb = 4'b0000;

    case (store_type)
        STORE_B: begin
            case (addr[1:0])
                2'b00: begin
                    mem_wdata = {24'd0, store_data[7:0]};
                    mem_wstrb = 4'b0001;
                end
                2'b01: begin
                    mem_wdata = {16'd0, store_data[7:0], 8'd0};
                    mem_wstrb = 4'b0010;
                end
                2'b10: begin
                    mem_wdata = {8'd0, store_data[7:0], 16'd0};
                    mem_wstrb = 4'b0100;
                end
                default: begin
                    mem_wdata = {store_data[7:0], 24'd0};
                    mem_wstrb = 4'b1000;
                end
            endcase
        end

        STORE_H: begin
            if (addr[1]) begin
                mem_wdata = {store_data[15:0], 16'd0};
                mem_wstrb = 4'b1100;
            end else begin
                mem_wdata = {16'd0, store_data[15:0]};
                mem_wstrb = 4'b0011;
            end
        end

        STORE_W: begin
            mem_wdata = store_data;
            mem_wstrb = 4'b1111;
        end

        default: begin
            mem_wdata = 32'd0;
            mem_wstrb = 4'b0000;
        end
    endcase
end

endmodule
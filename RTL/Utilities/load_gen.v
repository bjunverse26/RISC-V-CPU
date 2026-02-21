module load_gen(
    input [31:0]        mem_rdata,
    input [31:0]        addr,
    input [2:0]         load_type,
    output reg [31:0]   load_data
);

localparam [2:0] LOAD_B  = 3'b000;
localparam [2:0] LOAD_H  = 3'b001;
localparam [2:0] LOAD_W  = 3'b010;
localparam [2:0] LOAD_BU = 3'b100;
localparam [2:0] LOAD_HU = 3'b101;

reg [7:0]  selected_byte;
reg [15:0] selected_half;

always @(*) begin
    case (addr[1:0])
        2'b00: selected_byte = mem_rdata[7:0];
        2'b01: selected_byte = mem_rdata[15:8];
        2'b10: selected_byte = mem_rdata[23:16];
        default: selected_byte = mem_rdata[31:24];
    endcase

    if (addr[1])
        selected_half = mem_rdata[31:16];
    else
        selected_half = mem_rdata[15:0];

    case (load_type)
        LOAD_B:  load_data = {{24{selected_byte[7]}}, selected_byte};
        LOAD_H:  load_data = {{16{selected_half[15]}}, selected_half};
        LOAD_W:  load_data = mem_rdata;
        LOAD_BU: load_data = {24'd0, selected_byte};
        LOAD_HU: load_data = {16'd0, selected_half};
        default: load_data = 32'd0;
    endcase
end

endmodule
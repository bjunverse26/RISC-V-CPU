module Instruction_Memory #(
    parameter MEM_INIT_FILE = "program.hex"
)(
    input [31:0]        instr_addr,
    output [31:0]       instr
);

localparam integer IMEM_WORDS = 256;

reg [31:0] rom[0:IMEM_WORDS-1];
wire [7:0] word_addr;

assign word_addr = instr_addr[9:2];
assign instr = rom[word_addr];

integer i;
initial begin
    for (i = 0; i < IMEM_WORDS; i = i + 1)
        rom[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)

    // Program image initialization from hex file.
    $readmemh(MEM_INIT_FILE, rom);
end

endmodule
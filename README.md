# single-cycle_RISC-V

RV32I single-cycle CPU in Verilog.

## Project Structure

- `RTL/Core/RV32I_Core.v`: CPU core top (control + datapath)
- `RTL/Core/RV32I/Control_Unit.v`: instruction decode / control signals
- `RTL/Core/RV32I/Data_Path.v`: PC, ALU path, register writeback path
- `RTL/Core/Instruction_Memory.v`: instruction ROM (`program.hex`)
- `RTL/Core/Data_Memory.v`: data RAM with byte/half/word load/store
- `RTL/Core/RV32I_Top.v`: FPGA synthesis top (clk, reset_btn, led[3:0])
- `RTL/Core/RV32I/program.hex`: test program image
- `Test/tb_rv32i_final.v`: simulation testbench
- `Test/Zybo-Z7-Master.xdc`: Zybo Z7 pin constraints

## Supported ISA (current)

- R-type: `ADD SUB SLL SLT SLTU XOR SRL SRA OR AND`
- I-type: `ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI`
- Memory: `LB LH LW LBU LHU`, `SB SH SW`
- Branch/Jump: `BEQ BNE BLT BGE BLTU BGEU`, `JAL JALR`
- Upper immediate: `LUI AUIPC`

## Simulation

1. Add RTL sources and `Test/tb_rv32i_final.v` to simulation sources.
2. Ensure `program.hex` is visible to simulator working directory.
3. Run behavioral simulation.
4. Expected message: `PASS: tb_rv32i_final`.

## FPGA Implementation (Zybo Z7)

1. Set top module to `RV32I_Top`.
2. Add `Test/Zybo-Z7-Master.xdc` as constraints.
3. Ensure clock/reset/LED ports match:
   - `clk`
   - `reset_btn` (active-high button, internally inverted to `reset_n`)
   - `led[3:0]`
4. Run synthesis/implementation and generate bitstream.

## Notes

- `RV32I_Top` connects LED to `instr_addr[5:2]` mainly to keep observable outputs so synthesis/implementation does not optimize the design into an empty netlist.
- For core-only verification, use `tb_rv32i_final.v`.

## License

MIT. See `LICENSE`.
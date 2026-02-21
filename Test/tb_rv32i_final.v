`timescale 1ns/1ps

module tb_rv32i_final;
    reg clk;
    reg reset_n;
    integer cycles;
    reg done;
    wire [31:0] instr;
    wire [31:0] read_data;
    wire [31:0] instr_addr;
    wire data_mem_write;
    wire data_mem_read;
    wire [31:0] data_mem_addr;
    wire [1:0] store_type;
    wire [2:0] load_type;
    wire [31:0] write_data;

    RV32I_Core dut (
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

    always #5 clk = ~clk;

    task check_eq32;
        input [8*32-1:0] name;
        input [31:0] got;
        input [31:0] exp;
        begin
            if (got !== exp) begin
                $display("FAIL: %0s got=0x%08h expected=0x%08h", name, got, exp);
                $finish;
            end
        end
    endtask

    initial begin : run_test
        clk = 1'b0;
        reset_n = 1'b0;
        cycles = 0;
        done = 1'b0;

        repeat (3) @(posedge clk);
        reset_n = 1'b1;

        while ((cycles < 300) && !done) begin
            @(posedge clk);
            cycles = cycles + 1;

            if (u_dmem.ram[2] == 32'd127) begin
                $display("FAIL: program wrote fail signature 127");
                $finish;
            end

            if (u_dmem.ram[2] == 32'd2)
                done = 1'b1;
        end

        if (!done) begin
            $display("FAIL: timeout waiting for pass signature");
            $finish;
        end

        check_eq32("x3",  dut.u_datapath.u_regfile.register[3],  32'd12);
        check_eq32("x4",  dut.u_datapath.u_regfile.register[4],  32'd12);
        check_eq32("x5",  dut.u_datapath.u_regfile.register[5],  32'h12345000);
        check_eq32("x6",  dut.u_datapath.u_regfile.register[6],  32'h0000001C);
        check_eq32("x7",  dut.u_datapath.u_regfile.register[7],  32'h00000024);
        check_eq32("x8",  dut.u_datapath.u_regfile.register[8],  32'd42);
        check_eq32("x10", dut.u_datapath.u_regfile.register[10], 32'd0);
        check_eq32("x11", dut.u_datapath.u_regfile.register[11], 32'd42);
        check_eq32("x12", dut.u_datapath.u_regfile.register[12], 32'd5);
        check_eq32("x13", dut.u_datapath.u_regfile.register[13], 32'd2);

        check_eq32("mem[0]", u_dmem.ram[0], 32'd12);
        check_eq32("mem[1]", u_dmem.ram[1], 32'h0005002A);
        check_eq32("mem[2]", u_dmem.ram[2], 32'd2);

        $display("PASS: tb_rv32i_final (%0d cycles)", cycles);
        $finish;
    end
endmodule
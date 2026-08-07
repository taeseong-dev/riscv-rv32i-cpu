`timescale 1ns / 1ps

module instruction_mem(
    input           clk,
    input           rst,

    input   [31:00] instr_addr,
    output  logic   [31:00] instr_data
    );


    logic [31:00]   rom[0:127];



    initial begin
        $readmemh("multicycle_test.mem", rom);
    end


    assign instr_data = rom[instr_addr[31:02]];



endmodule

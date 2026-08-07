`timescale 1ns / 1ps
`include "define.vh"

module rv32i_top(

    input   clk,
    input   rst

    );


    logic           dwe;
    logic   [31:00] instr_addr, instr_data, daddr, dwdata, drdata;
    logic   [02:00] o_funct3;



    instruction_mem U_INSTRUCTION_MEM(.*);


    rv32i_cpu U_RV32I(.*,
    .o_funct3(o_funct3));

    data_mem U_DATA_MEM(.*,
    .i_funct3(o_funct3));


endmodule

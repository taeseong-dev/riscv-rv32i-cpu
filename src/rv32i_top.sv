`timescale 1ns / 1ps
`include "define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/06 16:36:02
// Design Name: 
// Module Name: rv32i_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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

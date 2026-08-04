`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu(
    input           clk,
    input           rst,
    input   [31:00] instr_data,
    input   [31:00] drdata,

    output  [31:00] instr_addr,
    output          dwe,
    output  [31:00] daddr,
    output  [02:00] o_funct3,
    output  [31:00] dwdata
    );

    logic           rf_we, alu_src, branch, jal, jalr;
    logic   [02:00] rfwd_src;
    logic   [03:00] alu_control;


    control_unit U_CNTL(
    .funct7         (instr_data[31:25]  ),
    .funct3         (instr_data[14:12]  ),
    .opcode         (instr_data[06:00]  ),
    .rf_we          (rf_we              ),
    .alu_src        (alu_src            ),
    .alu_control    (alu_control        ),
    .rfwd_src       (rfwd_src           ),
    .o_funct3       (o_funct3           ),
    .dwe            (dwe                ),
    .branch         (branch             ),
    .jal            (jal                ),
    .jalr           (jalr               )
);

    rv32i_datapath U_DATAPATH(.*);




endmodule

module  control_unit(
    input           [06:00] funct7,
    input           [02:00] funct3,
    input           [06:00] opcode,
    output  logic           rf_we,
    output  logic           alu_src,
    output  logic   [03:00] alu_control,
    output  logic   [02:00] o_funct3,
    output  logic   [02:00] rfwd_src,
    output  logic           dwe,
    output  logic           branch,
    output  logic           jal,
    output  logic           jalr
);

    always_comb begin
        rf_we       = 1'b0;
        alu_src     = 1'b0;
        alu_control = 4'b0000;
        branch      = 1'b0;
        rfwd_src    = 3'd0;
        jal         = 1'b0;
        jalr        = 1'b0;
        o_funct3    = 3'd0;
        dwe         = 1'd0;
        case(opcode)
            `R_TYPE  :  begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b0;
                            alu_control = {funct7[5], funct3};
                            branch      = 1'b0;
                            rfwd_src    = 3'b000;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            o_funct3    = 3'd0;
                            dwe         = 1'd0;
                            
                        end
            `S_TYPE :   begin
                            rf_we       = 1'b0;
                            alu_src     = 1'b1;
                            alu_control = 4'b0000;
                            branch      = 1'b0;
                            rfwd_src    = 3'b000;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            o_funct3    = funct3;
                            dwe         = 1'd1;
                        end

            `B_TYPE :   begin
                            rf_we       = 1'b0;
                            alu_src     = 1'b0;
                            alu_control = {1'b0, funct3};
                            branch      = 1'b1;
                            rfwd_src    = 3'b000;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            o_funct3    = 4'd0;
                            dwe         = 1'b0;
                        end
            `IL_TYPE:   begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b1;
                            alu_control = 4'b0000;
                            branch      = 1'b0;
                            rfwd_src    = 3'b001;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            o_funct3    = funct3;
                            dwe         = 1'b0;
                        end
            `I_TYPE :   begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b1;
                            dwe         = 1'b0;
                            o_funct3    = funct3;
                            rfwd_src    = 3'b000;
                            branch      = 1'b0;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            if(funct3 == 3'b101) alu_control = {funct7[5], funct3};
                            else alu_control = {1'b0, funct3};
                        end

            `UL_TYPE :  begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b0;
                            dwe         = 1'b0;
                            o_funct3    = funct3;
                            rfwd_src    = 3'b010;
                            branch      = 1'b0;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            alu_control = 4'd0;
                        end

            `UA_TYPE :  begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b0;
                            dwe         = 1'b0;
                            o_funct3    = funct3;
                            rfwd_src    = 3'b011;
                            branch      = 1'b0;
                            jal         = 1'b0;
                            jalr        = 1'b0;
                            alu_control = 4'd0;
                        end
            
            `J_TYPE :  begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b0;
                            dwe         = 1'b0;
                            o_funct3    = funct3;
                            rfwd_src    = 3'b100;
                            branch      = 1'b0;
                            jal         = 1'b1;
                            jalr        = 1'b0;
                            alu_control = 4'd0;
                        end

            `JL_TYPE :  begin
                            rf_we       = 1'b1;
                            alu_src     = 1'b0;
                            dwe         = 1'b0;
                            o_funct3    = funct3;
                            rfwd_src    = 3'b100;
                            branch      = 1'b0;
                            jal         = 1'b1;
                            jalr        = 1'b1;
                            alu_control = 4'd0;
                        end
        endcase
    end
            

endmodule





`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input         clk,
    input         rst,
    input [31:00] instr_data,
    input [31:00] drdata,

    output [31:00] instr_addr,
    output         dwe,
    output [31:00] daddr,
    output [02:00] o_funct3,
    output [31:00] dwdata
);

    logic rf_we, alu_src, branch, jal, jalr, pc_en;
    logic [02:00] rfwd_src;
    logic [03:00] alu_control;


    control_unit U_CNTL (
        .clk        (clk),
        .rst        (rst),
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[06:00]),
        .pc_en      (pc_en),
        .rf_we      (rf_we),
        .alu_src    (alu_src),
        .alu_control(alu_control),
        .rfwd_src   (rfwd_src),
        .o_funct3   (o_funct3),
        .dwe        (dwe),
        .branch     (branch),
        .jal        (jal),
        .jalr       (jalr)
    );

    rv32i_datapath U_DATAPATH (.*);




endmodule

module control_unit (
    input                clk,
    input                rst,
    input        [06:00] funct7,
    input        [02:00] funct3,
    input        [06:00] opcode,
    output logic         pc_en,
    output logic         rf_we,
    output logic         alu_src,
    output logic [03:00] alu_control,
    output logic [02:00] o_funct3,
    output logic [02:00] rfwd_src,
    output logic         dwe,
    output logic         branch,
    output logic         jal,
    output logic         jalr
);

    typedef enum logic [02:00] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM,
        WB
    } state_t;

    state_t c_st, n_st;

    reg n_pc_en, c_pc_en;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_st <= FETCH;
            c_pc_en <= 0;
        end else begin
            c_st <= n_st;
            c_pc_en <= n_pc_en;
        end
    end

    always_comb begin
        n_st = c_st;
        case (c_st)
            FETCH: begin
                n_st = DECODE;
            end
            DECODE: begin
                n_st = EXECUTE;
            end

            EXECUTE: begin
                case (opcode)

                    `R_TYPE, `I_TYPE, `B_TYPE, `UL_TYPE, `UA_TYPE, `J_TYPE, `JL_TYPE : n_st = FETCH;
                    `S_TYPE, `IL_TYPE : n_st = MEM;

                endcase
            end

            MEM: begin
                case (opcode)
                    `S_TYPE:  n_st = FETCH;
                    `IL_TYPE: n_st = WB;
                endcase
            end

            WB: begin
                n_st = FETCH;
            end
        endcase
    end

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
        pc_en       = 1'b0;

        case (c_st)
            FETCH: begin
                pc_en = 1'b1;
            end
            DECODE: begin
            end
            EXECUTE: begin
                case (opcode)

                    `R_TYPE: begin
                        rf_we = 1'b1;
                        alu_src = 1'b0;
                        alu_control = {funct7[5], funct3};
                    end
                    `S_TYPE: begin
                        alu_src = 1'b1;
                    end
                    `B_TYPE: begin
                        alu_src     = 1'b0;
                        alu_control = {1'b0, funct3};
                        branch      = 1'b1;
                    end
                    `IL_TYPE: begin
                        alu_src = 1'b1;
                    end
                    `I_TYPE: begin
                        rf_we   = 1'b1;
                        alu_src = 1'b1;
                        if (funct3 == 3'b101) alu_control = {funct7[5], funct3};
                        else alu_control = {1'b0, funct3};
                    end

                    `UL_TYPE: begin
                        rf_we = 1'b1;
                        rfwd_src    = 3'b010;
                    end

                    `UA_TYPE: begin
                        rf_we = 1'b1;
                        rfwd_src    = 3'b011;
                    end

                    `J_TYPE: begin
                        rf_we    = 1'b1;
                        rfwd_src = 3'b100;
                        jal      = 1'b1;
                    end

                    `JL_TYPE: begin
                        rf_we    = 1'b1;
                        rfwd_src = 3'b100;
                        jal      = 1'b1;
                        jalr     = 1'b1;
                    end

                endcase
            end
            MEM: begin
                o_funct3 = funct3;

                if (opcode == `S_TYPE) begin
                    dwe = 1'd1;
                end
            end

            WB: begin
                rfwd_src = 3'b001;
                rf_we    = 1'b1;
            end

        endcase
    end


endmodule





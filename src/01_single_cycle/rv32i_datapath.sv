`timescale 1ns / 1ps
`include "define.vh"


module rv32i_datapath(

    input           clk,
    input           rst,
    input           rf_we,
    input           alu_src,
    input   [03:00] alu_control,
    input   [31:00] instr_data,
    input   [31:00] drdata,
    input   [02:00] rfwd_src,
    input           branch,
    input           jal,
    input           jalr,

    output  [31:00] instr_addr,
    output  [31:00] daddr,
    output  [31:00] dwdata

);

    logic   [31:00] rd1, rd2, alu_result, alurs2_data, imm_data, alu_b_data, alu_4_data;
    logic   [31:00] rfwd_data;
    logic           btaken;

    assign  daddr   = alu_result;
    assign  dwdata  = rd2;

    program_counter U_PC(
    .clk                (clk        ),
    .rst                (rst        ),
    .branch             (branch     ),
    .btaken             (btaken     ),
    .jal                (jal        ),
    .jalr               (jalr       ),
    .rd1                (rd1        ),
    .imm_data           (imm_data   ),
    
    .alu_b_data         (alu_b_data ),
    .alu_4_data         (alu_4_data ),
    .program_counter    (instr_addr )

);
    register_file U_REG(

    .clk                (clk                ),
    .rst                (rst                ),
    .we                 (rf_we              ),
    .ra1                (instr_data[19:15]  ),
    .ra2                (instr_data[24:20]  ),
    .wa                 (instr_data[11:07]  ),
    .wdata              (rfwd_data          ),
    .rd1                (rd1                ),
    .rd2                (rd2                )

);

    imm_extender U_IMM_EXTEND(
    .instr_data         (instr_data ),
    .imm_data           (imm_data   )
);

    mux_2x1 U_MUX_ALUSRC_RS2(
    .in0            (rd2        ),
    .in1            (imm_data   ),
    .sel            (alu_src    ),
    .out_mux        (alurs2_data)
);


    alu U_ALU(

    .a              (rd1        ),
    .b              (alurs2_data),
    .alu_control    (alu_control),
    .btaken         (btaken     ),
    .alu_result     (alu_result )

);


    mux_wd U_MUX_WD(

    .in0            (alu_result ), //alu
    .in1            (drdata     ), //mem
    .in2            (imm_data   ), //lui
    .in3            (alu_b_data ), //auipc
    .in4            (alu_4_data ), //jal,jalr
    .sel            (rfwd_src   ), 

    .o_mux_wd       (rfwd_data  )

);

endmodule

module mux_wd(

    input           [31:00] in0, //alu
    input           [31:00] in1, //mem
    input           [31:00] in2, //lui
    input           [31:00] in3, //auipc
    input           [31:00] in4, //jal,jalr

    input           [02:00] sel,  //rfwdsrc 1'b1 : mem, 1'b0 : alu

    output  logic   [31:00] o_mux_wd

);

    always_comb begin
        o_mux_wd = 4'd0;
        case(sel)
            3'b000 : o_mux_wd = in0;
            3'b001 : o_mux_wd = in1;
            3'b010 : o_mux_wd = in2;
            3'b011 : o_mux_wd = in3;
            3'b100 : o_mux_wd = in4;
        endcase
    end



endmodule


module mux_2x1(
    input           [31:00] in0,
    input           [31:00] in1,
    input                   sel,
    output  logic   [31:00] out_mux
);

    assign out_mux = sel ? in1 : in0;

endmodule

module imm_extender(
    input           [31:00] instr_data,
    output  logic   [31:00] imm_data
);

    always_comb begin
        imm_data = 0;
        case(instr_data[6:0])
            `S_TYPE :   begin
                            imm_data = {{20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]};
                        end
            `I_TYPE , 
            `IL_TYPE,
            `JL_TYPE:   begin
                            imm_data = {{20{instr_data[31]}}, instr_data[31:20]};
                        end

            `B_TYPE :   begin
                            imm_data = {{20{instr_data[31]}},instr_data[07], instr_data[30:25], instr_data[11:08], 1'b0};
                        end

            `UL_TYPE,
            `UA_TYPE : begin
                            imm_data = {instr_data[31:12], 12'b0};
                        end

            `J_TYPE :   begin
                            imm_data = {{12{instr_data[31]}}, instr_data[19:12], instr_data[20], instr_data[30:21], 1'b0};
                        end
            
        endcase
    end
endmodule

module register_file(

    input           clk,
    input           rst,
    input           we,
    input   [04:00] ra1,
    input   [04:00] ra2,
    input   [04:00] wa,
    input   [31:00] wdata,
    output  [31:00] rd1,
    output  [31:00] rd2

);

    logic   [31:00] register_file [01:31];

//`ifdef SIMULATION
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//
//            if(i == 1) begin
//                register_file[i] = 12;
//            end
//            else begin
//              register_file[i] = i;
//            end
//        end
//    end
//`endif



//J-type
//`ifdef SIMULATION
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//
//            if(i == 1) begin
//                register_file[i] = 5;
//            end
//            else if(i == 2) begin
//                register_file[i] = -2;
//            end
//            
//            else begin
//              register_file[i] = i;
//            end
//        end
//    end
//`endif

////IL_type
//`ifdef SIMULATION
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//
//              register_file[i] = i;
//        end
//    end
//`endif



//R-type
//`ifdef SIMULATION
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//            if(i==1) begin
//                register_file[i] = 5;
//            end
//            else if(i==2) begin
//                register_file[i] = 1;
//            end
//            else if(i==3)  begin
//                register_file[i] = -3;
//            end
//            else begin
//              register_file[i] = i;
//            end
//        end
//    end
//`endif

//S-type
//`ifdef SIMULATION
   initial begin
       for (int i = 0; i < 32; i++) begin

           if(i == 2) begin
               register_file[i] = 32'h1234_5678;
           end
           else if(i == 3) begin
               register_file[i] = 32'h8765_4321;
           end
           else if(i == 4) begin
               register_file[i] = 32'h0000_ABCD;
           end
           else if(i == 5) begin
               register_file[i] = 32'h0000_0011;
           end
           else if(i == 6) begin
               register_file[i] = 32'h0000_0022;
           end
           else if(i == 7) begin
               register_file[i] = 32'h0000_0033;
           end
           else if(i == 8) begin
               register_file[i] = 32'h0000_0044;
           end
           else begin
             register_file[i] = i;
           end
       end
   end
//`endif


//B-type
//`ifdef SIMULATION
//    initial begin
//        for (int i = 0; i < 32; i++) begin
//
//            if(i == 1) begin
//                register_file[i] = 0;
//            end
//            else if(i == 4) begin
//                register_file[i] = -4;
//            end
//            
//            else begin
//              register_file[i] = i;
//            end
//        end
//    end
//`endif




    always @ (posedge clk) begin

        if(!rst && we) begin
            register_file[wa] <= wdata;
        end
    end

    assign rd1 = (ra1 == 0) ? 0 : register_file[ra1];
    assign rd2 = (ra2 == 0) ? 0 : register_file[ra2];


endmodule

module alu(

    input           [31:00] a,
    input           [31:00] b,
    input           [03:00] alu_control,
    output  logic           btaken,
    output  logic   [31:00] alu_result

);

    always_comb begin
        alu_result = 0;
        case(alu_control)
            `ADD  : alu_result = a + b;                        //ADD                         
            `SUB  : alu_result = a - b;                        //SUB
            `SLL  : alu_result = a << b[04:00];                       //SLL   
            `SLT  : alu_result = $signed(a) < $signed(b);      //SLT                           
            `SLTU : alu_result = a < b;                        //SLTU (unsigned)
            `XOR  : alu_result = a ^ b;                        //XOR
            `SRL  : alu_result = a >> b[04:00];                       //SRL   
            `SRA  : alu_result = $signed(a) >>> b[04:00];                      //SRA       
            `OR   : alu_result = a | b;                        //OR      
            `AND  : alu_result = a & b;                        //AND
        endcase
    end

    always_comb begin
        btaken = 0;
        case(alu_control[02:00])
            3'b000 : btaken = (a == b);
            3'b001 : btaken = (a != b);
            3'b100 : btaken = ($signed(a) < $signed(b));
            3'b101 : btaken = ($signed(a) >= $signed(b));
            3'b110 : btaken = (a < b);
            3'b111 : btaken = (a >= b);
        endcase
    end
endmodule



module  program_counter(
    input   clk,
    input   rst,
    input   branch,
    input   btaken,
    input   jal,
    input   jalr,
    input   [31:00] rd1,
    input   [31:00] imm_data,

    output  [31:00] alu_b_data,
    output  [31:00] alu_4_data,
    output  [31:00] program_counter

);
    logic   [31:00] pc_alu_4_out, pc_alu_b_out, out_mux;
    logic           pc_mux_sel;
    logic   [31:00] alu_b_in;


    assign alu_b_data = pc_alu_b_out;
    assign alu_4_data = pc_alu_4_out;

    assign pc_mux_sel = ((branch && btaken) || jal);


    mux_2x1 U_MUX_RD2_IMM (
        .in0(program_counter),
        .in1(rd1),
        .sel(jalr),
        .out_mux(alu_b_in)
    );

    pc_alu U_PC_ALU_4(
    .a(32'd4),
    .b(program_counter),
    .pc_alu_out(pc_alu_4_out)
);

    pc_alu U_PC_ALU_B(
    .a(imm_data),
    .b(alu_b_in),
    .pc_alu_out(pc_alu_b_out)
    );

    mux_2x1 U_PC_MUX(
        .in0(pc_alu_4_out),
        .in1(pc_alu_b_out),
        .sel(pc_mux_sel),
        .out_mux(out_mux)
    );
    

    register U_PC_REG(
        .clk(clk),
        .rst(rst),
        .data_in(out_mux),
        .data_out(program_counter)
    );



endmodule

module pc_alu(
    input   [31:00] a,
    input   [31:00] b,
    output  [31:00] pc_alu_out
);

    assign pc_alu_out = a + b;

endmodule



module register (
    input   clk,
    input   rst,
    input   [31:00] data_in,
    output  [31:00] data_out
);

    logic   [31:00] register;

    always @ (posedge clk or posedge rst) begin
        if(rst)begin
            register <= 32'd0;
        end
        else begin
            register <= data_in;
        end
    end

    assign data_out = register;

endmodule

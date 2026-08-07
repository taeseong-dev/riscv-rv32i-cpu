`timescale 1ns / 1ps

module data_mem(
    input           clk,
    input           rst,
    input           dwe,
    input           [02:00] i_funct3,
    input           [31:00] daddr,
    input           [31:00] dwdata,

    output  logic   [31:00] drdata

    );

    logic   [31:00] dmem[00:127];

    always @ (posedge clk) begin
        
        if(dwe) begin
            if(i_funct3 == 3'b000) begin
                if(daddr[01:00] == 2'b00) begin
                    dmem[daddr[31:2]][07:00] <= dwdata[07:00];
                end
                else if(daddr[01:00] == 2'b01) begin
                    dmem[daddr[31:2]][15:08] <= dwdata[07:00];
                end
                else if(daddr[01:00] == 2'b10) begin
                    dmem[daddr[31:2]][23:16] <= dwdata[07:00];
                end
                else if(daddr[01:00] == 2'b11) begin
                    dmem[daddr[31:2]][31:24] <= dwdata[07:00];
                end
            end
            else if(i_funct3 == 3'b001) begin
                if(daddr[01:00] == 2'b00) begin
                    dmem[daddr[31:2]][15:00] <= dwdata[15:00];
                end
                else if(daddr[01:00] == 2'b10) begin
                    dmem[daddr[31:2]][31:16] <= dwdata[15:00];
                end
            end
            else if(i_funct3 == 3'b010) begin
                dmem[daddr[31:2]] <= dwdata;
            end
        end
    end

    always_comb begin
        drdata = 0;
        case({i_funct3, daddr[01:00]})
        //LB
            5'b000_00 : drdata = {{24{dmem[daddr[31:02]][07]}}, dmem[daddr[31:02]][07:00]};
            5'b000_01 : drdata = {{24{dmem[daddr[31:02]][15]}}, dmem[daddr[31:02]][15:08]};
            5'b000_10 : drdata = {{24{dmem[daddr[31:02]][23]}}, dmem[daddr[31:02]][23:16]};
            5'b000_11 : drdata = {{24{dmem[daddr[31:02]][31]}}, dmem[daddr[31:02]][31:24]};
        //LH
            5'b001_00 : drdata = {{16{dmem[daddr[31:02]][15]}}, dmem[daddr[31:02]][15:00]};
            5'b001_10 : drdata = {{16{dmem[daddr[31:02]][31]}}, dmem[daddr[31:02]][31:16]};
        //LW
            5'b010_00 : drdata = dmem[daddr[31:02]];
        //LBU
            5'b100_00 : drdata = {{24'b0}, dmem[daddr[31:02]][07:00]};
            5'b100_01 : drdata = {{24'b0}, dmem[daddr[31:02]][15:08]};
            5'b100_10 : drdata = {{24'b0}, dmem[daddr[31:02]][23:16]};
            5'b100_11 : drdata = {{24'b0}, dmem[daddr[31:02]][31:24]};
        //LHU
            5'b101_00 : drdata = {{16'b0}, dmem[daddr[31:02]][15:00]};
            5'b101_10 : drdata = {{16'b0}, dmem[daddr[31:02]][31:16]};
        endcase
    end




endmodule

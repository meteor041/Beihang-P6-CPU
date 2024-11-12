`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:59:19 11/06/2024 
// Design Name: 
// Module Name:    DM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "constants.v"
module DM(
    input clk,
    input reset,
    input WE,
    input [1:0] MEM_PART,
    input [31:0] addr,
    input [31:0] WD,
    input [31:0] PC,
    output [31:0] RD
    );

/*-----------------------------------Data Memory初始化----------------------------------------*/
    reg[31:0] ram[4095:0];
    integer i;
    initial begin
        for (i = 0; i < 4096; i=i+1)begin
                ram[i] = 32'b0;
            end
    end
/*------------------------------------------写入逻辑------------------------------------------------*/
    always @(posedge clk)begin
        if (reset) begin
            for (i = 0; i < 4096; i=i+1)begin
                ram[i] = 32'b0;
            end
        end
        else if (WE == 1) begin
            if (MEM_PART == `memWord)
                ram[addr >> 2] = WD;
            else if (MEM_PART == `memHalf)
                ram[addr >> 2][16*half+:16] = WD[15:0];
            else if (MEM_PART == `memByte)
                ram[addr >> 2][8*byte+:8] = WD[7:0];
            $display("%d@%h: *%h <= %h", $time, PC, (addr>> 2) << 2, ram[addr[13:2]]);
        end
    end

/*------------------------------------------读出逻辑------------------------------------------------*/
    wire half;
    wire [1:0] byte;
    wire [31:0] lb_RD;
    wire [31:0] lh_RD;

    // 在32bit的数据内定位
    assign half = addr[1];
    assign byte = addr[1:0];

    // load Half 的读出数据(符号扩展)
    assign lh_RD = {{16{ram[addr[13:2]][16*half+15]}}, 
                    ram[addr[13:2]][16*half+:16]};
    // load Byte 的读出数据(符号扩展)
    assign lb_RD = {{24{ram[addr[13:2]][8*byte+7]}}, 
                    ram[addr[13:2]][8*byte+:8]};

    // 最终读出操作
    assign RD = (MEM_PART == `memHalf) ? lh_RD :
                (MEM_PART == `memByte) ? lb_RD :
                (MEM_PART == `memWord) ? ram[addr[13:2]]:
                32'bz;

endmodule

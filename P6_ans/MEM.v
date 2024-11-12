`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:54:48 11/06/2024 
// Design Name: 
// Module Name:    MEM 
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
module MEM(
    input clk,
    input reset,
    input [31:0] MEM_PC, // 指令PC地址(用于$display)
    input [31:0] MEM_instr, // MEM区当前指令
    input [31:0] MEM_WD, // MEM区传递的写入A3寄存器的值,传递至WB区
    input [31:0] MEM_RES, // MEM区传递的ALU计算结果
    input [31:0] MEM_RD2_forward, // MEM区接收的A2转发数据
    input [4:0] MEM_A3, // MEM区传递接收写入数据的A3寄存器,传递至WB区
    input [31:0] RD, // 从MEMORY中读出的数据
    output [4:0] MEM_WB_A3, // MEM区传递接收写入数据的A3寄存器,传递至WB区
    output [31:0] MEM_WB_WD,// MEM区传递的写入A3寄存器的值,传递至WB区
    output [1:0] MEM_A2_NEW, // MEM区$T_{NEW}$
    output [3:0] MEM_BYTE_EN, // 写入MEM数据的按字节使能信号
    output [31:0] MEM_WRITE_DATA, // 写入MEM,按字节重新排序的数据
    output [31:0] MEM_DATA_ADDR, // 写入或读出的Memory地址
    output [31:0] MEM_INST_ADDR // 当load/store指令对应的PC地址
    );

/*--------------------------------控制信号-------------------------------*/
    wire WE;
    wire MEM_Sel;
    wire [1:0] MEM_PART;
    wire [2:0] MEM_EXT_Control;
    CTRL mem_ctrl(
        .instr(MEM_instr),
        .MEM_WE(WE), // 写入Memory的使能信号
        .MEM_Sel(MEM_Sel),
        .MEM_A2_NEW(MEM_A2_NEW),
        .MEM_PART(MEM_PART),
        .MEM_EXT_Control(MEM_EXT_Control)
    );
    assign MEM_WB_A3 = MEM_A3;

/*--------------------------------LOAD类指令,读出Memory数据并进行扩展-------------------------------*/
    wire [31:0] LOAD_DATA;
    // MEM读出数据扩展部件
    MEM_EXT mem_ext(
        .A(addr[1:0]),
        .Din(RD),
        .Op(MEM_EXT_Control),
        .Dout(LOAD_DATA)
    );

    assign MEM_WB_WD = (MEM_Sel == 1) ? LOAD_DATA : MEM_WD;  

/*--------------------------------STORE类指令相关,写入Memory-------------------------------*/
    // lh定位
    wire half;
    // lb定位
    wire [1:0] byte;
    // 地址,是EX区的ALU计算结果
    wire [31:0] addr;
    assign addr = MEM_RES;    
    assign half = addr[1];
    assign byte = addr[1:0];
         
    // 写入MEM数据的按字节使能信号
    assign MEM_BYTE_EN =  (WE == 0) ? 4'b0000 :
                    (MEM_PART == `memWord) ? 4'b1111 :
                    (MEM_PART == `memHalf && half == 0) ? 4'b0011 :
                    (MEM_PART == `memHalf && half == 1) ? 4'b1100 :
                    (MEM_PART == `memByte && byte == 2'b00) ? 4'b0001 : 
                    (MEM_PART == `memByte && byte == 2'b01) ? 4'b0010 : 
                    (MEM_PART == `memByte && byte == 2'b10) ? 4'b0100 : 
                    (MEM_PART == `memByte && byte == 2'b11) ? 4'b1000 :
                    4'b0000;
    // 写入MEM,按字节重新排序的数据
    assign MEM_WRITE_DATA = (WE== 0) ? 32'b0 :
                    (MEM_PART == `memWord) ? MEM_RD2_forward:
                    (MEM_PART == `memHalf && half == 0) ? MEM_RD2_forward :
                    (MEM_PART == `memHalf && half == 1) ? {MEM_RD2_forward[15:0], 16'b0} :
                    (MEM_PART == `memByte && byte == 2'b00) ? MEM_RD2_forward : 
                    (MEM_PART == `memByte && byte == 2'b01) ? {16'b0, MEM_RD2_forward[7:0], 8'b0} : 
                    (MEM_PART == `memByte && byte == 2'b10) ? {8'b0, MEM_RD2_forward[7:0], 16'b0} : 
                    (MEM_PART == `memByte && byte == 2'b11) ? {MEM_RD2_forward[7:0], 24'b0} :
                    32'b0;
    // 写入或读出的Memory地址
    assign MEM_DATA_ADDR = MEM_RES;
    // 当load/store指令对应的PC地址
    assign MEM_INST_ADDR = MEM_PC;
endmodule

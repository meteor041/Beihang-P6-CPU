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
    input [31:0] MEM_PC,
    input [31:0] MEM_instr,
    input [31:0] MEM_WD,
    input [31:0] MEM_RES,
    input [31:0] MEM_RD2_forward,
    input [4:0] MEM_A3,
    input [31:0] RD,
    output [4:0] MEM_WB_A3,
    output [31:0] MEM_WB_WD,
    output [1:0] MEM_A2_NEW,
    output [3:0] MEM_BYTE_EN,
    output [31:0] MEM_WRITE_DATA,
    output [31:0] MEM_DATA_ADDR,
    output [31:0] MEM_INST_ADDR
    );

    wire WE;
    // wire [31:0] RD;
    wire MEM_Sel;
    wire [1:0] MEM_PART;
    CTRL mem_ctrl(
        .instr(MEM_instr),
        .MEM_WE(WE), // 写入Memory的使能信号
        .MEM_Sel(MEM_Sel),
        .MEM_A2_NEW(MEM_A2_NEW),
        .MEM_PART(MEM_PART)
    );

    // assign MEM_WB_WD = (MEM_Sel == 1) ? RD : MEM_WD;
    
    assign MEM_WB_A3 = MEM_A3;

    wire half;
    wire [1:0] byte;
    wire [31:0] addr;
    assign addr = MEM_RES;

    // 在32bit的数据内定位
    assign half = addr[1];
    assign byte = addr[1:0];
    assign MEM_WB_WD = (MEM_Sel == 0) ? MEM_WD :
                    (WE == 0 && MEM_PART == `memWord) ? RD :
                    (WE == 0 && MEM_PART == `memHalf && half == 0) ? {{16{RD[15]}}, RD[15:0]} :
                    (WE == 0 && MEM_PART == `memHalf && half == 1) ? {{16{RD[31]}}, RD[31:16]} :
                    (WE == 0 && MEM_PART == `memByte && byte == 2'b00) ? {{24{RD[7]}}, RD[7:0]} : 
                    (WE == 0 && MEM_PART == `memByte && byte == 2'b01) ? {{24{RD[15]}}, RD[15:8]} : 
                    (WE == 0 && MEM_PART == `memByte && byte == 2'b10) ? {{24{RD[23]}}, RD[23:16]} : 
                    (WE == 0 && MEM_PART == `memByte && byte == 2'b11) ? {{24{RD[31]}}, RD[31:24]} :
                    MEM_WD;                         
    assign MEM_BYTE_EN =  (WE == 0) ? 4'b0000 :
                    (MEM_PART == `memWord) ? 4'b1111 :
                    (MEM_PART == `memHalf && half == 0) ? 4'b0011 :
                    (MEM_PART == `memHalf && half == 1) ? 4'b1100 :
                    (MEM_PART == `memByte && byte == 2'b00) ? 4'b0001 : 
                    (MEM_PART == `memByte && byte == 2'b01) ? 4'b0010 : 
                    (MEM_PART == `memByte && byte == 2'b10) ? 4'b0100 : 
                    (MEM_PART == `memByte && byte == 2'b11) ? 4'b1000 :
                    4'b0000;
    assign MEM_WRITE_DATA = (WE== 0) ? 32'b0 :
                    (MEM_PART == `memWord) ? MEM_RD2_forward:
                    (MEM_PART == `memHalf && half == 0) ? MEM_RD2_forward :
                    (MEM_PART == `memHalf && half == 1) ? {MEM_RD2_forward[15:0], 16'b0} :
                    (MEM_PART == `memByte && byte == 2'b00) ? MEM_RD2_forward : 
                    (MEM_PART == `memByte && byte == 2'b01) ? {16'b0, MEM_RD2_forward[7:0], 8'b0} : 
                    (MEM_PART == `memByte && byte == 2'b10) ? {8'b0, MEM_RD2_forward[7:0], 16'b0} : 
                    (MEM_PART == `memByte && byte == 2'b11) ? {MEM_RD2_forward[7:0], 24'b0} :
                    32'b0;
    assign MEM_DATA_ADDR = MEM_RES;
    assign MEM_INST_ADDR = MEM_PC;
 
    
    // DM dm(
    //     .clk(clk),
    //     .reset(reset),
    //     .WE(WE),
    //     .MEM_PART(MEM_PART),
    //     .addr(MEM_RES),
    //     .WD(MEM_RD2_forward),
    //     .PC(MEM_PC),
    //     .RD(RD)
    // );


endmodule

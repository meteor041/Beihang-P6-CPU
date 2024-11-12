`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:41:22 11/05/2024 
// Design Name: 
// Module Name:    IF 
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
module IF(
    input clk, // 时钟信号
    input reset,   // 重置信号
    input enablePC, // PC 使能信号
    input [31:0] NPC, // PC地址输入
    output [31:0] IF_PC // 输出PC地址
    );

    // 程序计数器
    PC pc(
        .clk(clk),
        .reset(reset),
        .enable(enablePC),
        .NPC(NPC), // PC地址输入
        .PC(IF_PC) // 输出PC地址
    );
endmodule

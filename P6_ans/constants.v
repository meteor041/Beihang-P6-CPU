`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:55:51 11/05/2024 
// Design Name: 
// Module Name:    constants 
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

// R型指令构造
`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define funct 5:0

// I型指令构造
`define immediate 15:0

// J型指令构造
`define instr_index 25:0

// ALUOp
`define aluAnd 4'b0
`define aluOr 4'b1
`define aluAdd 4'b10
`define aluLui 4'b11
`define aluXor 4'b100
`define aluSlt 4'b101
`define aluSub 4'b110
`define aluSltu 4'b111
`define aluSwc 4'b1000 // 2021年上机指令

// CMPControl
// 控制部件:CMP,来源:CTRL,作用:选择CMP部件的比较方式,使其输出对应的结果(zero)
`define cmpBeq 4'b0000
`define cmpBgez 4'b0001
`define cmpBgtz 4'b0010
`define cmpBlez 4'b0011
`define cmpBltz 4'b0100
`define cmpBne 4'b0101
`define cmpBonall 4'b0110

//MEM_PART
`define memWord 2'b00
`define memHalf 2'b01
`define memByte 2'b10

//MULT_DIV_OP
`define mult 3'b0
`define div 3'b1
`define multu 3'b10
`define divu 3'b11

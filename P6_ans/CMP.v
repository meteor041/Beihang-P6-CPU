`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:26:07 11/05/2024 
// Design Name: 
// Module Name:    CMP 
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
module CMP(
    input [31:0] A,
    input [31:0] B,
    input [3:0] CMPControl,
    output zero
    );

    assign zero = (CMPControl == `cmpBeq)  ? (A == B) :
                  (CMPControl == `cmpBgez) ? (A >= 32'b0):
                  (CMPControl == `cmpBgtz) ? (A > 32'b0) :
                  (CMPControl == `cmpBlez) ? (A <= 32'b0) :
                  (CMPControl == `cmpBltz) ? (A < 32'b0) :
                  (CMPControl == `cmpBne)  ? (A != B) :
                  (CMPControl == `cmpBonall) ? (A + B == 32'b0) :
                  1'bz;
endmodule

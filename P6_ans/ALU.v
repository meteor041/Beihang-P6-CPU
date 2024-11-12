`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:13:28 11/06/2024 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUOp,
    output reg [31:0] ALURes
    );
    integer i;
    always @(*)begin
        case (ALUOp)
            `aluAdd:ALURes = SrcA+SrcB;
            `aluSub:ALURes = SrcA-SrcB;
            `aluOr:ALURes = SrcA | SrcB;
            `aluAnd:ALURes = SrcA & SrcB;
            `aluLui:ALURes = SrcB << 16; // 高位覆盖
            `aluSlt:ALURes = ($signed(SrcA) < $signed(SrcB)) ? $signed(32'b1) : $signed(32'b0);
            `aluSltu:ALURes = ($unsigned(SrcA) < $unsigned(SrcB)) ? $unsigned(32'b1) : $unsigned(32'b0);
            `aluSwc:begin
                ALURes = SrcA;
                if (SrcB[0] == 1)begin
                  for (i = 0; i < SrcB[4:0]; i=i+1)begin
                    ALURes = {ALURes[0], ALURes[31:1]};
                  end
                end
                else begin
                  for (i = 0; i < SrcB[4:0]; i=i+1)begin
                    ALURes = {ALURes[30:0], ALURes[31]};
                  end
                end
            end
            default:ALURes = 32'bz;
        endcase
    end
endmodule

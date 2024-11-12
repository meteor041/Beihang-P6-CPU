`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:51 11/12/2024 
// Design Name: 
// Module Name:    MULt_DIV 
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
module MULT_DIV(
    input clk,
    input reset,
    input [31:0] A,
    input [31:0] B,
    input start,
    input [2:0] MULT_DIV_OP,
    input MTHI,   
    input MTLO,       
    output reg busy,
    output reg [31:0] HI,
    output reg [31:0] LO
    );

    reg[31:0] hi;
    reg[31:0] lo;
    integer cnt;
    always @(posedge clk)begin
        if (reset)begin
            hi <= 32'b0;
            lo <= 32'b0;
            cnt <= 0;
            busy <= 0;
            HI <= 32'b0;
            LO <= 32'b0;
        end
        else if (cnt==0)begin
            if (MTHI == 1)begin
              HI <= A;
            end
            else if (MTLO == 1)begin
              LO <= A;
            end
            else if (start == 1)begin
                busy <= 1;
                if (MULT_DIV_OP == `mult)begin
                    {hi, lo} <= $signed(A) * $signed(B);
                    cnt <= 5;
                end
                else if (MULT_DIV_OP == `div)begin
                    hi <= $signed(A) % $signed(B);
                    lo <= $signed(A) / $signed(B);
                    cnt <= 10;
                end
                else if (MULT_DIV_OP == `multu)begin
                    {hi, lo} <= $unsigned(A) * $unsigned(B);
                    cnt <= 5;
                end
                else if (MULT_DIV_OP == `divu)begin
                    hi <= $unsigned(A) % $unsigned(B);
                    lo <= $unsigned(A) / $unsigned(B);
                    cnt <= 10;
                end 
            end
        end
        else if (cnt == 1)begin
            HI <= hi;
            LO <= lo;
            cnt <= 0;
            busy <= 0;
        end
        else begin
            cnt = cnt - 1;
        end
    end

endmodule

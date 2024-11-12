`timescale 1ns / 1ps
`include "constants.v"
module MEM_EXT(
    input [1:0] A,
    input [31:0] Din,
    input [2:0] Op,
    output [31:0] Dout
);
    wire [1:0] byte;
    wire half;
    assign byte = A;
    assign half = A[1];
    assign Dout = (Op == `nonExt) ? Din :
                  (Op == `unsignedByteExt) ? {24'b0, Din[8*byte+:8]} :
                  (Op == `signedByteExt) ? {{24{Din[8*byte+7]}}, Din[8*byte+:8]}:
                  (Op == `unsignedHalfExt) ? {16'b0, Din[16*half+:16]} :
                  (Op == `signedHalfExt) ? {{16{Din[16*half+15]}}, Din[16*half+:16]} :
                  32'bz;
endmodule
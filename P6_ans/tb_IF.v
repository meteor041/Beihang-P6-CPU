`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:09:45 11/06/2024
// Design Name:   IF
// Module Name:   E:/Documents/computer_organization/work/P5/tb_IF.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: IF
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_IF;

	// Inputs
	reg clk;
	reg reset;
	reg enablePC;
	reg [31:0] NPC;

	// Outputs
	wire [31:0] IF_instr;
	wire [31:0] IF_PC;

	// Instantiate the Unit Under Test (UUT)
	IF uut (
		.clk(clk), 
		.reset(reset), 
		.enablePC(enablePC), 
		.NPC(NPC), 
		.IF_instr(IF_instr), 
		.IF_PC(IF_PC)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		enablePC = 1;


		// Wait 100 ns for global reset to finish
		#100;
        reset = 0;
		// Add stimulus here
		forever #50 clk = ~clk;
	end
    initial begin
	  		NPC = 32'h3000;
		forever #100 NPC = NPC + 4;
	end
	always @(IF_instr)begin
	  $display("%H", IF_instr);
	end
endmodule


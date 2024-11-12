`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:55:51 11/06/2024
// Design Name:   CTRL
// Module Name:   E:/Documents/computer_organization/work/P5/tb_CTRL.v
// Project Name:  P5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CTRL
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_CTRL;

	// Inputs
	reg [31:0] instr;
	reg zero;

	// Outputs
	wire Branch;
	wire Jal;
	wire Jr;
	wire ExtControl;
	wire Sel_ID_WD;
	wire [4:0] ID_A3;
	wire ID_A1_USE;
	wire ID_A2_USE;
	wire [3:0] ALUOp;
	wire ALU_B_Sel;
	wire WD_Sel;
	wire EX_A1_USE;
	wire EX_A2_USE;
	wire MEM_WE;
	wire MEM_Sel;

	// Instantiate the Unit Under Test (UUT)
	CTRL uut (
		.instr(instr), 
		.zero(zero), 
		.Branch(Branch), 
		.Jal(Jal), 
		.Jr(Jr), 
		.ExtControl(ExtControl), 
		.Sel_ID_WD(Sel_ID_WD), 
		.ID_A3(ID_A3), 
		.ID_A1_USE(ID_A1_USE), 
		.ID_A2_USE(ID_A2_USE), 
		.ALUOp(ALUOp), 
		.ALU_B_Sel(ALU_B_Sel), 
		.WD_Sel(WD_Sel), 
		.EX_A1_USE(EX_A1_USE), 
		.EX_A2_USE(EX_A2_USE), 
		.MEM_WE(MEM_WE), 
		.MEM_Sel(MEM_Sel)
	);
	integer i;
	reg[31:0] rom[0:4095];
	initial begin
		// Initialize Inputs
		instr = 0;
		zero = 0;
		$readmemh("code.txt", rom);
		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here
		for (i=0;i<4096;i=i+1)begin
		  #100 instr = rom[i];
		end
	end
      
endmodule


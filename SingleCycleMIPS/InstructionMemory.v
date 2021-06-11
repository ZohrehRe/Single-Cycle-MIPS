
 module InstructionMemory( readAddr , instruction);
	input [31:0]readAddr ;
	output [31:0] instruction;
	reg    [31:0] instruction;
	reg [31:0] insMem [0:255];
	
	initial
		$readmemb("prog.asm",insMem);
	
	always @(readAddr)
		instruction = insMem[readAddr];
			
endmodule

  



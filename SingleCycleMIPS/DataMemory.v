
module DataMemory(clk ,address , writeData , readData , memRead , memWrite);
input [31:0] address , writeData;
input memWrite , memRead;
input clk;
output [31:0] readData;

reg [31:0] dataMemory [0:64];
assign readData = (memRead) ? dataMemory[address] : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

always@(posedge clk)
begin
	if(memWrite == 1'b1)
		begin
				dataMemory[address] = writeData;
		end
end 
initial
begin
	dataMemory[0] = 31'd0;
	dataMemory[1] = 31'd0;
	dataMemory[2] = 31'd0;
	dataMemory[3] = 31'd7;
	dataMemory[4] = 31'd0;
	dataMemory[5] = 31'd0;
	dataMemory[6] = 31'd0;
	dataMemory[7] = 31'd9;
	dataMemory[8] = 31'd0;
	dataMemory[9] = 31'd0;
end
endmodule

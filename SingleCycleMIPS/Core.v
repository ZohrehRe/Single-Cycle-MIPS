module Core(clk);
input clk;   
  
    reg [31:0]PC;

  
  //designing datapath.......................................................................................  
  reg [31:0]readAddress;
  wire [31:0]instructionW;  
  InstructionMemory instructionMemory(readAddress, instructionW);
  
  reg [31:0]in;
  wire [31:0]out;
  ShiftLeft2 shifter(in , out);
  
  reg [31:0]Four;
  wire [31:0]nextPCw;
  wire overflow1;
  Adder nextPC(PC , Four , nextPCw , overflow1);

  wire [31:0]bTarget; 
  wire overflow2;
  Adder BranchPC(nextPCw, out , bTarget, overflow2);
  
  wire [31:0]address;
  reg [31:0]writeDataMem;
  wire[31:0]readData;
  reg MemRead, MemWrite;
  DataMemory dataMemory(clk , address, writeDataMem, readData, MemRead, MemWrite);
  
  reg [4:0]in1, in2;
  reg RegDst;
  wire [4:0]regDst_out;
  Mux regDst(in1, in2, RegDst, regDst_out);
  
  reg [4:0]readRegister1, readRegister2;
  wire [4:0] writeRegister;
  wire [31:0]writeDataRegs;
  wire [31:0]readData1, readData2;
  reg RegWrite;
  RegisterFile registers( clk ,readRegister1, readRegister2, writeRegister, writeDataRegs, readData1, readData2, RegWrite);
  
  //sign extend registers
  reg [15:0]signIn;
  reg [31:0]signOut;
  
  reg aluSrcR;
  wire [31:0] aluSrc_out;
  Mux aluSrc(readData2, signOut, aluSrcR, aluSrc_out);
  
  //ALU_control registers
  reg [5:0]FunctField;
  reg [1:0]ALUOp;
  
  reg [3:0]alu_control;
  wire[31:0]ALU_out;
  wire outZero;
  ALU alu(readData1, aluSrc_out, alu_control, ALU_out, outZero);
  
  reg Branch;
  wire branchEn; 
	reg z;
  //and And_Branch(branchEn, Branch, z);
  assign branchEn = Branch & z;

  wire [31:0]nextPC2;
  Mux pcSrc(nextPCw , bTarget , branchEn, nextPC2);
  
  reg MemtoReg;
  wire [31:0]writeDataToReg;
  Mux memtoReg(ALU_out, readData, MemtoReg, writeDataToReg);
  //EOF designing datapath...................................................................................
  
      
  reg [5:0]OpCode;
  reg [4:0]rs, rt, rd, shamt; 
  reg [31:0]jumpTarget;
  integer counter, lastJ;
////////////////////////////////////////////START FROM HERE//////////////////////////////////////////////////

		assign writeRegister = regDst_out;
		assign writeDataRegs = writeDataToReg;
		assign address = ALU_out;
		
		
initial
  begin
	PC = 32'b0;    
	Four = 32'h0000_0001;   
	counter = 0;
	lastJ = 0;
  end   
  
 //fetch.....................................................................................................
 
  always@(posedge clk)
      begin  
            if(counter != 0)     
		  PC = nextPC2;
		
		if(lastJ == 1) 
		  PC = jumpTarget;
		  
		readAddress = PC; //to instruction memory		
      end
  
  
  
  always@(instructionW)  
  begin 		
		
//decode...................................................................................................		
		counter = 1;  
		OpCode = instructionW[31:26];
		rs = instructionW[25:21];
		rt = instructionW[20:16];
		rd = instructionW[15:11];
		signIn = instructionW[15:0];
		shamt =  instructionW[10:6];
		FunctField = instructionW[5:0];
		
		RegDst = 1;
		 
		

//sign extend
		signOut[15:0]  = signIn[15:0];
		signOut[31:16] = {16{signIn[15]}};
		
		//to registerFile   
		readRegister1 = rs;
		readRegister2 = rt;
		
		//to mux regDst	
		in1 = rt;              
		in2 = rd;
		
		//check for beq
		z = outZero;
		
		//input to writeDataMem
		writeDataMem = readData2;
			  
		//shift output of signExtend
		in = signOut;	
		
//instructions....................................................................................

		//...........noop		
		if(instructionW==32'd0)
			begin
					
						
			  RegDst = 0;
			  aluSrcR = 0;
			  MemtoReg = 0;
			  RegWrite = 0;
			  MemRead = 0;
			  MemWrite = 0;
			  Branch = 0;
			  ALUOp = 2'bzz;   
						
			end		

		//..........'J' type	
		else
		if(OpCode == 6'b000010 || OpCode == 6'b000011)
		  begin
			  jumpTarget[25:0] = instructionW[25:0];
			  jumpTarget[31:26] = PC[31:26];
			  lastJ = 1; 
			  RegDst = 0;
			  aluSrcR = 0;
			  MemtoReg = 0;
			  RegWrite = 0;
			  MemRead = 0;
			  MemWrite = 0;
			  Branch = 0;
			  ALUOp = 2'bzz; 			  
		  end

		//...........'R' type
		else if(OpCode == 6'b000000)     
		begin
			  
			  RegDst = 1;
			  aluSrcR = 0;
			  MemtoReg = 0;
			  RegWrite = 1;
			  MemRead = 0;
			  MemWrite = 0;
			  Branch = 0;
			  ALUOp = 2'b10; 


			//..............alu_control
			if(ALUOp == 2'b10)      
			begin
				case(FunctField) 

				6'b000010: alu_control = 4'b0100; //srlv   
				6'b000100: alu_control = 4'b0011; //sll   
				6'b000110: alu_control = 4'b0100; //srl   
				6'b010100: alu_control = 4'b0011; //sllv  
				6'b100000: alu_control = 4'b1010; //adds   
				6'b100001: alu_control = 4'b0010; //addu   
				6'b100010: alu_control = 4'b0110; //sub 
				6'b100011: alu_control = 4'b1110; //subs   		
				6'b100100: alu_control = 4'b0000; //and    
				6'b100101: alu_control = 4'b0001; //or 
				6'b100110: alu_control = 4'b0101; //xor   		
				6'b101010: alu_control = 4'b0111; //SLT  
				6'b101011: alu_control = 4'b1111; //SLTU  
	
				endcase
			end  
			//................EOF alu_control	
		end   

		//...........'I' type
		else
		begin 

			  //addi              
			  if(OpCode == 6'b001000) 
			  begin

				  Branch = 0;
				  RegDst = 0;
				  aluSrcR = 1;
				  MemRead = 0;
				  MemtoReg = 0;   
				  MemWrite = 0;
				  RegWrite = 1;
				  lastJ = 0;
				  alu_control = 4'b0010; 
				  
			  end


		
			  // lw 		
			  if(OpCode == 6'b100011)   
			  begin
			 
				  RegDst = 0;
				  aluSrcR = 1;
				  MemtoReg = 1;
				  RegWrite = 1;
				  MemRead = 1;
				  MemWrite = 0;
				  Branch = 0;
				  //ALUOp = 2'b00; 
				  alu_control = 4'b0010; 

				  
			  end
			  //sw              
			  if(OpCode == 6'b101011)   
			  begin
				  
				  RegDst = 0;
				  aluSrcR = 1;
				  MemtoReg = 1; 
				  RegWrite = 0;
				  MemRead = 0;
				  MemWrite = 1;
				  Branch = 0;
				  //ALUOp = 2'b00;
				  alu_control = 4'b0010; 	

				  
				 
			  end
			  //beq               
			  if(OpCode == 6'b000100)   
			  begin
				  
				  RegDst = 0;
				  aluSrcR = 0; 
				  MemtoReg = 1; 
				  RegWrite = 0;
				  MemRead = 0;
				  MemWrite = 0;
				  Branch = 1;
				 // ALUOp = 2'b01;
				  alu_control = 4'b0110;  	
			   
			  end
			  //bne              
			  if(OpCode == 6'b000101)  
			  begin
				  
				  RegDst = 0;
				  aluSrcR = 0;
				  MemtoReg = 1;
				  RegWrite = 0;
				  MemRead = 0;
				  MemWrite = 0;
				  alu_control = 4'b0110; 
				  if(z == 0)
					begin
									  Branch = 1;

					end				  
			  end
			  //ori              
			  if(OpCode == 6'b001101)   
			  begin
				  
				  lastJ = 0;
				  RegDst = 0;
				  aluSrcR = 1;
				  MemtoReg = 0; 
				  RegWrite=1;
				  MemRead = 0;
				  MemWrite = 0;
				  Branch = 0;
				  alu_control = 4'b0110;  
				  
				  RegWrite = ~RegWrite; 
				  RegWrite = ~RegWrite;   
				   
			  end


		end   
		
  end     //always block
  
endmodule

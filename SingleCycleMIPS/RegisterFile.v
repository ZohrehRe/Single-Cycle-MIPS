module RegisterFile( clk , readRegister1, readRegister2, writeRegister, writeDataregs, readData1, readData2, RegWrite);
     input [4:0]readRegister1, readRegister2, writeRegister;
     input [31:0]writeDataregs; 	 //address of the register to be written on to.
	 input clk;
	 input RegWrite;    //RegWrite - register write signal; writeReg-the destination register.
     
     output [31:0]readData1, readData2;
     reg [31:0]readData1, readData2;
     
     reg [31:0]RegMemory[0:31];
     
     integer placeVal, i, j, writeRegINT=0, readReg1INT=0, readReg2INT=0;
     
     initial
     begin
       for(i=0 ; i<32 ; i=i+1)
       begin
              for(j=0 ; j<32 ; j= j+1)
                RegMemory[i][j] = 1'b0;
       end
	   
			RegMemory[1] = 32'd4;
			RegMemory[2] = 32'd2;
			RegMemory[3] = 32'd3;
	   
     end
     
     always@ (*)
     begin
       
        if(RegWrite == 1)
        begin
          
          placeVal = 1;
          readReg1INT=0;
          readReg2INT=0;
          for(i=0 ; i<5 ; i=i+1)
          begin
               if(readRegister1[i] == 1)
                  readReg1INT = readReg1INT + placeVal;
                  
               if(readRegister2[i] == 1)
                  readReg2INT = readReg2INT + placeVal; 
                    
               placeVal = placeVal * 2;
          end
          
          
          for(i=0 ; i<32 ; i=i+1)
          begin
              readData1[i] = RegMemory[readReg1INT][i];
              readData2[i] = RegMemory[readReg2INT][i];
          end
          
          
          
          //binary to decimal address translation.
          placeVal = 1;
          writeRegINT=0;
          for(i=0 ; i<5 ; i=i+1)
          begin
               if(writeRegister[i] == 1)
                  writeRegINT = writeRegINT + placeVal;
                  
               placeVal = placeVal * 2;
          end
          
          for(i=0 ; i<32 ; i=i+1)
          begin
                RegMemory[writeRegINT][i] = writeDataregs[i];
          end
            
        end  // Register Write
        
        if(RegWrite == 0)
        begin
            //binary to decimal address translation.
          placeVal = 1;
          readReg1INT=0;
          readReg2INT=0;
          for(i=0 ; i<5 ; i=i+1)
          begin
               if(readRegister1[i] == 1)
                  readReg1INT = readReg1INT + placeVal;
                  
               if(readRegister2[i] == 1)
                  readReg2INT = readReg2INT + placeVal; 
                    
               placeVal = placeVal * 2;
          end
          
          
          for(i=0 ; i<32 ; i=i+1)
          begin
              readData1[i] = RegMemory[readReg1INT][i];
              readData2[i] = RegMemory[readReg2INT][i];
          end
          
          
        end// Register Read
          
     end  //always@
     
endmodule  


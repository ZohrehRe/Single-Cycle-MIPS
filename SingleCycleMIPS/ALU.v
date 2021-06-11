
module ALU(a,b,ctl,result,zero); 

 input [31:0] a,b;         // port A,B 
 input [3:0] ctl ;			 // carry input from carry flag register 
 output [31:0] result;        // the result 
 output  zero ;            // zero output 
         // functionality control for ALU       // ALU result 

 assign result = alu_out(a,b,ctl); 
 assign zero   = z_flag(result) ; 
   reg [31:0] cin ; 

  initial
	begin
	cin = 32'b0;    
	
   end 
 
 function [31:0] alu_out; 
   input  [31:0] a,b ; 
   input  [3:0] ctl ; 

  


   case ( ctl ) 
       4'b0000: alu_out=a&b;                  // AND 
       4'b0001: alu_out=a|b ;         // OR
       4'b0010: alu_out=a+b ;         // ADDU
       4'b0011: alu_out={b[30:0],1'b0};                // SLL  
       4'b0100: alu_out={1'b0,b[30:1]};            // SRL 
       4'b0101: alu_out=a^b ;               // XOR
       4'b0110: alu_out=a-b;         // SUBU
       4'b0111: alu_out=(a < b)?32'd1:32'd0;                // SLT 
       4'b1010: alu_out=a+b;      // ADDS
       4'b1100: alu_out={b[3:0],cin};       //  
       4'b1101: alu_out={b[0],cin,b[3:1]};  // 
	   4'b1110: alu_out=a-b;       // SUBS
	   4'b1111: alu_out=(a < b)?32'd1:32'd0;       //SLTU 
	   
	   
	   


	   
         default : begin 
                     alu_out=9'bxxxxxxxxx; 
                   end     
     endcase  /* {...,...,...} is for the concatenation. 
                 {ADD_WITH_CARRY,SUB_WITH_BORROW}==2'b11 is used 
                 to force the CARRY==1 for the increment operation */   
   endfunction // end of function "result" 

  function z_flag ; 
  input [31:0] in ; 
    begin 
      if(in == 32'h0000)
		begin
			z_flag = 1'b1;
		end 
    else
    begin
      z_flag = 1'b0;
    end
    end 
  endfunction 

endmodule 

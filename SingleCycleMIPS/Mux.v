module Mux (in0 , in1, s, out );
  input [31:0] in0; 
  input [31:0] in1;
  input s;
  output [31:0]out;
  
    assign out = (s == 0 ) ? in0 : in1;
    
 endmodule


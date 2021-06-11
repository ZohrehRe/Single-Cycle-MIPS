

module mips_tb();
reg clk;

Core core(clk);

initial
 clk = 0;
 
 always #20 clk = ~clk;
endmodule

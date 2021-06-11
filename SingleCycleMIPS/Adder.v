module Adder(
    input [31:0] in0,
    input [31:0] in1,
    output  [31:0] sum,
    output  cout
    );

	assign {cout, sum} = in0 + in1;

endmodule


module FA (
    input   wire   a,
    input   wire   b,
    input   wire   cin,
    output  wire   sum,
    output  wire   carry
);
	assign {carry, sum} = a + b + cin;
endmodule

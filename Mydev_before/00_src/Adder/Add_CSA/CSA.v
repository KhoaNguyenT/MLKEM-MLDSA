module CSA #(
    parameter WIDTH = 32
)(
    input   wire   [WIDTH-1:0]   a,
    input   wire   [WIDTH-1:0]   b,
    input   wire   [WIDTH-1:0]   cin,
    output  wire   [WIDTH-1:0]   sum,
    output  wire   [WIDTH-1:0]   carry
);
	

	wire [WIDTH - 1:0] carry_stage;

	genvar i;
	generate
		// Stage 1: CSA - 3-input fulladders
		for (i = 0; i < WIDTH; i = i + 1) begin : CSA_STAGE
			FA FA_inst (
				.a(a[i]),
				.b(b[i]),
				.cin(cin[i]),
				.sum(sum[i]),
				.carry(carry_stage[i])
			);
		end
	endgenerate
	// pass UNUSEDSIGNAL
	wire temp;
	assign temp = (carry_stage[WIDTH-1]) ? 1'b0 : carry_stage[WIDTH-1];
	// Stage 2: Ripple Carry Adder - sum_stage1 + (carry_stage << 1)
	// assign {carry, sum}  = sum_out + (carry_stage << 1);
    assign carry = {carry_stage[WIDTH - 2:0], temp};
endmodule

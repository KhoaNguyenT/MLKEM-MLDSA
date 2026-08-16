module ReverseBits #(
    parameter WIDTH = 8
)(
    input  wire  [WIDTH-1:0] in,
    output wire  [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin
            assign out[WIDTH-1-i] = in[i];
        end
    endgenerate
endmodule

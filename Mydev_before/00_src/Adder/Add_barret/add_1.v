// module add_1 #(
//     parameter WIDTH = 12
// )(
//     input   logic   [WIDTH-1:0] a,
//     input   logic   [WIDTH-1:0] b,
//     output  logic   [WIDTH-1:0] result   // a[i][j] + b[i][j]
// );
//     localparam POLY_Q = 3329;

//     logic [WIDTH:0] sum_full;
//     logic [WIDTH:0] sum_minus_Q;


//     assign  sum_full    = {1'b0, a} + {1'b0, b};
//     assign  sum_minus_Q = sum_full - POLY_Q;

//     assign  result      = (sum_minus_Q[12]) ? sum_full[11:0] : sum_minus_Q[11:0];
// endmodule

module add_1 #(
    parameter WIDTH = 12
)(
    input   wire   [WIDTH:0] a,
    input   wire   [WIDTH:0] b,
    output  wire   [WIDTH-1:0] result   // a[i][j] + b[i][j]
);
    localparam POLY_Q = 3329;

    wire [WIDTH+1:0] sum_full;
    wire [WIDTH+1:0] sum_minus_Q;
    wire [WIDTH+1:0] sum_add_Q;


    assign  sum_full    = {1'b0, a} + {b[WIDTH], b};
    assign  sum_minus_Q = sum_full - POLY_Q;
    assign  sum_add_Q   = sum_full + POLY_Q;

    assign  result      = (&sum_full[WIDTH+1:WIDTH])    ? sum_add_Q[WIDTH-1:0] 
                        : (~(|sum_minus_Q[WIDTH+1:WIDTH])) ? sum_minus_Q[WIDTH-1:0]
                        : sum_full[WIDTH-1:0];
endmodule


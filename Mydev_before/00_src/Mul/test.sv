module test (
    input  logic                        clk_i,
    input  logic                        rst_i,
    input  logic                        valid_data,
    input  logic    [2:0]               k, 
    input  logic    [192-1:0]           a,
    input  logic    [192-1:0]           b,
    output logic    [192-1:0]           res,
    output logic                        valid_output,
    output logic                        before_valid_output
);
    MulMatrix MulMatrix_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .valid_data(valid_data),
        .k(k),
        .a(a),
        .b(b),
        .res(res),
        .valid_output(valid_output),
        .before_valid_output(before_valid_output)
    );
endmodule

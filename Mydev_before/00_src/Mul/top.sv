
module top (		
    input   logic           clk_i,
    input   logic           rst_i,
    input   logic           valid_data,
    input   logic    [2:0]  k, 
    input   logic [31:0]    a_0,
    input   logic [31:0]    a_1,
    input   logic [31:0]    a_2,
    input   logic [31:0]    a_3,
    input   logic [31:0]    a_4,
    input   logic [31:0]    a_5,
    input   logic [31:0]    b_0,
    input   logic [31:0]    b_1,
    input   logic [31:0]    b_2,
    input   logic [31:0]    b_3,
    input   logic [31:0]    b_4,
    input   logic [31:0]    b_5,
    output  logic [191:0]   res,
    output  logic           valid_output,
    output  logic           before_valid_output
);
    logic               rst_i_reg;
    logic               valid_data_reg;
    logic    [2:0]      k_reg; 
    logic   [191:0]     a_reg;
    logic   [191:0]     b_reg;
    always @(posedge clk_i) begin
        rst_i_reg       <= rst_i;
        valid_data_reg  <= valid_data;
        k_reg           <= k;
        a_reg           <= {a_0, a_1, a_2, a_3, a_4, a_5};
        b_reg           <= {b_0, b_1, b_2, b_3, b_4, b_5};
    end

    test module_inst (
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
endmodule : top

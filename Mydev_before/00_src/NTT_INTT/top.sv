module top (
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   logic                       start,
    input   logic                       is_NTT,
    input   logic                       valid_input,
    input   logic   [31:0]              in_0,
    input   logic   [31:0]              in_1,
    input   logic   [31:0]              in_2,
    input   logic   [31:0]              in_3,
    input   logic   [31:0]              in_4,
    input   logic   [31:0]              in_5,
    output  logic   [192-1:0]           out,
    output  logic                       load_done,
    output  logic                       done_compute,
    output  logic                       valid_output,
    output  logic                       pre_valid_output,
    output  logic                       done_o
);
    logic                       rst_i_reg;
    logic                       start_reg;
    logic                       is_NTT_reg;
    logic                       valid_input_reg;
    logic   [192-1:0]           in_reg;
    always @(posedge clk_i) begin
        rst_i_reg   <= rst_i;
        start_reg   <= start;
        is_NTT_reg  <= is_NTT;
        valid_input_reg <= valid_input;
        in_reg  <= {in_0, in_1, in_2, in_3, in_4, in_5};
    end
    test test_m (
        .clk_i(clk_i),
        .rst_i(rst_i_reg),
        .start(start_reg),
        .is_NTT(is_NTT_reg),
        .valid_input(valid_input_reg),
        .in(in_reg),
        .load_done(load_done),
        .done_compute(done_compute),
        .done_o(done_o),
        .valid_output(valid_output),
        .pre_valid_output(pre_valid_output),
        .out(out)
    );
endmodule

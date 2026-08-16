module test (
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               start,
    input   logic               is_NTT,
    input   logic               valid_input,
    input   logic   [192-1:0]   in,
    output  logic               load_done,
    output  logic               done_compute,
    output  logic               done_o,
    output  logic               valid_output,
    output  logic               pre_valid_output,
    output  logic   [192-1:0]   out
);
  
    NTT NTT_module (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start(start),
        .is_NTT(is_NTT),
        .valid_input(valid_input),
        .in(in),
        .load_done(load_done),
        .done_compute(done_compute),
        .done_o(done_o),
        .valid_output(valid_output),
        .pre_valid_output(pre_valid_output),
        .out(out)
    );
    always @(posedge clk_i) begin
        if (valid_output) begin
            $display("%h",out);
            $fflush();
        end
    end
endmodule

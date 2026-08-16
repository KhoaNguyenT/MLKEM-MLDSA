module WrapperNTTINTT #(
    parameter DATA_WIDTH = 13,
    parameter INPUT_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter ADDR_ZETA = 7
)(
    //  CONTROL SIGNAL
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    //  CONTROL SIGNAL
    input   wire                        CBD_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   CBD_data_i,
    input   wire                        MUL_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   MUL_data_i,
    input   wire                        DCP_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   DCP_data_i,
    output  wire                        done_compute,
    output  wire                        valid_output,
    output  wire                        pre_valid_output,
    output  wire    [INPUT_WIDTH-1:0]   out,
    output  wire                        NTT_done,
    output  wire    [3:0]               NTT_runs 
);

    // wire            NTT_done;
    wire            NTT_load_done;
    // wire            NTT_done_compute;
    wire            is_NTT;
    wire            NTT_valid_input_o;
    wire            NTT_rst;
    wire            NTT_start;
    wire    [INPUT_WIDTH-1:0]   NTT_data_input_o;
    
    // logic           NTT_valid_input_pre;
    // logic   [3:0]               NTT_runs_reg;
    // always @(posedge clk_i) begin
    //     if (rst_i) begin
    //         NTT_runs_reg    <= 0;
    //     end
    //     else begin
    //         if ((NTT_runs_reg != NTT_runs) & NTT_valid_input_pre) begin
    //             NTT_runs_reg    <= NTT_runs;
    //         end
    //     end
    // end

    Controller_NTT #(
        .INPUT_WIDTH(INPUT_WIDTH)
    ) Controller_NTT_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .NTT_done_i(NTT_done),
        .CBD_valid_input(CBD_valid_input),
        .CBD_data_i(CBD_data_i),
        .MUL_valid_input(MUL_valid_input),
        .MUL_data_i(MUL_data_i),
        .DCP_valid_input(DCP_valid_input),
        .DCP_data_i(DCP_data_i),
        .load_done(NTT_load_done),
        .done_compute(done_compute),
        .NTT_valid_output_i(valid_output),
        .is_NTT_o(is_NTT),
        .NTT_valid_input_o(NTT_valid_input_o),
        .NTT_data_input_o(NTT_data_input_o),
        .NTT_rst_o(NTT_rst),
        .NTT_start_o(NTT_start),
        .NTT_runs(NTT_runs)
    );

    NTT #(
        .DATA_WIDTH(DATA_WIDTH),
        .INPUT_WIDTH(INPUT_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ADDR_ZETA(ADDR_ZETA)
    ) NTT_inst (
        .clk_i(clk_i),
        .rst_i(rst_i | NTT_rst),
        .start(NTT_start),
        .is_NTT(is_NTT),
        .valid_input(NTT_valid_input_o),
        .in(NTT_data_input_o),
        .load_done(NTT_load_done),
        .done_compute(done_compute),
        .done_o(NTT_done),
        .valid_output(valid_output),
        .pre_valid_output(pre_valid_output),
        .out(out)
    );
endmodule

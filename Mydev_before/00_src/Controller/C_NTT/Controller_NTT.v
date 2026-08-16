module Controller_NTT#(
    parameter INPUT_WIDTH = 192
)(
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        NTT_done_i,
    input   wire                        CBD_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   CBD_data_i,
    input   wire                        MUL_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   MUL_data_i,
    input   wire                        DCP_valid_input,
    input   wire    [INPUT_WIDTH-1:0]   DCP_data_i,
    input   wire                        load_done,
    input   wire                        done_compute,
    input   wire                        NTT_valid_output_i,

    output  reg                         is_NTT_o,
    output  wire                        NTT_valid_input_o,
    output  wire    [INPUT_WIDTH-1:0]   NTT_data_input_o,
    output  reg                         NTT_rst_o,
    output  reg                         NTT_start_o,
    output  wire    [3:0]               NTT_runs 
);
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE = 2'b00;
localparam DIN  = 2'b01;
localparam RUN  = 2'b10;
localparam DOUT = 2'b11;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg     [1:0]   state;
    reg     [3:0]   count_run;
    wire    [3:0]   k_temp;
    // logic           NTT_rst_o;

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign k_temp = {1'b0, k_i};
    assign NTT_runs = count_run;
    assign NTT_valid_input_o    =   (gk_ena_i & ~ec_ena_i & ~dc_ena_i)  ?   CBD_valid_input
                                :   (~gk_ena_i & ec_ena_i & ~dc_ena_i)  ?   ((count_run <= k_temp) ? CBD_valid_input : MUL_valid_input)
                                :   (~gk_ena_i & ~ec_ena_i & dc_ena_i)  ?   ((count_run <= k_temp) ? DCP_valid_input : MUL_valid_input)
                                :   DCP_valid_input;
    assign NTT_data_input_o     =   (gk_ena_i & ~ec_ena_i & ~dc_ena_i)  ?   CBD_data_i
                                :   (~gk_ena_i & ec_ena_i & ~dc_ena_i)  ?   ((count_run <= k_temp) ? CBD_data_i : MUL_data_i)
                                :   (~gk_ena_i & ~ec_ena_i & dc_ena_i)  ?   ((count_run <= k_temp) ? DCP_data_i : MUL_data_i)
                                :   DCP_data_i;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin   :   CONTROL_BLOCK
        if (rst_i) begin
            state       <= IDLE;
            count_run   <= 0;
            is_NTT_o    <= 0;
            NTT_rst_o   <= 0;
            NTT_start_o <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (ena_i) begin
                        NTT_start_o <= 1'b1;
                        if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin // GENKEY
                            is_NTT_o    <= 1;
                            if (count_run ==  k_temp << 1) begin
                                NTT_rst_o   <= 1'b1;
                                state       <= IDLE;
                            end
                            else begin
                                NTT_rst_o   <= 1'b0;
                                state       <= DIN;
                                count_run   <= count_run + 1;
                            end
                        end
                        else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin // ENCAP
                            if (count_run ==  (k_temp << 1)+1) begin
                                NTT_rst_o   <= 1'b1;
                                state       <= IDLE;
                            end
                            else begin
                                NTT_rst_o   <= 1'b0;
                                state       <= DIN;
                                count_run   <= count_run + 1;
                            end


                            if (count_run < k_temp) begin
                                is_NTT_o    <= 1;
                            end
                            else begin
                                is_NTT_o    <= 0;
                            end
                        end
                        else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                            if (count_run ==  k_temp + 1) begin
                                NTT_rst_o   <= 1'b1;
                                state       <= IDLE;
                            end
                            else begin
                                NTT_rst_o   <= 1'b0;
                                state       <= DIN;
                                count_run   <= count_run + 1;
                            end


                            if (count_run < k_temp) begin
                                is_NTT_o    <= 1;
                            end
                            else begin
                                is_NTT_o    <= 0;
                            end
                        end
                    end
                end
                DIN: begin
                    NTT_start_o <= 1'b0;
                    if (NTT_valid_input_o & load_done) begin
                        state       <= RUN;
                    end
                    else begin
                        state       <= DIN;
                    end
                end
                RUN: begin
                    if (done_compute) begin
                        state       <= DOUT;
                    end
                    else begin
                        state       <= RUN;
                    end
                end
                DOUT: begin
                    if (NTT_done_i) begin
                        state       <= IDLE;
                        NTT_rst_o   <= 1'b1;
                    end
                    else begin
                        state       <= DOUT;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
/*****************************************************************************
*                              Internal Modules                              *
*****************************************************************************/
    // NTT #(
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .INPUT_WIDTH(INPUT_WIDTH),
    //     .ADDR_WIDTH(ADDR_WIDTH),
    //     .ADDR_ZETA(ADDR_ZETA)
    // ) NTT_m (
    //     .clk_i(clk_i),
    //     .rst_i(rst_i),
    //     .start(start),
    //     .is_NTT(is_NTT_o),
    //     .valid_input(valid_input),
    //     .in(in),
    //     .load_done(load_done),
    //     .done_compute(done_compute),
    //     .done_o(done_o),
    //     .valid_output(valid_output),
    //     .out(out)
    // );
endmodule

module GenInSampleCBD (
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            ena_i,
    input   wire            next_i,
    input   wire            gk_ena_i,
    input   wire            ec_ena_i,
    input   wire    [2:0]   k_i,
    output  wire    [15:0]  last_Block_o,
    output  wire            last_hash_o,
    output  wire    [2:0]   lnum_hash_o,
    output  reg             done_o
);
    localparam IDLE = 2'b00, RUN = 2'b01, DONE = 2'b10;
    // dem l truoc k sau
    reg   [7:0] counter_k;
    // logic [7:0] counter_runs;
    wire  [7:0] k_temp;
    wire  [7:0] N_limit_i;
    reg   [1:0] state;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    assign lnum_hash_o  = 3'b001;
    assign k_temp       = {5'b0, k_i};
    assign N_limit_i    = (gk_ena_i & ~ec_ena_i) ? k_temp << 1
                        : (~gk_ena_i & ec_ena_i) ? (k_temp << 1) + 1
                        : 0;
    assign last_Block_o = {counter_k, 8'b0};
    assign last_hash_o  = ena_i;

    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
        if(rst_i) begin
            state       <= IDLE;  
            counter_k   <= 0;
            done_o      <= 0;
            // counter_runs <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    // if (gk_ena_i & ~ec_ena_i) begin
                    //     counter_runs <= k_temp;
                    // end
                    if (ena_i) begin
                        state <= RUN;
                    end
                    done_o      <= 0;
                end 
                RUN: begin
                    if (next_i) begin
                        if (counter_k !=   N_limit_i) begin
                            state <= state;
                            counter_k <= counter_k + 1;
                            // if ((gk_ena_i & ~ec_ena_i) & (counter_runs != N_limit_i-1)) begin
                            //     counter_runs <= counter_runs + 1;
                            // end
                            // else begin
                            //     counter_runs <= 0;
                            // end
                        end
                        else if (counter_k ==  N_limit_i) begin
                            counter_k <= 0;
                            state     <= DONE;
                        end
                    end
                end 
                DONE: begin
                    done_o <= 1;
                end
                default: state <= state;
            endcase
        end
    end
endmodule

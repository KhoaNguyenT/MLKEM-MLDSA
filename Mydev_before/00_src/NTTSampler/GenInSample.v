module GenInSample (
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            ena_i,
    input   wire            next_i,
    input   wire            mode_i,   // 0 : Encap, 1: Genkey
    input   wire    [1:0]   param_i,  //  2, 3, 4 => 1, 2, 3
    output  wire    [15:0]  last_Block_o,
    output  wire            last_hash_o,
    output  wire    [2:0]   lnum_hash_o,
    output  reg     [4:0]   runtimes,
    output  wire            done_o
);
    localparam IDLE = 2'b00, RUN = 2'b01, DONE = 2'b10;
    // dem l truoc k sau
    reg   [1:0] state;
    reg   [7:0] counter_l, counter_k;
    wire  [7:0] param_i_temp;
    wire    [15:0]  last_Block_o_gk;
    wire    [15:0]  last_Block_o_en;
    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    assign lnum_hash_o  = 3'b010;
    assign param_i_temp = {6'b0, param_i};
    assign last_Block_o_gk = {counter_l, counter_k};
    assign last_Block_o_en = {counter_k, counter_l};
    assign last_Block_o = (mode_i) ? last_Block_o_gk : last_Block_o_en;
    assign last_hash_o  = ena_i;

    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
        if(rst_i) begin
            state       <= 0;  
            counter_l   <= 0;
            counter_k   <= 0;
            runtimes    <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (ena_i) begin
                        state <= RUN;
                    end
                    done_o      <= 0;
                end 
                RUN: begin
                    if (next_i) begin
                        
                        if (counter_l == param_i_temp && counter_k != param_i_temp) begin
                            state <= state;
                            counter_l <= 0;
                            counter_k <= counter_k + 1;
                            runtimes  <= runtimes + 1;
                        end
                        else if (counter_l == param_i_temp && counter_k == param_i_temp) begin
                            counter_k <= 0;
                            counter_l <= 0;
                            state     <= DONE;
                        end
                        else begin
                            counter_l <= counter_l + 1;  
                            runtimes  <= runtimes + 1;
                            state <= state;
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

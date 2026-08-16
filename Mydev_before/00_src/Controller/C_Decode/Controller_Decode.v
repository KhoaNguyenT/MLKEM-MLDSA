module Controller_Decode # (
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
) (
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        ec_inter_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire    [3:0]               NTT_runs,
    input   wire                        NTT_done_compute,
    input   wire                        NTT_done_one,
    output  reg                         DC_run_check,
    
    // DECODE TO BRAM
    input   wire                        wvalid_i,
    input   wire    [DATA_WIDTH-1:0]    din_i_bram,
    input   wire                        done_input_i,
    input   wire                        rvalid_i,
    output  reg                         ena_o_bram,
    output  reg                         wea_o_bram,
    output  wire    [ADDR_WIDTH-1:0]    addr_o_bram,
    output  reg     [DATA_WIDTH-1:0]    din_o_bram,
    // I/O DECODE
    output  wire    [2:0]               DEC_mode,
    output  reg     [2:0]               state,
    output  reg                         valid_decode,
    output  reg                         wdone_o
);
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE       = 3'b000;
localparam WRITE      = 3'b001;
localparam READWAIT   = 3'b010;
localparam READ       = 3'b011;
localparam READDCNTT  = 3'b100;
localparam READDCV    = 3'b101;
localparam DONE       = 3'b111;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    // wire  [2:0] state;
    reg                         done_dc;
    wire    [3:0]               k_temp;
    reg     [1:0]               runmode;
    reg     [2:0]               dc_runtimes;
    reg                         done_uncnt;
    wire    [ADDR_WIDTH-1:0]    uncnt_start_c2;
    wire    [ADDR_WIDTH-1:0]    uncnt_end_c1;
    wire    [ADDR_WIDTH-1:0]    uncnt_end_c2;
    wire    [ADDR_WIDTH-1:0]    uncnt_mul;
    wire    [ADDR_WIDTH-1:0]    uncnt_dc;
    wire    [ADDR_WIDTH-1:0]    uncnt_ek;
    reg     [ADDR_WIDTH-1:0]    shift_count;
    reg     [ADDR_WIDTH-1:0]    cnt_in;
    reg     [ADDR_WIDTH-1:0]    cnt_out;
    // wire    [ADDR_WIDTH-1:0]    cnt_out_mul;

    wire    [ADDR_WIDTH-1:0]    count_r_temp;
    wire    [ADDR_WIDTH-1:0]    count_r_add;
    reg     [2:0]               count_k;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  k_temp          =   {1'b0, k_i};
    assign  uncnt_start_c2  =   (k_i == 3'd2)   ?   8'd32
                            :   (k_i == 3'd3)   ?   8'd48
                            :   (k_i == 3'd4)   ?   8'd64
                            :   0;
    assign  uncnt_end_c1    =   (k_i == 3'd2)   ?   8'd31
                            :   (k_i == 3'd3)   ?   8'd47
                            :   (k_i == 3'd4)   ?   8'd63
                            :   0;
    assign  uncnt_end_c2    =   (k_i == 3'd2)   ?   8'd47
                            :   (k_i == 3'd3)   ?   8'd63
                            :   (k_i == 3'd4)   ?   8'd79
                            :   0;
    assign  uncnt_mul       =   (k_i == 3'd2)   ?   8'd48
                            :   (k_i == 3'd3)   ?   8'd64
                            :   (k_i == 3'd4)   ?   8'd80
                            :   0;
    assign  uncnt_dc        =   (k_i == 3'd2)   ?   8'd79
                            :   (k_i == 3'd3)   ?   8'd111
                            :   (k_i == 3'd4)   ?   8'd143
                            :   0;
    assign  uncnt_ek        =   (k_i == 3'd2)   ?   8'd80
                            :   (k_i == 3'd3)   ?   8'd112
                            :   (k_i == 3'd4)   ?   8'd144
                            :   0;
    assign  count_r_add     =   count_r_temp + shift_count;
    // assign DC_run_check = ~dc_runtimes[0] & (state == READWAIT);
    // assign  addr_o_bram =   (wea_o_bram & (ec_ena_i & ~dc_ena_i))   ?   ((done_uncnt)   ?   (cnt_in-2)      :   cnt_in) 
    //                     :   (~ec_ena_i & dc_ena_i)                  ?   ((wea_o_bram)   ?   cnt_in          :  cnt_out)  
    //                     :   count_r_temp;

    // always @(*) begin
    //     if ((ec_ena_i | ec_inter_i) & ~dc_ena_i) begin
    //         if (wea_o_bram) begin
    //             if (done_uncnt) begin
    //                 addr_o_bram = cnt_in-2;
    //             end
    //             else begin
    //                 addr_o_bram = cnt_in;
    //             end
    //         end
    //         else begin
    //             addr_o_bram = count_r_add;
    //         end
    //     end
    //     else if ((~ec_ena_i & ~ec_inter_i) & dc_ena_i) begin
    //         if (wea_o_bram) begin
    //             addr_o_bram = cnt_in;
    //         end
    //         else begin
    //             if ((state == READDCNTT) | (state == READDCV)) begin
    //                 addr_o_bram = cnt_out;
    //             end
    //             else addr_o_bram = count_r_add;
    //         end
    //     end
    //     else addr_o_bram = 0;
    // end

    wire [2:0] temp_sub;
    assign temp_sub     = count_k - 3'd1;
    assign count_r_temp = {1'b0, temp_sub, cnt_out[3:0]};  
    //
    wire mode_ec, mode_dc;
    wire state_is_read;
    assign mode_ec = (ec_ena_i | ec_inter_i) & ~dc_ena_i;
    assign mode_dc = (~ec_ena_i & ~ec_inter_i) & dc_ena_i;
    assign state_is_read = (state == READDCNTT) | (state == READDCV);
    assign addr_o_bram =
                    mode_ec ? (wea_o_bram ? (done_uncnt ? cnt_in - 2 : cnt_in) : count_r_add)
                :   mode_dc ? (wea_o_bram ? cnt_in : (state_is_read ? cnt_out : count_r_add)):
                    '0;
    //
    wire k_eq_4;
    assign k_eq_4  = (k_i == 4);
    assign DEC_mode =
        mode_dc ?
            (runmode == 2'b00) ? (k_eq_4 ? 3'd1 : 3'd2) :
            (runmode == 2'b01) ? (k_eq_4 ? 3'd3 : 3'd4) :
            3'd0
        :
        3'd0;

    // always @(*) begin
    //     case (count_k)
    //         3'b001:  count_r_temp = {4'b0000, cnt_out[3:0]};  // count_r[3:0] = 1 => count_r = 1
    //         3'b010:  count_r_temp = {4'b0001, cnt_out[3:0]};  // count_r[3:0] = 1 => count_r = 17
    //         3'b011:  count_r_temp = {4'b0010, cnt_out[3:0]};  // count_r[3:0] = 1 => count_r = 33
    //         3'b100:  count_r_temp = {4'b0011, cnt_out[3:0]};  // count_r[3:0] = 1 => count_r = 49
    //         default: count_r_temp = {4'b0000, cnt_out[3:0]};
    //     endcase
    // end      


    // always @(*) begin
    //     if ((gk_ena_i | ec_ena_i) & ~dc_ena_i) begin
    //         DEC_mode = 0;
    //     end
    //     else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
    //         if (k_i == 4) begin
    //             if (runmode == 2'b00) begin
    //                 DEC_mode = 1;
    //             end
    //             else if (runmode == 2'b01) begin
    //                 DEC_mode = 3;
    //             end
    //             else DEC_mode = 0;
    //         end
    //         else begin
    //             if (runmode == 2'b00) begin
    //                 DEC_mode = 2;
    //             end
    //             else if (runmode == 2'b01) begin
    //                 DEC_mode = 4;
    //             end
    //             else DEC_mode = 0;
    //         end
    //     end
    //     else DEC_mode = 0;
    // end
        
    // logic TEMP_DEBUG_0;
    // logic TEMP_DEBUG_1;
    // assign TEMP_DEBUG_0 = (NTT_runs == (k_temp << 1));
    // assign TEMP_DEBUG_1 = ((~gk_ena_i & ec_ena_i & ~dc_ena_i) | (~gk_ena_i & ec_inter_i & dc_ena_i));
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state           <= IDLE;
            done_dc         <= 1'b0;
            runmode         <= 'b0;
            dc_runtimes     <= 'b0;
            valid_decode    <= 1'b0;
            wdone_o         <= 1'b0;


            ena_o_bram      <= 1'b0;
            wea_o_bram      <= 1'b0;
            din_o_bram      <= 'b0;
            done_uncnt      <= 1'b0;
            cnt_in          <= 'd0;
            cnt_out         <= 'b0;

            count_k         <= 0;
            shift_count     <= 0;
            DC_run_check    <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (~gk_ena_i & (ec_ena_i | dc_ena_i) & wvalid_i) begin
                        state           <= WRITE;    // RUN decode t_hat + m
                        if (ec_ena_i & ~dc_ena_i) valid_decode    <= 1'b1;
                        else if (~ec_ena_i & dc_ena_i)  valid_decode    <= 1'b0;
                        ena_o_bram      <= 1'b1;
                        wea_o_bram      <= 1'b1;
                        din_o_bram      <= din_i_bram;
                    end
                    // else  if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                    //     state   <= DECAP;    // RUN decode DECAP
                    // end
                end
                WRITE:  begin
                    if (done_input_i & (~gk_ena_i & ec_ena_i & ~dc_ena_i)) begin
                        state   <= READWAIT;
                    end
                    else if (~wvalid_i & (~gk_ena_i & ~ec_ena_i & dc_ena_i) ) begin
                        state   <= READDCNTT;
                        DC_run_check <= 1'b1;
                    end
                    
                    if (wvalid_i & (~gk_ena_i & ec_ena_i & ~dc_ena_i)) begin
                        if (cnt_in == uncnt_start_c2 & done_uncnt) begin
                            wea_o_bram  <= 1'b0;
                        end
                        else if (cnt_in == uncnt_end_c1 & ~done_uncnt) begin
                            wea_o_bram  <= 1'b0;
                            done_uncnt  <= 1'b1;
                        end
                        else begin
                            wea_o_bram  <= 1'b1;
                        end
                        cnt_in      <= cnt_in + 1;
                        din_o_bram  <= din_i_bram;
                    end
                    else if (wvalid_i & (~gk_ena_i & ~ec_ena_i & dc_ena_i)) begin
                        wea_o_bram  <= 1'b1;
                        cnt_in      <= cnt_in + 1;
                        din_o_bram  <= din_i_bram;
                    end
                    else wea_o_bram  <= 1'b0;

                    if ((cnt_in == uncnt_end_c1) | (cnt_in == uncnt_end_c2)) begin
                        runmode <= runmode + 1;
                    end
                    else begin
                        runmode <= runmode;
                    end
                end
                READWAIT:begin
                    if ((NTT_runs == (k_temp << 1)) & (~gk_ena_i & (ec_ena_i | ec_inter_i) & ~dc_ena_i)) begin
                        if (NTT_done_compute) begin
                            state <= READ;
                            valid_decode    <= 1'b0;
                            count_k <= count_k + 1;
                            if (ec_inter_i & done_dc) begin
                                cnt_out <= 0; 
                                shift_count <= uncnt_ek;
                            end
                        end
                    end
                    // else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                    //     if (dc_runtimes[0]) begin 
                    //         state <= READDCV;                    //     end
                    //     else if (~dc_runtimes[0] & NTT_done_one & (NTT_runs != k_temp)) begin
                    //         state <= READDCNTT;
                    //     end 
                    // end
                    else if ((NTT_runs != k_temp) & (~gk_ena_i & ~ec_ena_i & ~ec_inter_i & dc_ena_i)) begin
                        valid_decode    <= 1'b0;
                        if (NTT_done_one) begin
                            state <= READDCNTT;
                        end
                    end
                    else if ((NTT_runs == k_temp) & (~gk_ena_i & ~ec_ena_i & ~ec_inter_i & dc_ena_i)) begin
                        valid_decode    <= 1'b0;
                        if (NTT_done_one) begin
                            state <= READ;
                            count_k <= count_k + 1;
                            DC_run_check    <= 1'b1;
                            shift_count <= uncnt_mul;
                        end
                    end
                    wea_o_bram  <= 1'b0;
                    wdone_o     <= 1'b1;
                end
                READ: begin
                    if ((count_r_temp == uncnt_end_c1) & (~gk_ena_i & (ec_ena_i | ec_inter_i) & ~dc_ena_i)) begin
                        state <= DONE;
                        // valid_decode    <= 1'b0;
                    end
                    else if ((~gk_ena_i & ~ec_ena_i & dc_ena_i) & (count_r_add == uncnt_dc)) begin
                        if (dc_runtimes == (k_i-1)) begin
                            state <= READDCV;
                            cnt_out <= uncnt_start_c2;
                            valid_decode    <= 1'b0;
                        end
                        else if (dc_runtimes != (k_i-1)) begin
                            dc_runtimes <= dc_runtimes + 1;
                        end
                    end
                    else begin
                        valid_decode    <= 1'b1;
                        if (count_k == k_i) begin
                            if (&cnt_out[3:0]) begin
                                shift_count <= shift_count + 16;
                            end
                            cnt_out[3:0] <= cnt_out[3:0] + 1;
                            count_k     <= 1;
                        end
                        else count_k <= count_k + 1;
                    end
                    wea_o_bram  <= 1'b0;
                    wdone_o     <= 1'b1;
                end
                READDCNTT: begin
                    wea_o_bram  <= 1'b0; 
                    valid_decode    <= 1'b1;
                    if (&cnt_out[3:0]) begin
                        state <= READWAIT;
                        // valid_decode    <= 1'b0;
                        // dc_runtimes <= dc_runtimes + 1;
                        
                    end
                    cnt_out <= cnt_out + 1;
                end
                READDCV:  begin
                    wea_o_bram  <= 1'b0; 
                    valid_decode    <= rvalid_i;
                    if (&cnt_out[3:0]) begin
                        state <= DONE;
                        // valid_decode    <= 1'b0;
                        dc_runtimes <= dc_runtimes + 1;
                    end
                    if (rvalid_i) cnt_out <= cnt_out + 1;
                    wdone_o     <= 1'b1;
                end
                DONE: begin
                    valid_decode    <= 1'b0;
                    wdone_o         <= 1'b1;
                    if (~dc_ena_i & ~done_dc) begin
                        state <= READWAIT;
                        count_k <= 0;
                        done_dc <= 1'b1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

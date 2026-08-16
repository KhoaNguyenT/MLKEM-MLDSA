module Controller_BRAM_NTT #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
) (    
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,

    output  reg                         ena_o,
    output  reg                         wea_o,
    output  wire    [ADDR_WIDTH-1:0]    addr_o,
    output  wire    [DATA_WIDTH-1:0]    data_o,
    
    input   wire    [3:0]               NTT_runs,
    input   wire                        next_i,
    input   wire                        NTT_done_compute,
    output  wire                        stop_o,
    output  reg                         add_signal,
    output  reg                         valid_o,
    output  reg                         done_o
);
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
    localparam  IDLE  = 2'b00;
    localparam  WDATA = 2'b01;
    localparam  RDATA = 2'b10;
    localparam  DONE  = 2'b11;


/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg     [1:0]               state;
    wire    [7:0]               k_temp;
    wire    [7:0]               NTT_runs_temp;
    wire    [7:0]               shift_temp;
    reg     [ADDR_WIDTH-1:0]    count_w;
    wire    [ADDR_WIDTH-1:0]    count_w_temp;
    reg     [ADDR_WIDTH-1:0]    count_r;
    wire    [ADDR_WIDTH-1:0]    count_r_temp;
    reg     [2:0]               count_k;
    // wire                        add_signal; // 0: Mul, 1 : add;
    reg                         done_round;     // use for Mul
    reg     [2:0]               runs;     // use for Mul
    wire    [ADDR_WIDTH-1:0]    max_k;
    wire    [ADDR_WIDTH-1:0]    max_k_add;
    wire    [ADDR_WIDTH-1:0]    max_k_2;
    wire    [ADDR_WIDTH-1:0]    shift_add;
    reg     [DATA_WIDTH-1:0]    data_reg;

    

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  k_temp          = {5'b0, k_i};
    assign  NTT_runs_temp   = {4'b0, NTT_runs};
    // assign  shift_temp      = (k_i == 2)        ?   8'd63
    //                         : (k_i == 3)        ?   8'd143
    //                         : (k_i == 4)        ?   8'd255
    //                         : 0;
    // assign  shift_temp      = (gk_ena_i & ~ec_ena_i) ? (NTT_runs_temp - k_temp - 1) << (k_i + 3) : 0;

    assign  addr_o          = (state == WDATA) ? count_w
                            : ((state == RDATA) | (state == DONE)) ? ((add_signal) ? count_r : count_r_temp)
                            : 0;

    assign  count_w_temp    = {count_w[3:0], count_w[7:4]};

    assign  max_k           = (k_i == 2)        ?   8'd31
                            : (k_i == 3)        ?   8'd47
                            : (k_i == 4)        ?   8'd63
                            : 0;
    assign  max_k_add       = (k_i == 2)        ?   8'd32
                            : (k_i == 3)        ?   8'd48
                            : (k_i == 4)        ?   8'd64
                            : 0;
    assign  max_k_2         = (k_i == 2)        ?   8'd63
                            : (k_i == 3)        ?   8'd95
                            : (k_i == 4)        ?   8'd127
                            : 0;
    // assign  shift_add       = (k_i == 2)        ?   8'd32
    //                         : (k_i == 3)        ?   8'd48
    //                         : (k_i == 4)        ?   8'd64
    //                         : 0;
    assign  data_o          = (wea_o)           ?   data_reg
                            : 0;

    assign  stop_o          = (~gk_ena_i & ec_ena_i) ? done_round : 1'b0;                       
// always @(*) begin
//     case (count_k)
//         3'b001:  count_r_temp = {4'b0000, count_r[3:0]};  // count_r[3:0] = 1 => count_r = 1
//         3'b010:  count_r_temp = {4'b0001, count_r[3:0]};  // count_r[3:0] = 1 => count_r = 17
//         3'b011:  count_r_temp = {4'b0010, count_r[3:0]};  // count_r[3:0] = 1 => count_r = 33
//         3'b100:  count_r_temp = {4'b0011, count_r[3:0]};  // count_r[3:0] = 1 => count_r = 49
//         default: count_r_temp = {4'b0000, count_r[3:0]};
//     endcase
// end                     
wire [2:0] temp_sub;
assign temp_sub     = count_k - 3'd1;
assign count_r_temp = {1'b0, temp_sub, count_r[3:0]};    
// always @(*) begin
//     case (count_k)
//         3'b001:  count_r_temp = {4'b0000, count_r[3:0]} + shift_temp;  // count_r[3:0] = 1 => count_r = 1
//         3'b010:  count_r_temp = {4'b0001, count_r[3:0]} + shift_temp;  // count_r[3:0] = 1 => count_r = 17
//         3'b011:  count_r_temp = {4'b0010, count_r[3:0]} + shift_temp;  // count_r[3:0] = 1 => count_r = 33
//         3'b100:  count_r_temp = {4'b0011, count_r[3:0]} + shift_temp;  // count_r[3:0] = 1 => count_r = 49
//         default: count_r_temp = {4'b0000, count_r[3:0]} + shift_temp;
//     endcase
// end          
    // assign count_r_temp     = count_r;                
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
always @(posedge clk_i) begin
    if (rst_i) begin
        state           <= IDLE;
        count_w         <= 8'd255;
        count_r         <= 0;
        count_k         <= 1;
        add_signal      <= 0;
        ena_o           <= 0;
        wea_o           <= 0;
        data_reg        <= 0;
        valid_o         <= 0;
        done_o          <= 0;
        done_round      <= 0;
        runs            <= 0;
        // shift_temp      <= 0;
    end
    else begin
        case (state)
            IDLE:  begin
                if (ena_i) begin 
                    state   <= WDATA;
                    ena_o   <= 1'b1;
                end
            end
            WDATA: begin
                if (valid_i) begin  // Valid => write
                    wea_o    <= 1'b1;
                    data_reg <= data_i;
                    count_w <= count_w + 1;
                end
                else wea_o   <= 1'b0;
                // if ((gk_ena_i & ~ec_ena_i & ~dc_ena_i) & (count_w == max_k)) begin // GENKEY go to read state
                if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin // GENKEY go to read state
                    if (k_i == 2) begin
                        if (count_w == max_k) begin
                            state   <= RDATA;
                        end
                    end
                    else if (k_i != 2) begin
                        if (count_w == max_k_2) begin
                            state   <= RDATA;
                        end
                    end
                    
                end
                else if ((~gk_ena_i & ec_ena_i & ~dc_ena_i) & (count_w == max_k) & next_i) begin // Encap go to read state
                    state   <= RDATA;
                end
                else if ((~gk_ena_i & ~ec_ena_i & dc_ena_i) & (count_w == max_k)) begin // Decap go to read state
                    state   <= RDATA;
                end
                else state   <= WDATA;
            end
            RDATA: begin
                wea_o    <= 1'b0;
                valid_o  <= ~stop_o;
                // if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                if (((count_r == max_k_2) & add_signal) | ((count_r_temp == max_k) & ~add_signal)) begin
                    if ((gk_ena_i & ~ec_ena_i & ~dc_ena_i) & (runs == k_i-1)) begin
                        state   <= DONE;
                        // add_signal  <= ~add_signal;
                    end
                    else if (done_round & (~gk_ena_i & ec_ena_i & ~dc_ena_i) & (runs == k_i)) begin 
                        state   <= DONE;
                    end
                    else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                        state   <= DONE;
                        add_signal <= 1'b1;
                    end
                    else begin
                        runs    <= runs + 1;
                        count_k <= 1;
                        done_round  <= 1;
                        count_r <= 0;
                    end
                end
                else begin
                    if (add_signal & next_i & ~stop_o) begin // (in GENKEY data from NTT directly go to ADD - not use)
                        count_r <= count_r + 1;
                    end
                    else if (~add_signal & (next_i | dc_ena_i) & ~stop_o) begin // GENKEY mul
                        if (count_k == k_i) begin
                            count_r[3:0] <= count_r[3:0] + 1;
                            count_k     <= 1;
                        end
                        else count_k <= count_k + 1;
                    end
                    else if (stop_o) begin
                        if (NTT_done_compute) begin
                            done_round  <= 0;
                        end
                        count_r <= count_r;
                        count_k <= count_k;
                    end
                    state   <= RDATA;
                end
            end
            DONE:  begin
                valid_o <= 1'b0;
                //
                if (~add_signal & ~done_o & (k_i != 2)) begin
                    add_signal  <= 1'b1;
                    count_r <= max_k_add;
                    state       <= RDATA;
                end
                else begin 
                    done_o      <= 1'b1;
                    add_signal  <= 1'b0;
                end
                //
                // done_o      <= 1'b1; 
            end
            default: state   <= IDLE;
        endcase
    end
end
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/
endmodule

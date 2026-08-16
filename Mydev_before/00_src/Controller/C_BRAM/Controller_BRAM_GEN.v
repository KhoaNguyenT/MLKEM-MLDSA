module Controller_BRAM_GEN #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
) (    
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,

    output  reg                         ena_o,
    output  reg                         wea_o,
    output  wire    [ADDR_WIDTH-1:0]    addr_o,
    output  wire    [DATA_WIDTH-1:0]    data_o,
    
    input   wire    [4:0]               GEN_runs,
    input   wire                        next_i,
    input   wire                        stop_i,
    output  wire                        valid_o,
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
    wire    [7:0]               GEN_runs_temp;
    wire    [7:0]               shift_temp;
    reg     [ADDR_WIDTH-1:0]    count_w;
    wire    [ADDR_WIDTH-1:0]    count_w_temp;
    reg     [ADDR_WIDTH-1:0]    count_r;
    wire    [ADDR_WIDTH-1:0]    count_r_temp;
    reg     [2:0]               count_k;
    reg     [ADDR_WIDTH-1:0]    count_shift;
    reg                         add_signal; // 0: Mul, 1 : add;
    wire    [ADDR_WIDTH-1:0]    max_k;
    reg     [DATA_WIDTH-1:0]    data_reg;

    

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  k_temp          = {5'b0, k_i};
    assign  GEN_runs_temp   = {3'b0, GEN_runs};
    assign  shift_temp      = (k_i == 2)        ?   8'd32
                            : (k_i == 3)        ?   8'd48
                            : (k_i == 4)        ?   8'd64
                            : 0;

    assign  addr_o          = (state == WDATA) ? count_w
                            : (state == RDATA) ? ((add_signal) ? count_r : count_r_temp)
                            : 0;

    assign  count_w_temp    = {count_w[3:0], count_w[7:4]};

    assign  max_k           = (k_i == 2)        ?   8'd63
                            : (k_i == 3)        ?   8'd143
                            : (k_i == 4)        ?   8'd255
                            : 0;

    assign  data_o          = (wea_o)           ?   data_reg
                            : 0;
// always @(*) begin
//     case (count_k)
//         3'b001:  count_r_temp = {4'b0000, count_r[3:0]} + count_shift;  // count_r[3:0] = 1 => count_r = 1
//         3'b010:  count_r_temp = {4'b0001, count_r[3:0]} + count_shift;  // count_r[3:0] = 1 => count_r = 17
//         3'b011:  count_r_temp = {4'b0010, count_r[3:0]} + count_shift;  // count_r[3:0] = 1 => count_r = 33
//         3'b100:  count_r_temp = {4'b0011, count_r[3:0]} + count_shift;  // count_r[3:0] = 1 => count_r = 49
//         default: count_r_temp = {4'b0000, count_r[3:0]} + count_shift;
//     endcase
// end               
    wire [2:0] temp_sub;
    assign temp_sub = (count_k - 3'd1);   // 3-bit subtract rất nhỏ            
    
    assign count_r_temp = {1'b0, temp_sub, count_r[3:0]} + count_shift;
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
        count_shift     <= 0;
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
                    // if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                    count_w <= count_w + 1;
                    // end
                    // else if (~gk_ena_i & ec_ena_i) begin // ENCAP (be used in DOT)
                    //     if (&count_w[7:4]) begin
                    //         count_w[7:4] <= 0;
                    //         count_w[3:0] <= count_w[3:0] + 1;
                    //     end
                    //     else begin
                    //         count_w[7:4] <= count_w[7:4] + 1;
                    //     end
                    // end
                end
                else wea_o   <= 1'b0;
                if ((gk_ena_i & ~ec_ena_i) & (count_w == max_k) & (GEN_runs_temp > k_temp)) begin // GENKEY go to read state
                    state   <= RDATA;
                end
                else if ((~gk_ena_i & ec_ena_i) & (count_w == max_k) & next_i) begin // Encap go to read state
                    state   <= RDATA;
                end
                else state   <= WDATA;
            end
            RDATA: begin
                wea_o    <= 1'b0;
                valid_o  <= ~stop_i;
                // if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                if ((count_r == count_w & add_signal) | (count_r_temp == count_w & ~add_signal)) begin
                    state   <= DONE;
                end
                else begin
                    if (add_signal & next_i & ~stop_i) begin // GENKEY add
                        count_r <= count_r + 1; 
                    end
                    else if (~add_signal & next_i & ~stop_i) begin // GENKEY mul
                        if (count_k == k_i) begin
                            count_r[3:0] <= count_r[3:0] + 1;
                            if (&count_r[3:0]) begin
                                count_shift <= count_shift + shift_temp;
                            end
                            count_k     <= 1;
                        end
                        // else if ((~gk_ena_i & ec_ena_i) & ) begin
                            
                        // end
                        else count_k <= count_k + 1;
                    end
                    else if (stop_i) begin
                        count_r <= count_r;
                        count_shift <= count_shift;
                        count_k <= count_k;
                    end
                    state   <= RDATA;
                end
            end
            //     else if (~gk_ena_i & ec_ena_i) begin
            //         if (count_r == count_w_temp) begin
            //             state   <= DONE;
            //         end
            //         else begin
            //             count_r <= count_r + 1'b1;
            //             state   <= RDATA;
            //         end
            //     end
            // end
            DONE:  begin
                valid_o <= 1'b0;
                add_signal  <= 1'b1;
                done_o      <= 1'b1;
                // if (~add_signal) begin
                //     state   <= RDATA;
                // end
            end
            default: state   <= IDLE;
        endcase
    end
end
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/
endmodule

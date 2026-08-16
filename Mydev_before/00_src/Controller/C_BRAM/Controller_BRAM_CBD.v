module Controller_BRAM_CBD #(
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
    input   wire                        add_valid_i,
    input   wire    [DATA_WIDTH-1:0]    add_data_i,

    output  reg                         ena_o,
    output  reg                         wea_o,
    output  wire    [ADDR_WIDTH-1:0]    addr_o,
    output  wire    [DATA_WIDTH-1:0]    data_o,
    
    input   wire    [4:0]               CBD_runs,
    input   wire                        next_i,
    input   wire                        stop_i,
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
    reg     [4:0]               runtimes;
    wire    [4:0]               k_temp;
    reg     [ADDR_WIDTH-1:0]    count_w;
    reg     [ADDR_WIDTH-1:0]    count_r;
    wire    [ADDR_WIDTH-1:0]    max_k;
    reg     [DATA_WIDTH-1:0]    data_reg;
    reg                         valid_unused;
    

/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  k_temp          = {2'b0, k_i} ;

    assign  addr_o          = (state == WDATA) ? count_w
                            : (state == RDATA) ? count_r
                            : 0;

    assign  max_k           = (k_i == 2)        ?   8'd48
                            : (k_i == 3)        ?   8'd64
                            : (k_i == 4)        ?   8'd80
                            : 0;

    assign  data_o          = (wea_o)           ?   data_reg
                            : 0;                     
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
always @(posedge clk_i) begin
    if (rst_i) begin
        state           <= IDLE;
        count_w         <= 8'd255;
        count_r         <= 0;
        runtimes        <= 0;
        ena_o           <= 0;
        wea_o           <= 0;
        data_reg        <= 0;
        valid_o         <= 0;
        done_o          <= 0;
        valid_unused    <= 0;
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
                valid_o <= 1'b0;
                if ((add_valid_i | valid_i) & valid_unused ) begin
                    valid_unused    <= 1'b1;
                end
                else valid_unused    <= 1'b0;
                if ((~gk_ena_i & ec_ena_i) & (CBD_runs > k_temp) & ~valid_unused) begin
                    if (runtimes == k_temp) begin
                        if (add_valid_i) begin
                            wea_o    <= 1'b1;
                            data_reg <= add_data_i;
                            count_w <= count_w + 1;
                        end
                        else wea_o   <= 1'b0;
                    end
                    else begin
                        if (valid_i) begin  // Valid => write
                            wea_o    <= 1'b1;
                            data_reg <= data_i;
                            count_w <= count_w + 1;
                        end
                        else wea_o   <= 1'b0;
                    end
                end
                if ((~gk_ena_i & ec_ena_i) & (count_w == 8'd15)) begin // Encap go to read state
                    state   <= RDATA;
                end
                else state   <= WDATA;
            end
            RDATA: begin
                if (add_valid_i | valid_i) begin
                    valid_unused    <= 1'b1;
                end
                else valid_unused    <= 1'b0;
                wea_o    <= 1'b0;
                valid_o  <= ~stop_i;
                if (count_r == count_w) begin
                    if (runtimes == k_temp) begin
                        state       <= DONE;
                    end
                    else begin
                        count_r     <= 0;
                        count_w     <= 8'd255;
                        runtimes    <= runtimes + 1;
                        state       <= WDATA;
                    end
                end
                else begin
                    if (next_i) begin
                        count_r <= count_r + 1;
                    end
                    state   <= RDATA;
                end
            end
            DONE:  begin
                valid_o <= 1'b0;
                done_o      <= 1'b1;
            end
            default: state   <= IDLE;
        endcase
    end
end
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/
endmodule

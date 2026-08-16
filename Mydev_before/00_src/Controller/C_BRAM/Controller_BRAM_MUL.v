module Controller_BRAM_MUL#(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
) 
( 
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,
    output  reg                         enw_o,
    output  wire    [ADDR_WIDTH-1:0]    addrin_o,
    output  reg     [DATA_WIDTH-1:0]    data_o,
    input   wire                        enr_i,
    input   wire                        enrgk_i,
    input   wire    [3:0]               NTT_runs,
    output  reg                         valid_o,
    output  wire    [ADDR_WIDTH-1:0]    addrout_o
);
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg     [ADDR_WIDTH-1:0]    count_w;
    reg     [ADDR_WIDTH-1:0]    count_r;
    reg     [ADDR_WIDTH-1:0]    count_r_gk;
    wire    [3:0]               k_temp;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign addrin_o     = (enw_o) ? count_w : 0;
    assign addrout_o    = (enr_i) ? count_r 
                        : (enrgk_i & (k_i != 2)) ? count_r_gk
                        : 0;
    assign k_temp       = {1'b0, k_i};

/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
always @(posedge clk_i) begin
    if (rst_i) begin
        // state_w     <=  IDLE;
        count_w     <= 0;
        data_o      <= 0;
        enw_o       <= 0;
    end
    else begin
        if (ena_i) begin
            if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                if (valid_i) begin
                    data_o  <= data_i;
                    count_w <= count_w + 1;
                    enw_o   <= 1;
                end
                else begin
                    data_o  <= 0;
                    count_w <= count_w;
                    enw_o   <= 0;
                end
            end
        end
        else begin
            data_o  <= 0;
            count_w <= 8'd255;
            enw_o   <= 0;
        end
    end
end
always @(posedge clk_i) begin
    if (rst_i) begin
        // state_w     <=  IDLE;
        count_r     <=  8'd255;
        count_r_gk  <=  8'd255;
        valid_o     <=  0;
    end
    else begin
        if (ena_i) begin
            if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                if (enr_i & ~enrgk_i & (NTT_runs > k_temp)) begin
                    count_r     <= count_r + 1;
                    valid_o     <= 1;
                end
                else if (~enr_i & enrgk_i) begin
                    count_r_gk  <= count_r_gk + 1;
                    valid_o <= 1;
                end
                else begin
                    count_r     <= count_r;
                    count_r_gk  <= count_r_gk;
                end
            end
        end
        else begin
            valid_o     <= 0;
            count_r     <= 0;
            count_r_gk  <= 0;
        end
    end
end
endmodule

module Controller_BRAM_INDC #(
    parameter ADDR_WIDTH = 8
) (
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        wdone_i,
    input   wire                        wvalid_i,
    input   wire                        rvalid_i,
    // input   logic   [DATA_WIDTH-1:0]    data_i,

    output  wire                        ena_o,
    output  wire                        wea_o,
    output  wire    [ADDR_WIDTH-1:0]    addr_o,
    // output  logic   [DATA_WIDTH-1:0]    data_o,
    
    input   wire                        next_i,
    output  reg                         valid_o,
    output  reg                         done_temp,
    output  reg                         done_o,

    input   wire                        ENC_dc_done_i,
    input   wire                        ENC_valid_i
);
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
    localparam  IDLE  = 3'd0;
    localparam  WDATA = 3'd1;
    localparam  WWAIT = 3'd2;
    localparam  WLAST = 3'd3;
    localparam  RLAST = 3'd4;
    localparam  RDATA = 3'd5;
    localparam  RHEK  = 3'd6;
    localparam  DONE  = 3'd7;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg     [2:0]   state;
    wire            validn_data;
    reg             keccak_runs;
    reg     [7:0]   cnt_in;
    reg     [7:0]   cnt_out;
    reg             cnt_Hek;
    wire    [7:0]   uncut_Hek;
    wire    [7:0]   uncut_Z;
    wire    [7:0]   uncut_key_L;
    wire    [7:0]   uncut_key_H;
    wire    [7:0]   uncut_temp;
    reg             done_compare;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    assign  ena_o   =   ena_i;
    assign  wea_o   =   wvalid_i;
    assign  addr_o  =   (wea_o) ?   cnt_in  :   cnt_out;

    assign  uncut_key_L =   (k_i == 2)  ?   47
                        :   (k_i == 3)  ?   63
                        :   (k_i == 4)  ?   79
                        :   0;
    assign  uncut_key_H =   (k_i == 2)  ?   65
                        :   (k_i == 3)  ?   97
                        :   (k_i == 4)  ?   129
                        :   0;
    assign  uncut_Hek   =   (k_i == 2)  ?   48
                        :   (k_i == 3)  ?   64
                        :   (k_i == 4)  ?   80
                        :   0;
    assign  uncut_Z     =   (k_i == 2)  ?   50
                        :   (k_i == 3)  ?   66
                        :   (k_i == 4)  ?   82
                        :   0;
    assign  uncut_temp  =   (k_i == 2)  ?   33
                        :   (k_i == 3)  ?   49
                        :   (k_i == 4)  ?   65
                        :   0;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
always @(posedge  clk_i) begin
    if (rst_i) begin
        state       <= IDLE;
        keccak_runs <= 1'b0;
        cnt_in      <= 'b0;
        cnt_out     <= 'b0;
        cnt_Hek     <= 'b0;

        valid_o     <= 1'b0;
        done_temp   <= 1'b0;
        done_o      <= 1'b0;
        done_compare<= 1'b0;
    end
    else begin
        case (state)
            IDLE: begin
                if (dc_ena_i) begin
                    if (wea_o) begin
                        cnt_in  <= cnt_in + 1;
                        state   <= WDATA;
                    end
                end
                if (dc_ena_i & ENC_dc_done_i) begin
                    state   <= RDATA;
                    cnt_out <= 0;
                end
            end 
            WDATA: begin
                if (wea_o) begin
                    cnt_in  <= cnt_in + 1;
                end
                if (cnt_in == uncut_key_L) begin
                    state   <= WWAIT;
                end
            end 
            WWAIT: begin
                if (wea_o) begin
                    cnt_out  <= cnt_out + 1;
                end
                if (cnt_out == uncut_key_H) begin
                    state   <= WLAST;
                end
            end 
            WLAST: begin
                if (wea_o & ~wdone_i) begin
                    cnt_in  <= cnt_in + 1;
                end
                else begin
                    state   <= RLAST;
                    cnt_out <= uncut_Z;
                end
            end
            RLAST: begin
                if (rvalid_i & (cnt_out != cnt_in)) begin
                    valid_o <= 1;
                    cnt_out <= cnt_out + 1;
                end
                else if (cnt_out == cnt_in) begin
                    state   <= RDATA;
                    cnt_out <= 0;
                end
            end 
            RDATA: begin
                // if ((rvalid_i | (ENC_dc_done_i & ENC_valid_i)) & (cnt_out != uncut_key_L) & ((cnt_out != uncut_temp) & ~ENC_dc_done_i)) begin
                if (rvalid_i & (cnt_out != uncut_key_L) & ((cnt_out != uncut_temp) | ENC_dc_done_i)) begin
                    valid_o     <= 1;
                    cnt_out     <= cnt_out + 1;
                end
                else if ((cnt_out == uncut_temp) & ~ENC_dc_done_i) begin
                    valid_o     <= done_temp;
                    if (!done_temp) cnt_out     <= cnt_out;
                    else cnt_out     <= cnt_out + 1;
                    done_temp   <= 1'b1;
                end
                else if (cnt_out == uncut_key_L) begin
                    state   <= DONE;
                    done_o  <= 1'b1;
                end
            end 
            RHEK: begin
                done_o      <= 1'b0;
                cnt_Hek     <= 1'b1;
                // if (rvalid_i & cnt_Hek[1]) begin
                if (next_i & ~cnt_Hek) begin
                    valid_o <= 1;
                    cnt_out <= cnt_out + 1;
                end
                else if (cnt_Hek) begin
                    state   <= DONE;
                    done_o  <= 1'b1;
                end
            end 
            DONE: begin
                valid_o     <= 0;
                if (~cnt_Hek) begin
                    done_o  <= 1'b0;
                end
                if (next_i & ~ENC_dc_done_i) begin
                    state   <= RHEK;
                    cnt_out <= uncut_Hek;
                end
                else if (ENC_dc_done_i & ~done_compare) begin
                    state   <= IDLE;
                    done_compare <= 1'b1;
                end
                // else begin
                //     done_o      <= 1'b1;
                // end
            end 
            default: state  <= IDLE; 
        endcase
    end
end
endmodule

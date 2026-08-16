module Controller_Keccak # (
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
) (
    // Clock signal
    input   wire                            clk_i,
    input   wire                            rst_i,
    // mode
    input   wire                            gk_ena_i,
    input   wire                            ec_ena_i,
    input   wire                            dc_ena_i,
    input   wire    [2:0]                   k,
    // I/O BRAM
    input   wire    [DATA_WIDTH-1:0]        din_i,
    input   wire                            valid_i,
    input   wire                            done_i,
    output  reg                             rtimes,
    output  reg                             ena_o_bram,
    output  reg                             wea_o_bram,
    output  wire    [ADDR_WIDTH-1:0]        addr_o_bram,
    output  reg     [DATA_WIDTH-1:0]        din_o_bram,
    // I/O Keccak
    input   wire                            next_i,
    input   wire                            ready_i,
    output  reg                             ena_o,
    output  reg     [1:0]                   mode_o,         // 0 => 512, 1 => 256, 2 => 128
    output  reg                             SHA_o,          // 0 => SHA, 1 => SHAKE
    output  reg                             valid_o,
    output  reg     [7:0]                   ldata_o, 
    output  reg                             last_o,
    output  reg                             lmode_o,        // -> the number of last bytes
    output  reg                             rst_o_Keccak,
    // I/O Controll
    input   wire                            ena_i,
    output  reg                             rvalid_indc_o,
    output  wire    [2:0]                   status_o
);
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE = 3'b000;
localparam NEXT = 3'b001;
localparam LAST = 3'b010;
localparam DOUT = 3'b011;
localparam BRAM = 3'b100;

localparam FIRST  = 1'b0;
localparam SECOND = 1'b1;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    // BRAM in
    reg     [ADDR_WIDTH-1:0]    cnt_in;
    reg     [ADDR_WIDTH-1:0]    cnt_out;
    // logic                       ena_bram;
    // logic                       wea_bram;
    // logic   [ADDR_WIDTH-1:0]    addr_o_bram;
    // logic   [DATA_WIDTH-1:0]    din_bram;
    // CONTROLL
    reg     [2:0]               state;
    // logic                       rtimes;
    reg                         next_last;
    reg                         done_bram;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
    // BRAM in
    assign  addr_o_bram   =   (wea_o_bram) ? cnt_in : cnt_out;
    // CONTROLL
    assign  status_o    =   state;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/

    always @(posedge clk_i) begin : CONTROL_BLOCK
        if (rst_i) begin
            //  BRAM
            cnt_in          <= 'b0;
            cnt_out         <= 'b0;
            ena_o_bram      <= 'b0;
            wea_o_bram      <= 'b0;
            din_o_bram      <= 'b0;
            //  CONTROLL    
            state           <= IDLE;
            rtimes          <= FIRST;
            next_last       <= 'b0;
            done_bram       <= 'b0;
            //  Output  
            ena_o           <= 'b0;
            mode_o          <= 'b0; 
            SHA_o           <= 'b0;  
            valid_o         <= 'b0;
            ldata_o         <= 'b0;
            last_o          <= 'b0;
            lmode_o         <= 'b0;
            rst_o_Keccak    <= 'b0;
            // I/O
            rvalid_indc_o   <= 'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    rst_o_Keccak    <= 1'b0;
                    rvalid_indc_o   <= ~done_bram;
                    if (~ena_i & ~done_bram & valid_i) begin // BRAM
                        ena_o_bram  <= 1'b1;
                        wea_o_bram  <= 1'b1;
                        din_o_bram  <= din_i;
                        state       <= BRAM;
                        // rvalid_indc_o   <= dc_ena_i;
                    end
                    else if (ena_i) begin
                        ena_o_bram  <= 1'b1;
                        wea_o_bram  <= 1'b0;
                        ena_o       <= 1'b1;
                        valid_o     <= 1'b1;
                        if (gk_ena_i & ~ec_ena_i) begin // GENKEY
                            if (rtimes == FIRST) begin // SHA512
                                mode_o  <= 2'b00;
                                SHA_o   <= 1'b1;
                                ldata_o <= {5'b0, k};
                                lmode_o <= 1'b1;
                                state   <= LAST;
                            end
                            else if (rtimes == SECOND) begin // SHA256
                                mode_o  <= 2'b01;
                                SHA_o   <= 1'b1;
                                ldata_o <= 8'b0000_0000;
                                lmode_o <= 1'b0;
                                state   <= NEXT;
                            end
                        end
                        else if (~gk_ena_i & ec_ena_i) begin // ENCAP
                            if (rtimes == FIRST) begin // SHA256
                                mode_o  <= 2'b01;
                                SHA_o   <= 1'b1;
                                ldata_o <= 8'b0000_0000;
                                lmode_o <= 1'b0;
                                state   <= NEXT;
                            end
                            else if (rtimes == SECOND) begin // SHA512
                                mode_o  <= 2'b00;
                                SHA_o   <= 1'b1;
                                ldata_o <= 8'b0000_0000;
                                lmode_o <= 1'b0;
                                state   <= NEXT;
                            end
                        end
                        else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                            if (rtimes == FIRST) begin // SHAKE256
                                mode_o  <= 2'b01;
                                SHA_o   <= 1'b0;
                                ldata_o <= 8'b0000_0000;
                                lmode_o <= 1'b0;
                                state   <= NEXT;
                            end
                            else if (rtimes == SECOND) begin // SHA512
                                mode_o  <= 2'b00;
                                SHA_o   <= 1'b1;
                                ldata_o <= 8'b0000_0000;
                                lmode_o <= 1'b0;
                                state   <= NEXT;
                            end
                        end
                    end
                end 
                NEXT: begin
                    valid_o  <= next_i;
                    if (next_i) begin
                        cnt_out     <= cnt_out + 1;
                        state       <= NEXT;
                    end
                    else if (~next_i) begin
                        // if ((gk_ena_i & ~ec_ena_i) & (cnt_out == cnt_in - 1)) begin
                        if ((gk_ena_i | dc_ena_i) & (cnt_out == cnt_in - 1)) begin
                            state       <= LAST;
                            next_last   <= 1'b0;
                        end
                        else if (~gk_ena_i & ec_ena_i) begin
                            if ((cnt_out == cnt_in - 3) & (rtimes == FIRST)) begin
                                state       <= LAST;
                                next_last   <= 1'b0;
                            end
                            else if ((cnt_out == cnt_in - 1) & (rtimes == SECOND)) begin
                                state       <= LAST;
                                next_last   <= 1'b0;
                            end
                        end
                    end
                end 
                LAST: begin
                    valid_o  <= next_i;
                    if (next_i) begin
                        if (~next_last) begin
                            last_o      <= 1'b0;
                            next_last   <= 1'b1;
                            cnt_out     <= cnt_out + 1;
                            state       <= LAST;
                        end
                        else if (next_last) begin
                            last_o      <= 1'b1;
                            next_last   <= 1'b0;
                            state       <= DOUT;
                        end
                    end
                end 
                DOUT: begin
                    rvalid_indc_o   <= 1'b0;
                    last_o  <= 1'b0;
                    valid_o <= 1'b0;
                    if (ready_i) begin
                        if (rtimes == FIRST) begin
                            rtimes <= SECOND;
                            state  <= BRAM;
                            cnt_out     <= 'b0;
                            if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                                cnt_in      <= 8'd255;
                                cnt_out     <= 'b0;
                            end
                            else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                                cnt_in      <= cnt_in;
                                // cnt_out     <= cnt_out;
                                cnt_out     <= cnt_out + 1;
                            end
                            else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                                cnt_in      <= 8'd255;
                                // cnt_out     <= cnt_out;
                                cnt_out     <= 0;
                            end
                        end 
                        else state       <= IDLE;
                    end
                    else begin
                        state       <= DOUT;
                    end
                end 
                BRAM: begin
                    rst_o_Keccak    <= 1'b1;
                    if (valid_i) begin
                        wea_o_bram  <= 1'b1;
                        din_o_bram  <= din_i;
                        cnt_in      <= cnt_in + 1;
                    end
                    else begin
                        cnt_in      <= cnt_in;
                    end
                    
                    if (done_i) begin
                        done_bram   <= 1'b1;
                        state   <= IDLE;
                    end
                    else begin
                        state       <= BRAM;
                    end
                end 
                default: state  <= IDLE;
            endcase
        end
    end


/*****************************************************************************
*                              Internal Modules                              *
*****************************************************************************/
    // BRAM # (
    //     .DATA_WIDTH(DATA_WIDTH),
    //     .ADDR_WIDTH(ADDR_WIDTH)
    // ) BRAM_inst (
    //     .clk (clk_i),
    //     .ena (ena_bram ),
    //     .wea (wea_bram ),
    //     .addr(addr_bram),
    //     .din (din_bram ),
    //     .dout(dout),
    // );
endmodule

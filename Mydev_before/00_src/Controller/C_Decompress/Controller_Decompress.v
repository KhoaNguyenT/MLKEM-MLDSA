module Controller_Decompress # (
    parameter DATA_WIDTH = 192
    // parameter ADDR_WIDTH = 8
) (
    //  controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire    [4:0]               CBD_runs,
    //  DECODE to DECOMPRESS
    //  DECOMPRESS  M
    input   wire                        valid_m_i,
    input   wire    [DATA_WIDTH-1:0]    coeff_m_i,
    output  reg                         ena_m_o,
    output  reg     [263:0]             coeff_m_o,
    output  reg                         valid_o,
    // output  logic   [DATA_WIDTH-1:0]    coeff_o,

    
    // output  logic                       valid_o,

    input   wire                        valid_m_o,
    output  reg     [2:0]               runs
);  
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE     = 2'b00;
localparam EDCP     = 2'b01;
localparam DDCP     = 2'b10;
localparam DONE     = 2'b11;   
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    reg     [1:0]           state;
    reg     [263:0]         m_reg;
    wire    [4:0]           k_temp;
    wire    [5:0]           k_max;
    reg                     runs_e_ki;
    reg     [5:0]           cnt;
    assign  k_temp  = (k_i == 2)    ?   5'd5
                    : (k_i == 3)    ?   5'd7
                    : (k_i == 4)    ?   5'd9
                    : 0;
    assign  k_max   = (k_i == 2)    ?   6'd30
                    : (k_i == 3)    ?   6'd46
                    : (k_i == 4)    ?   6'd62
                    : 0;
                    
    // assign  runs    = cnt == k_max;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state       <= IDLE;
            ena_m_o     <= 0;
            coeff_m_o   <= 0;
            m_reg       <= 0;
            // valid_m_o   <= 0;
            valid_o     <= 0;
            // coeff_o     <= 0;
            runs        <= 0;
            runs_e_ki   <= 0;
            cnt         <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (valid_m_i & (ec_ena_i & ~dc_ena_i)) begin
                        state           <= EDCP;
                        m_reg[263:72]   <= coeff_m_i;
                    end
                    else if (valid_m_i & (~ec_ena_i & dc_ena_i)) begin
                        state           <= DDCP;
                        coeff_m_o[191:0]    <= coeff_m_i;
                        coeff_m_o[255:192]  <= 0;
                        valid_o             <= 1;
                    end
                end
                EDCP: begin
                    if (valid_m_i & ~(|m_reg[63:0])) begin
                        state       <= EDCP;
                        m_reg[71:0] <= coeff_m_i[191:120];
                    end
                    else if (CBD_runs == (k_temp)) begin
                        ena_m_o     <= 1;
                        coeff_m_o   <= m_reg;
                        state       <= DONE;
                        // valid_m_o   <= 1;
                    end
                end 
                DDCP: begin
                    if (~valid_m_i) begin
                        if (runs == k_i) begin
                            if (runs_e_ki) begin
                                runs        <= runs + 1;
                            end
                            else runs_e_ki  <= 1'b1;
                        end
                        else runs        <= runs + 1;
                        state       <= IDLE;
                        coeff_m_o   <= 0;
                        valid_o     <= 0;
                    end
                    else begin
                        cnt                 <= cnt + 1;
                        coeff_m_o[191:0]    <= coeff_m_i;
                        coeff_m_o[255:192]  <= 0;
                        valid_o             <= 1;
                    end
                    // if (cnt == k_max) begin
                    //     runs    <= 1;
                    // end
                end
                DONE: begin
                    if (valid_m_o) begin
                        ena_m_o     <= 0;
                        coeff_m_o   <= 0;
                    end
                end
                default: state       <= IDLE;
            endcase
        end
    end
endmodule


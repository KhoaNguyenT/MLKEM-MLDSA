module KeccakData (
    // Controller_i
    input   wire            clk_i,
    input   wire            rst_i,
    input   wire            ena_i,
    
    // Data_i
    input   wire    [255:0] data_i,
    input   wire            valid_i,
    input   wire            last_i,

    // Data_o
    output  wire    [63:0]  data_o,
    output  wire            valid_o,
    output  reg             last_o,

    // Next_io
    input   wire            perfull_i,
    input   wire            perfull_i_0,
    input   wire            perready_i,
    output  wire            next_o
);

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/

    localparam IDLE = 2'b00, SDATA = 2'b01, GDATA = 2'b10, ODATA = 2'b11;
    reg     [1:0]   state;

    reg     [1:0]   idx;
    reg     [255:0] data_i_reg;
    reg             last_i_reg;
    reg             perready_i_reg;
    reg             next_o_reg;
    reg             valid_reg;
    // logic           temp_debug;
    // logic           next_temp;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    assign data_o   = data_i_reg[(idx*64) +: 64];
    assign valid_o  = ((|data_o) | last_o) ? valid_reg : 1'b0;
    assign next_o = ((idx == 2'b01) & perfull_i_0)              ? perready_i_reg 
                   :((idx == 2'b00) & next_o_reg)               ? perready_i
                   :((idx == 2'b01) | (state == IDLE & !rst_i)) ? !last_i_reg 
                   : 1'b0; 

    // assign next_temp = ((idx == 2'b11) | (state == IDLE)) ? 1'b1 : 1'b0; 

    
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state           <= IDLE;

            data_i_reg      <= 0;
            idx             <= 0;
            valid_reg         <= 0;
            last_o          <= 0;
            last_i_reg      <= 0;
            perready_i_reg  <= 0;
            next_o_reg      <= 0;
            // temp_debug      <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (valid_i | ena_i) begin 
                        state <= GDATA;
                    end
                end
                SDATA: begin
                    if ((idx == 2'b01) && (perfull_i_0 ^ perfull_i) && !last_i_reg) begin
                        next_o_reg  <= 1'b1;
                    end
                    else if (next_o) begin
                        next_o_reg  <= 1'b0;
                    end
                    perready_i_reg  <= perready_i;
                    valid_reg <= 1'b1;
                    // idx         <= idx - 2'b01;
                    casez ({perfull_i, (last_i_reg && !(|idx)), ((next_o) && !last_i_reg)})
                        3'b10?: begin
                            idx         <= idx;
                            last_o      <= 1'b0;
                            if (next_o) begin
                                state   <= GDATA;
                            end
                            else state       <= state;
                        end 
                        3'b?1?: begin
                            // temp_debug <= 1;
                            // valid_reg <= 1'b1;
                            if ((perfull_i_0 ^ perready_i) & (|data_i_reg[191:0])) begin
                                idx     <= idx;  
                                last_o  <= 1'b0;
                                state   <= state;
                            end
                            else begin
                                idx     <= idx - 2'b01;
                                last_o  <= 1'b1;
                                state   <= ODATA;
                            end
                        end 
                        3'b001: begin
                            idx     <= idx - 2'b01;
                            last_o  <= 1'b0;
                            state   <= GDATA;
                        end
                        3'b000: begin
                            idx     <= idx - 2'b01;
                            // valid_reg <= 1'b1;
                            last_o  <= 1'b0;
                            state   <= state;
                        end
                        default: idx     <= idx - 2'b01;
                    endcase
                end
                GDATA: begin
                    data_i_reg  <= data_i;
                    idx         <= idx - 2'b01;
                    valid_reg   <= 1'b1;
                    last_i_reg  <= last_i;
                    state       <= SDATA;
                end
                ODATA: begin
                    // temp_debug <= 0;
                    last_o      <= 1'b0;
                    valid_reg     <= 1'b0;
                end
                default: state  <= state;
            endcase
        end
    end

endmodule

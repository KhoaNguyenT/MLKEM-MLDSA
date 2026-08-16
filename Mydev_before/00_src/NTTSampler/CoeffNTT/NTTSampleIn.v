module NTTSampleIn (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire    [1343:0]    data_i,
    input   wire                valid_i,
    output  wire    [47:0]      data_o,
    output  reg                 valid_o,
    output  wire                done_o
);

    localparam IDLE = 1'b0, RUN = 1'b1;

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/

    reg                 state;
    reg     [1343:0]    buffer;
    reg     [4:0]       idx;
    
    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign data_o = buffer[(idx*48) +: 48];
    assign done_o = ((state == IDLE) & !rst_i) ? 1'b1: 1'b0;
    
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            state       <= IDLE;
            buffer      <= 0;
            idx         <= 5'd27;
            valid_o     <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (valid_i) begin
                        buffer  <= data_i;
                        valid_o <= 1'b1;
                        idx     <= 5'd27;
                        state   <= RUN;
                    end
                    else valid_o <= 1'b0;
                end
                RUN: begin
                    if (!(|idx)) begin
                        idx     <= idx;
                        valid_o <= 1'b0;
                        state   <= IDLE;
                    end
                    else idx     <= idx - 5'd1;
                end
                default: state <= state;
            endcase
        end
    end
endmodule

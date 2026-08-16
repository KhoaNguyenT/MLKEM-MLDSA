module CBDSampleIn (
    input   wire               clk_i,
    input   wire               rst_i,
    input   wire               eta_i,
    input   wire   [1087:0]    data_i,
    input   wire               valid_i,
    output  wire   [95:0]      data_o,
    output  reg                valid_o,
    output  wire               done_o
);

    localparam IDLE = 1'b0, RUN = 1'b1;

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/

    reg    [1087:0]    buffer;
    reg    [31:0]      toggle_buffer;
    reg                toggle;

    reg    [4:0]       idx2;
    reg    [3:0]       idx3;
    reg                state;
    
    reg               valid_i_reg;
    wire   [63:0]      data_2;
    wire   [95:0]      data_3;
    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign data_2 = buffer[((idx2*64)) +: 64];
    assign data_3 = buffer[((idx3*96)) +: 96];
    assign data_o = (eta_i) ? data_3: {32'b0, data_2};
    // assign done_o = ((state == IDLE) & !rst_i & valid_i_reg) ? 1'b1: 1'b0;
    assign done_o = ((state == RUN) & !rst_i & valid_i_reg) ? 1'b1: 1'b0;
    
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            buffer          <= 0;
            state           <= IDLE;
            idx3            <= 4'd10;
            idx2            <= 5'd16;

            valid_o         <= 0;
            valid_i_reg     <= 0;
            toggle          <= 0;
            toggle_buffer   <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (valid_i) begin
                        valid_i_reg <= 1'b1;
                        if (eta_i) begin
                            if (~toggle) begin
                                buffer[1055:0]  <= data_i[1087:32];
                                toggle_buffer   <= data_i[31:0];
                                toggle          <= ~toggle;
                            end
                            else if (toggle) begin
                                buffer[1055:0]  <= {toggle_buffer, data_i[1087:64]};
                                toggle_buffer   <= 32'b0;
                                toggle          <= ~toggle;
                            end
                        end
                        else begin
                            buffer  <= data_i;
                        end
                        valid_o     <= 1'b1;
                        idx2        <= 5'd16;
                        idx3        <= 4'd10;
                        state       <= RUN;
                    end
                    else valid_o <= 1'b0;
                end
                RUN: begin
                    valid_i_reg <= 1'b0;
                    if (eta_i) begin
                        if (!(|idx3)) begin
                            idx3    <= idx3;
                            valid_o <= 1'b0;
                            state   <= IDLE;
                        end
                        else idx3   <= idx3 - 4'd1;
                    end
                    else begin
                        if (!(|idx2)) begin
                            idx2    <= idx2;
                            valid_o <= 1'b0;
                            state   <= IDLE;
                        end
                        else idx2   <= idx2 - 4'd1;
                    end
                end
                default: state <= state;
            endcase
        end
    end
endmodule

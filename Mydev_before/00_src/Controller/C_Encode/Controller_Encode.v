module Controller_Encode (
    //controll signal
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire                dc_ena_i,
    input   wire    [2:0]       k_i,
    input   wire    [3:0]       NTT_runs,
    output  wire    [2:0]       mode,
    output  reg     [2:0]       state,
    output  reg                 valid_encode,
    output  reg                 done_decap_o,
    input   wire                done_encode_i,
    output  reg                 done_encode_o
);
    
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE     = 3'b000;
localparam RUNGK1   = 3'b001;
localparam RUNGK2   = 3'b010; // Tuong duong RUNEC2
localparam RUNEC1   = 3'b011;
// localparam RUNEC2   = 3'b100;
localparam DONE     = 3'b111;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
// logic [1:0] state;
wire [3:0] k_temp;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
assign k_temp   = {1'b0, k_i};
// always @(*) begin
//     if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
//         mode = 0;
//     end
//     else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
//         if (k_i == 4) begin
//             if (state == RUNEC1) begin
//                 mode = 1;
//             end
//             // else if (state == RUNEC2) begin
//             else if (state == RUNGK2) begin
//                 mode = 3;
//             end
//             else mode = 0;
//         end
//         else begin
//             if (state == RUNEC1) begin
//                 mode = 2;
//             end
//             // else if (state == RUNEC2) begin
//             else if (state == RUNGK2) begin
//                 mode = 4;
//             end
//             else mode = 0;
//         end
//     end
//     else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
//         mode = 5;
//     end
//     else mode = 0;
// end
    wire mode_ec;
    wire mode_dc;
    assign mode_ec = (~gk_ena_i &  ec_ena_i & ~dc_ena_i);
    assign mode_dc = (~gk_ena_i & ~ec_ena_i &  dc_ena_i);

    wire k_eq_4;
    wire is_ec1;
    wire is_gk2;
    assign k_eq_4   = (k_i == 4);
    assign is_ec1   = (state == RUNEC1);
    assign is_gk2   = (state == RUNGK2);

    assign mode =
        mode_dc ? 3'd5 :
        mode_ec ?
            (is_ec1 ? (k_eq_4 ? 3'd1 : 3'd2) :
            is_gk2 ? (k_eq_4 ? 3'd3 : 3'd4) :
            3'd0)
        : 3'd0;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            state           <= IDLE;
            valid_encode    <= 1'b0;
            done_decap_o    <= 1'b0;
            done_encode_o   <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (gk_ena_i & ~ec_ena_i & ~dc_ena_i) begin
                        if (NTT_runs < k_temp) begin
                            state   <= RUNGK1;    // RUN encode s_hat
                        end
                    end
                    else if (~gk_ena_i & ec_ena_i & ~dc_ena_i) begin
                        if (NTT_runs == k_temp) begin
                            state   <= RUNEC1;
                        end
                    end
                    else if (~gk_ena_i & ~ec_ena_i & dc_ena_i) begin
                        if (done_encode_i) begin
                            state   <= DONE;
                        end
                    end
                end
                RUNGK1: begin
                    if (gk_ena_i & ~ec_ena_i) begin
                        if (NTT_runs == k_temp + 1) begin
                            state   <= RUNGK2;    // RUN encode t_hat = e_hat + (s_hat * A_hat)
                        end
                    end
                    valid_encode    <= 1'b1;
                end
                RUNGK2: begin
                    valid_encode    <= 1'b1;
                    if (done_encode_i) begin
                        state   <= DONE;
                    end
                end
                RUNEC1: begin
                    valid_encode    <= 1'b1;
                    if (NTT_runs == (k_temp << 1) + 1) begin
                        state   <= RUNGK2;
                    end
                end
                // RUNEC2: begin
                //     valid_encode    <= 1'b1;
                //     if (done_encode_i) begin
                //         state   <= DONE;
                //     end
                // end
                DONE: begin
                    done_encode_o     <= 1'b1;
                    if (dc_ena_i) begin
                        valid_encode    <= 1'b0;
                        done_decap_o    <= 1'b1;
                        done_encode_o   <= 1'b0;
                        state           <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

module Controller_CMP (
    //controll signal
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire    [2:0]       k_i,

    input   wire                valid_i,
    output  wire                id_i_1011,
    output  wire                id_i_0405,
    output  reg     [2:0]       state,
    output  reg                 done_o
);

/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
localparam IDLE         = 3'b000;
localparam COMPRESS_U   = 3'b001;
localparam WAIT         = 3'b010;
localparam COMPRESS_V   = 3'b011;
localparam DONE         = 3'b111;

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
reg             valid_store_0;
reg             valid_store_1;
reg     [2:0]   runtimes;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
// always @(*) begin
//     if (~gk_ena_i & ec_ena_i) begin
//         if (k_i == 4) begin
//             id_i_1011   =   1'b1;
//             id_i_0405   =   1'b1;
//         end
//         else begin
//             id_i_1011   =   1'b0;
//             id_i_0405   =   1'b0;
//         end
//     end
//     else begin
//         id_i_1011   =   1'b0;
//         id_i_0405   =   1'b0;
//     end
// end
assign id_i_1011 = (~gk_ena_i) & ec_ena_i & (k_i == 4);
assign id_i_0405 = id_i_1011;
/*****************************************************************************
*                             Sequential Logic                               *
*****************************************************************************/
always @(posedge clk_i) begin
    if (rst_i) begin
        state           <= IDLE;
        valid_store_0   <= 1'b0;
        valid_store_1   <= 1'b0;
        runtimes        <= 3'b0;
        done_o          <= 1'b0;
    end
    else begin
        case (state)
            IDLE: begin
                if (~gk_ena_i) begin
                    state <= COMPRESS_U;
                end
            end
            COMPRESS_U: begin
                if (valid_i) begin
                    valid_store_0  <= 1'b1;
                end
                else valid_store_0  <= 1'b0;
                valid_store_1  <= valid_store_0;
                if (valid_store_1 & ~valid_store_0) begin
                    runtimes    <= runtimes + 1;
                end
                if (runtimes == k_i) begin
                    state <= WAIT;
                end
            end
            WAIT: begin
                if (valid_i) begin
                    valid_store_0  <= 1'b1;
                end
                else valid_store_0  <= 1'b0;
                valid_store_1  <= valid_store_0;
                if (valid_store_1 & ~valid_store_0) begin
                    state <= COMPRESS_V;
                end
            end
            COMPRESS_V: begin
                if (valid_i) begin
                    valid_store_0  <= 1'b1;
                end
                else valid_store_0  <= 1'b0;
                valid_store_1  <= valid_store_0;
                if (valid_store_1 & ~valid_store_0) begin
                    state <= DONE;
                end
            end
            DONE: begin
                done_o          <= 1'b1;
            end
            default: state <= IDLE;
        endcase
    end
end
endmodule

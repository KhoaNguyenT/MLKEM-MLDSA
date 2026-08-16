module Packwords (
    input               clk_i,
    input               rst_i,
    input      [159:0]  data_i,
    input               data_i_valid,
    output     [191:0]  data_o,
    output reg          data_o_valid
);

    reg [319:0] buffer;        // 2 x 160 bit
    reg [2:0]   cnt;           // 0–5
    localparam  CNT_WAIT = 3'd6;

    assign data_o = (cnt == 3'd1) ? buffer[319:128] :
                    (cnt == 3'd2) ? buffer[287:96]  :
                    (cnt == 3'd3) ? buffer[255:64]  :
                    (cnt == 3'd4) ? buffer[223:32]  :
                    (cnt == 3'd5) ? buffer[191:0]   :
                                    192'd0;

    always @(posedge clk_i) begin
        if (rst_i) begin
            buffer        <= 320'd0;
            cnt           <= CNT_WAIT;
        end else begin
            if (data_i_valid) begin 
                buffer <= {buffer[159:0], data_i};
            end

            case (cnt)
                CNT_WAIT: begin
                    // chỉ đợi input, không xuất
                    data_o_valid <= 1'b0;
                    if (data_i_valid) cnt <= 3'd0;
                end

                3'd0: begin
                    data_o_valid <= data_i_valid;
                    cnt <= 3'd1;
                end
                3'd1: begin
                    data_o_valid <= data_i_valid;
                    cnt <= 3'd2;
                end
                3'd2: begin
                    data_o_valid <= data_i_valid;
                    cnt <= 3'd3;
                end
                3'd3: begin
                    data_o_valid <= data_i_valid;
                    cnt <= 3'd4;
                end
                3'd4: begin
                    data_o_valid <= data_i_valid;
                    cnt <= 3'd5;
                end
                3'd5: begin
                    // hết 1 vòng 6
                    data_o_valid <= 1'b0;
                    if (data_i_valid) cnt <= 0;
                end
                default: cnt <= CNT_WAIT;
            endcase
        end
    end

endmodule

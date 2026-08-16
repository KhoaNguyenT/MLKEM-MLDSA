module PackBits (
    input  wire         clk_i,
    input  wire         rst_i,

    input  wire         in_valid,
    input  wire [15:0]  in_data,

    output reg          out_valid,
    output reg          out_phase,
    output wire [191:0] out_data,
    input  wire         done_i
);

    reg [15:0] mem [0:15];
    reg [3:0]  cnt;

    always @(posedge clk_i) begin
        if (rst_i) begin
            cnt       <= 0;
            out_valid <= 0;
            out_phase <= 0;
        end else begin
            if (in_valid) begin
                mem[cnt] <= in_data;
                cnt <= cnt + 1;
            end
            if (~done_i) begin
                if (cnt == 10) begin
                    out_valid <= 1;
                    out_phase <= 1'b0;
                end
                else if (cnt == 14) begin
                    out_valid <= 1;
                    out_phase <= 1'b0;
                end
                else if (cnt == 15) begin
                    out_valid <= 0;
                    out_phase <= 1'b1;
                end
                else begin
                    out_valid <= 0;
                    out_phase <= out_phase;
                end
            end
            else if (done_i) begin
                out_valid <= 0;
                out_phase <= 1'b0;
            end
        end
    end

    assign out_data =
        (cnt == 11) ? {
            mem[0], mem[1], mem[2], mem[3],
            mem[4], mem[5], mem[6], mem[7],
            mem[8], mem[9], mem[10], in_data
        } :
        (cnt == 15) ? {
            mem[12], mem[13], mem[14], in_data,
            128'd0
        } :
        192'd0;

endmodule

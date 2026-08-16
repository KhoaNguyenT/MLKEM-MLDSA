module MulPolyiNTT #(
    parameter DWIDTH = 12,
    parameter NUMBER = 16,
    parameter LWIDTH = DWIDTH * NUMBER
) (
    input   wire                    clk_i,
    input   wire                    rst_i,
    input   wire                    valid_i,
    input   wire    [LWIDTH-1:0]    data_i,
    output  wire                    valid_o,
    output  wire                    pre_valid_o,
    output  wire    [LWIDTH-1:0]    data_o
);
    localparam DATA_WIDTH   = DWIDTH + 1;
    localparam OUTW         = DATA_WIDTH * 2;
    localparam Q = 13'd3329;
    wire    [OUTW-1:0]       Mul_pre_barret [0:NUMBER-1];
    wire    [DATA_WIDTH-1:0] oBarretMul     [0:NUMBER-1];
    reg     [DATA_WIDTH-1:0] data_pre_o     [0:NUMBER-1];
    reg     [3:0]   valid_hold;
    genvar i;
    generate
        for (i = 0; i < NUMBER; i++) begin
            BoothMul_R8 Mul_inst (
                .clk_i(clk_i),
                .rst_i(rst_i),
                .a({1'b0, data_i[i*DWIDTH +: DWIDTH]}),
                .b(13'd3303),
                .R(Mul_pre_barret[i])
            );
            Barret Barret_inst (
                .clk_i(clk_i),
                .rst_i(rst_i),
                .C({{(32-OUTW){Mul_pre_barret[i][OUTW-1]} }, Mul_pre_barret[i]}),
                .R(oBarretMul[i])
            );
            assign data_o[i*DWIDTH +: DWIDTH] = (valid_o) ? data_pre_o[i][DWIDTH-1:0] : 0;
        end
    endgenerate
    assign valid_o      = valid_hold[3];
    assign pre_valid_o  = valid_hold[2];
    always @(posedge clk_i) begin
        if (rst_i) begin
            valid_hold[0] <= 0;
            valid_hold[1] <= 0;
            valid_hold[2] <= 0;
            valid_hold[3] <= 0;
        end
        else begin
            valid_hold[0]  <= valid_i;
            valid_hold[1]  <= valid_hold[0];
            valid_hold[2]  <= valid_hold[1];
            valid_hold[3]  <= valid_hold[2];

            data_pre_o[0 ] <= oBarretMul[0 ][DATA_WIDTH-1] ? (oBarretMul[0 ]-Q): oBarretMul[0 ];
            data_pre_o[1 ] <= oBarretMul[1 ][DATA_WIDTH-1] ? (oBarretMul[1 ]-Q): oBarretMul[1 ];
            data_pre_o[2 ] <= oBarretMul[2 ][DATA_WIDTH-1] ? (oBarretMul[2 ]-Q): oBarretMul[2 ];
            data_pre_o[3 ] <= oBarretMul[3 ][DATA_WIDTH-1] ? (oBarretMul[3 ]-Q): oBarretMul[3 ];
            data_pre_o[4 ] <= oBarretMul[4 ][DATA_WIDTH-1] ? (oBarretMul[4 ]-Q): oBarretMul[4 ];
            data_pre_o[5 ] <= oBarretMul[5 ][DATA_WIDTH-1] ? (oBarretMul[5 ]-Q): oBarretMul[5 ];
            data_pre_o[6 ] <= oBarretMul[6 ][DATA_WIDTH-1] ? (oBarretMul[6 ]-Q): oBarretMul[6 ];
            data_pre_o[7 ] <= oBarretMul[7 ][DATA_WIDTH-1] ? (oBarretMul[7 ]-Q): oBarretMul[7 ];
            data_pre_o[8 ] <= oBarretMul[8 ][DATA_WIDTH-1] ? (oBarretMul[8 ]-Q): oBarretMul[8 ];
            data_pre_o[9 ] <= oBarretMul[9 ][DATA_WIDTH-1] ? (oBarretMul[9 ]-Q): oBarretMul[9 ];
            data_pre_o[10] <= oBarretMul[10][DATA_WIDTH-1] ? (oBarretMul[10]-Q): oBarretMul[10];
            data_pre_o[11] <= oBarretMul[11][DATA_WIDTH-1] ? (oBarretMul[11]-Q): oBarretMul[11];
            data_pre_o[12] <= oBarretMul[12][DATA_WIDTH-1] ? (oBarretMul[12]-Q): oBarretMul[12];
            data_pre_o[13] <= oBarretMul[13][DATA_WIDTH-1] ? (oBarretMul[13]-Q): oBarretMul[13];
            data_pre_o[14] <= oBarretMul[14][DATA_WIDTH-1] ? (oBarretMul[14]-Q): oBarretMul[14];
            data_pre_o[15] <= oBarretMul[15][DATA_WIDTH-1] ? (oBarretMul[15]-Q): oBarretMul[15];
        end
    end
endmodule

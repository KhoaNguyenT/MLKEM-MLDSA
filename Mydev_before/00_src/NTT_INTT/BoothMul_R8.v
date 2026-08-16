module BoothMul_R8 #(
    parameter int DATA_WIDTH = 13
)(
    input   wire   clk_i,
    input   wire   rst_i,
    input   wire   [DATA_WIDTH - 1:0] a,
    input   wire   [DATA_WIDTH - 1:0] b,
    output  reg   [(DATA_WIDTH*2) - 1:0] R
);
    localparam int OUTW = DATA_WIDTH * 2;
    localparam int NUM_PP = 5; // Với 13-bit, Radix-8 cần 5 bộ giải mã (13/3 = 4.33)
    // Độ rộng ngõ ra của bộ Decode: DATA_WIDTH + 2
    localparam int DEC_W = DATA_WIDTH + 2;
    wire   [DEC_W - 1:0] pp_raw [0:NUM_PP - 1]; // Kết quả thô từ bộ giải mã
    wire   [OUTW - 1:0] pp [0:NUM_PP - 1]; // Kết quả đã được nới rộng dấu
    // 1. Chuẩn bị tín hiệu chọn (Selection logic) cho Radix-8
    // Cần nới rộng b để lấy đủ các nhóm 4-bit
    wire  [14:0] b_ext;
    assign b_ext = {{2{b[DATA_WIDTH-1]}}, b}; // Nới rộng dấu b lên 16 bit
    wire  [3:0] sel [0:NUM_PP - 1];
    assign sel[0] = {b_ext[2:0], 1'b0}; // Nhóm 0: {b2, b1, b0, 0}
    assign sel[1] = b_ext[5:2]; // Nhóm 1: {b5, b4, b3, b2}
    assign sel[2] = b_ext[8:5]; // Nhóm 2: {b8, b7, b6, b5}
    assign sel[3] = b_ext[11:8]; // Nhóm 3: {b11, b10, b9, b8}
    assign sel[4] = b_ext[14:11]; // Nhóm 4: {b14, b13, b12, b11}
    // 2. Instance các bộ giải mã Booth
    generate
    genvar i;
    for (i = 0; i < NUM_PP; i++) begin : gen_decode
        BoothDecode_16b #(
            .DATA_WIDTH(DATA_WIDTH)
        ) u_bd (
            .A(a),
            .sel(sel[i]),
            .res(pp_raw[i])
        );
    // Nới rộng dấu từ DEC_W lên OUTW
    // yêu cầu tường minh trong việc nới rộng bit
    assign pp[i] = {{(OUTW-DEC_W){pp_raw[i][DEC_W-1]}}, pp_raw[i]};
    end
    endgenerate
    // 3. Cộng tích riêng (Partial Product Accumulation)
    // Dịch bit tương ứng với Radix-8 (mỗi tầng dịch 3 bit)
    wire  [OUTW-1:0] p0, p1, p2, p3, p4;
    assign p0 = pp[0];
    assign p1 = pp[1] << 3;
    assign p2 = pp[2] << 6;
    assign p3 = pp[3] << 9;
    assign p4 = pp[4] << 12;
    always @(posedge clk_i) begin
        if (rst_i) begin
            R <= '0;
        end else begin
            R <= p0 + p1 + p2 + p3 + p4;
        end
    end
endmodule

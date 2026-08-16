module Barret #(
    parameter WIDTH = 16
) (
    input   wire                            clk_i,
    input   wire                            rst_i,
    input   wire  signed [(WIDTH*2)-1:0]    C, // 32-bit signed khi WIDTH=16
    // input   logic                           valid_i,
    output  wire         [13-1:0]        R
    // output  logic                           valid_o,

);
    // Định nghĩa Qmod với độ rộng 45 bit để khớp với các phép tính s1
    // localparam  [44:0] QMOD = 45'd3329;
    // Mở rộng dấu C lên 45 bit ngay từ đầu
    wire  [44:0] C45;
    assign C45 = {{(45-(WIDTH*2)){C[(WIDTH*2)-1]}}, C};
    // Chỉ giữ lại các thanh ghi thực sự sử dụng
    reg   [44:0] s0;
    reg   [44:0] s1;
    reg   [44:0] C_hold0;
    // logic               valid_hold0;
    // logic               valid_hold1;
    // tmp tính dựa trên giá trị đã lưu trong s0 (pipeline stage 1)
    wire  [44:0] tmp;
    assign tmp = s0 >>> 26;
    always @(posedge clk_i) begin
        if (rst_i) begin
            s0 <= 45'd0;
            s1 <= 45'd0;
            C_hold0 <= 45'd0;
        end else begin
            // Stage 1: Tính C * mu
            s0 <= (C45 << 14) + (C45 << 12) - (C45 << 8) - (C45 << 6) - C45;
            // valid_hold0 <= valid_i;
            C_hold0 <= C45;
            // Stage 2: Tính R = C - (q_hat * Q)
            // C_hold0 và tmp đều trễ 1 nhịp so với C gốc, tạo nên pipeline đồng bộ
            s1 <= C_hold0 - (tmp << 11) - (tmp << 10) - (tmp << 8) - tmp;
            // valid_hold1 <= valid_hold0;
        end
    end
    // Xử lý cảnh báo WIDTHTRUNC và WIDTHEXPAND
    // 1. Ép kiểu các hằng số so sánh về 45 bit
    // 2. Kết quả cuối cùng lấy đoạn [WIDTH-1:0] để khớp đầu ra R
    // always_comb begin
    //     // logic signed [44:0] res_internal;
    //     if (s1 < 0) // Nếu s1 âm
    //         R = s1[12:0] + QMOD[12:0];
    //     else if (s1 >= QMOD)
    //         R = s1[12:0] - QMOD[12:0];
    //     else
    //         R = s1[12:0];
    //     // valid_o <= valid_hold1;
    // end
    wire [12:0] s_mod;
    assign s_mod = s1[12:0];

    assign R =
        s1[44]              ? (s_mod + 13'd3329) :
        (s_mod >= 13'd3329) ? (s_mod - 13'd3329) :
                            s_mod;
endmodule



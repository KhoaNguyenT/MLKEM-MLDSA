module Barret_mul #(parameter int WIDTH = 16
) (
    input   wire                   clk_i,
    input   wire                   rst_i,
    input   wire   [(WIDTH*2)-1:0] C, // 32-bit signed
    output  wire   [WIDTH-1:0]     R
    );
    // --- Hằng số ---
    localparam QMOD = 16'd3329;
    // --- Tín hiệu trung gian ---
    wire [44:0] c45;
    wire [44:0] tmp_v;
    // Pipeline Registers
    // Stage 0-2: Tính quotient (q = (C * M) >>> 26)
    // Stage 3-5: Tính remainder (R = C - q * Q)
    reg [44:0] s_pipe[0:5];
    reg [44:0] c_hold[0:2];
    // Mở rộng dấu đầu vào lên 45-bit để tính toán an toàn
    assign c45 = {{13{C[(WIDTH*2)-1]}}, C};
    // Logic tính Quotient (tmp) dựa trên các trạm pipeline của bạn
    // Tương đương phép nhân C * 20111 (Barrett constant for Q=3329, shift 26)
    assign tmp_v = s_pipe[2] >>> 26;

    always @(posedge clk_i) begin
        if (rst_i) begin
            foreach (s_pipe[i]) s_pipe[i] <= '0;
            foreach (c_hold[i]) c_hold[i] <= '0;
        end else begin
            // --- GIAI ĐOẠN 1-3: Tính C * M (M=20159) ---
            // 20111 = 2^14 + 2^12 - 2^8 - 2^6 - 1 (xấp xỉ logic của bạn)
            s_pipe[0] <= (c45 <<< 14) + (c45 <<< 12);       // 348160
            s_pipe[1] <= (c45 <<< 8) + (c45 <<< 6);         // 5440
            c_hold[0] <= c45;                               // 17
            s_pipe[2] <= s_pipe[0] - s_pipe[1] - c_hold[0]; // 342703
            c_hold[1] <= c_hold[0];                         // 17
            // --- GIAI ĐOẠN 4-6: Tính Remainder = C - (tmp * Q) ---
            // Q = 3329 = 2^11 + 2^10 + 2^8 + 1
            s_pipe[3] <= (tmp_v <<< 11) + (tmp_v <<< 10);
            s_pipe[4] <= (tmp_v <<< 8) + tmp_v;
            c_hold[2] <= c_hold[1];                         // 17
            s_pipe[5] <= c_hold[2] - (s_pipe[3] + s_pipe[4]);
        end
    end
    // --- Xử lý kết quả cuối cùng (Final Correction) ---
    // Barrett reduction đảm bảo kết quả nằm trong khoảng [-Q, 2Q]
    // Cần đưa về khoảng [0, Q-1]
    // always @(*) begin
    //     if (&s_pipe[5][44:16]) // Nếu âm
    //         R = s_pipe[5][WIDTH-1:0] + QMOD;
    //     else if (s_pipe[5][WIDTH-1:0] >=  QMOD)
    //         R = s_pipe[5][WIDTH-1:0] - QMOD;
    //     else
    //         R = s_pipe[5][WIDTH-1:0];
    // end
    wire neg_flag;
    wire [WIDTH-1:0] s_val;

    assign s_val    = s_pipe[5][WIDTH-1:0];
    assign neg_flag = &s_pipe[5][44:16];

    assign R = neg_flag                ? (s_val + QMOD) :
            (s_val >= QMOD)         ? (s_val - QMOD) :
                                        s_val;
endmodule

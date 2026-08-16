module BU #(
    parameter DATA_WIDTH = 13
)(
    input   wire                        clk_i,
    input   wire                        rst_i, // Reset đồng bộ mức cao
    input   wire                        is_NTT,
    input   wire    [DATA_WIDTH-1:0]    A ,
    input   wire    [DATA_WIDTH-1:0]    B,
    input   wire    [DATA_WIDTH-2:0]    Zeta,
    output  wire    [DATA_WIDTH-2:0]    A_NTT,
    output  wire    [DATA_WIDTH-2:0]    B_NTT,
    output  wire    [DATA_WIDTH-2:0]    A_iNTT,
    output  wire    [DATA_WIDTH-2:0]    B_iNTT
);
    localparam Q = 13'd3329;
    localparam OUTW = DATA_WIDTH * 2;
    wire  [DATA_WIDTH-1:0] chooseB, addAB, sub_res, add_res;
    wire  [OUTW-1:0] oMul;
    wire  [12:0] oBarretAdd, oBarretMul;
    // Pipeline Registers
    reg   [DATA_WIDTH-1:0] RegA, RegB, RegZ;
    reg   [DATA_WIDTH-1:0] hold_a [0:3];
    reg   [DATA_WIDTH-1:0] reg_chooseB, reg_Z;
    reg   [DATA_WIDTH-1:0] hold_add_0;
    reg   [DATA_WIDTH-1:0] RegA_NTT_out, RegB_NTT_out, pre_RegA_iNTT_out, RegA_iNTT_out, RegB_iNTT_out;
    // 1. Giai đoạn Input
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            RegA <= '0; 
            RegB <= '0; 
            RegZ <= '0;
        end else begin
            RegA <= A; 
            RegB <= B; 
            RegZ <= {1'b0, Zeta};
        end
    end
    // 2. Delay line cho A
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            for (int i = 0; i < 4; i++) hold_a[i] <= '0;
        end else begin
            hold_a[0] <= RegA;
            hold_a[1] <= hold_a[0];
            hold_a[2] <= hold_a[1];
            hold_a[3] <= hold_a[2];
        end
    end
    // 3. Logic chọn đầu vào
    assign chooseB  = (is_NTT) ? RegB 
                    : ((RegB < RegA) ? (RegB + Q - RegA) : (RegB - RegA));
                    
    assign addAB = (RegA + RegB >= Q) ? (RegA + RegB - Q) : (RegA + RegB);
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            reg_chooseB <= '0; 
            reg_Z <= '0;
        end else begin
            reg_chooseB <= chooseB;
            reg_Z <= RegZ; 
        end
    end
    // 4. Booth Multiplier Instance (Đã cập nhật reset đồng bộ)
    BoothMul_R8 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) mul_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a(reg_chooseB),
        .b(reg_Z),
        .R(oMul)
    );
    // 5. Barrett Reduction (Lưu ý: Bạn cũng cần sửa module barret sang rst_i mức cao)
    Barret Barret_inst0(
        .clk_i(clk_i),
        .rst_i(rst_i), // Ở đây nối vào rst_i, nhưng hãy kiểm tra cực tính bên trong module Barret
        .C({ { (32-DATA_WIDTH){1'b0} }, addAB }),
        .R(oBarretAdd)
    );
    Barret Barret_inst1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .C({ { (32-OUTW){oMul[OUTW-1]} }, oMul }),
        .R(oBarretMul)
    );
    // 6. Giai đoạn tính toán cuối cùng
    assign add_res = hold_a[3] + oBarretMul[DATA_WIDTH-1:0];
    assign sub_res =  (hold_a[3] < oBarretMul[DATA_WIDTH-1:0]) 
                    ? (hold_a[3] + Q - oBarretMul[DATA_WIDTH-1:0]) 
                    : (hold_a[3] - oBarretMul[DATA_WIDTH-1:0]);
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            hold_add_0 <= '0;

            RegA_NTT_out <= '0; 
            RegB_NTT_out <= '0;

            RegA_iNTT_out <= '0; 
            RegB_iNTT_out <= '0;
        end else begin
            RegA_NTT_out <= (add_res >= Q) ? (add_res - Q) : add_res;
            RegB_NTT_out <= sub_res;

            hold_add_0 <= oBarretAdd[DATA_WIDTH-1:0];
            pre_RegA_iNTT_out <= hold_add_0[DATA_WIDTH-1] ? (hold_add_0-Q): hold_add_0;
            
            RegA_iNTT_out <= pre_RegA_iNTT_out;
            RegB_iNTT_out <= oBarretMul[DATA_WIDTH-1] ? (oBarretMul-Q): oBarretMul;
        end
    end
    assign A_NTT  =  (RegA_NTT_out[DATA_WIDTH-1]) ? RegA_NTT_out[DATA_WIDTH-2:0]  : RegA_NTT_out[DATA_WIDTH-2:0];
    assign B_NTT  =  (RegB_NTT_out[DATA_WIDTH-1]) ? RegB_NTT_out[DATA_WIDTH-2:0]  : RegB_NTT_out[DATA_WIDTH-2:0];
    assign A_iNTT = (RegA_iNTT_out[DATA_WIDTH-1]) ? RegA_iNTT_out[DATA_WIDTH-2:0] : RegA_iNTT_out[DATA_WIDTH-2:0];
    assign B_iNTT = (RegB_iNTT_out[DATA_WIDTH-1]) ? RegB_iNTT_out[DATA_WIDTH-2:0] : RegB_iNTT_out[DATA_WIDTH-2:0];
endmodule

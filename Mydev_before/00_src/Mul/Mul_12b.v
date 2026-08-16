module Mul_12b #(
    parameter int WIDTH = 13
)(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire    [WIDTH-1:0]     A,
    input   wire    [WIDTH-1:0]     B,
    output  wire    [(WIDTH*2)-1:0] R
);
// --- Khai báo tín hiệu ---
    localparam int NUM_BOOTH = 7;

    wire  [WIDTH:0] tmp[NUM_BOOTH];
    wire  [(WIDTH*2)-1:0] tmp_sum[4], tmp_carry[4];
    // Pipeline Registers
    reg   [WIDTH-1:0] regA;
    reg   [WIDTH+1:0] B_ex;
    reg   [(WIDTH*2)-1:0] regx[11];
    // --- Stage 1: Booth Decoding (Parallel) ---
    generate
    for (genvar i = 0; i < NUM_BOOTH; i++) begin : gen_booth
        BoothDecode_mul booth_inst (
            .A (regA),
            .sel(B_ex[2*i +: 3]), // Cắt bit thông minh: B_ex[2:0], [4:2], ...
            .res(tmp[i])
        );
        end
    endgenerate
    // --- Pipeline Stages Logic ---
    always @(posedge clk) begin
        if (!rst_n) begin
            regA <= '0;
            B_ex <= '0;
            for (int i = 0; i < 11; i++) regx[i] <= '0;
        end else begin
            // STAGE 1: Input Latched
            regA <= A;
            B_ex <= {B[WIDTH-1], B, 1'b0};
            // STAGE 2: First Level CSA Tree
            regx[0] <= tmp_sum[0];
            regx[1] <= tmp_sum[1];
            regx[2] <= tmp_carry[0];
            regx[3] <= tmp_carry[1];
            regx[4] <= ({{(WIDTH*2-(WIDTH+1)){tmp[6][WIDTH]}}, tmp[6]}) << 12;
            // STAGE 3: Second Level CSA Tree
            regx[5] <= tmp_sum[2];
            regx[6] <= tmp_carry[2];
            regx[7] <= regx[3] + regx[4];
            // STAGE 4: Third Level CSA Tree
            regx[8] <= tmp_sum[3];
            regx[9] <= tmp_carry[3];
            // STAGE 5: Final CPA (Carry Propagate Addition)
            regx[10] <= regx[8] + regx[9];
            end
        end
    // --- CSA Tree Assignments (Combinational) ---
    // Level 1
    CSA #(.WIDTH(2*WIDTH)) CSA0 (
        .a({{(WIDTH-1){tmp[0][WIDTH]}}, tmp[0]}),
        .b({{(WIDTH-3){tmp[1][WIDTH]}}, tmp[1], 2'd0}),
        .cin({{(WIDTH-5){tmp[2][WIDTH]}}, tmp[2], 4'd0}),
        .sum(tmp_sum[0]), 
        .carry(tmp_carry[0])
    );
    CSA #(.WIDTH(2*WIDTH)) CSA1 (
        .a({{(WIDTH-7){tmp[3][WIDTH]}}, tmp[3], 6'd0}),
        .b({{(WIDTH-9){tmp[4][WIDTH]}}, tmp[4], 8'd0}),
        .cin({{(WIDTH-11){tmp[5][WIDTH]}}, tmp[5], 10'd0}),
        .sum(tmp_sum[1]),
        .carry(tmp_carry[1])
    );
    // Level 2
    CSA #(.WIDTH(2*WIDTH)) CSA2 (
        .a(regx[0]), 
        .b(regx[1]), 
        .cin(regx[2]),
        .sum(tmp_sum[2]), 
        .carry(tmp_carry[2])
    );
    // Level 3
    CSA #(.WIDTH(2*WIDTH)) CSA3 (
        .a(regx[5]), 
        .b(regx[6]), 
        .cin(regx[7]),
        .sum(tmp_sum[3]), 
        .carry(tmp_carry[3])
    );
    assign R = regx[10];
endmodule

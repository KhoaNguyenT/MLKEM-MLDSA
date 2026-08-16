/**
* BoothDecode_16b: Radix-8 Booth Partial Product Generator
* Generates multiples (0, ±1, ±2, ±3, ±4) of multiplicand A.
*/
module BoothDecode_16b #(
    parameter int DATA_WIDTH = 16
)(
    input   wire  [DATA_WIDTH-1:0] A, // Multiplicand
    input   wire  [3:0] sel, // 4-bit selection from Booth Encoder
    output  wire  [DATA_WIDTH+1:0] res // Partial Product result
);
    // To satisfy Verilator linting, all intermediate logic should match the target width.
    // Radix-8 requires up to 4*A, which adds 2 bits to the input width.
    localparam int RES_W = DATA_WIDTH + 2;
    // Internal signals for multiples
    wire  [RES_W-1:0] a_ext; // Multiplicand extended to result width
    wire  [RES_W-1:0] a_x2; // +2A
    wire  [RES_W-1:0] a_x3; // +3A (Hard multiple)
    wire  [RES_W-1:0] a_x4; // +4A
    // 1. Explicit Sign Extension: Handles both positive and negative A correctly.
    // If you specifically need unsigned behavior, use {2'b0, A} instead.
    assign a_ext = signed'({ {2{A[DATA_WIDTH-1]}}, A });
    // 2. Pre-calculate Multiples: Perform operations on the full width to avoid WIDTH warnings.
    assign a_x2 = a_ext <<< 1; // +2A (Arithmetic shift)
    assign a_x3 = a_x2 + a_ext; // +3A
    assign a_x4 = a_ext <<< 2; // +4A
    // 3. Selection Logic
    // Using always_comb and unique case prevents Verilator CASEINCOMPLETE warnings.
    // always_comb begin
    //     unique case (sel)
    //         // Encoded values based on Radix-8 Table
    //         4'd0, 4'd15: res = {RES_W{1'b0}}; // 0X
    //         4'd1, 4'd2: res = a_ext; // +1X
    //         4'd3, 4'd4: res = a_x2; // +2X
    //         4'd5, 4'd6: res = a_x3; // +3X
    //         4'd7: res = a_x4; // +4X
    //         4'd8: res = -a_x4; // -4X
    //         4'd9, 4'd10: res = -a_x3; // -3X
    //         4'd11, 4'd12:res = -a_x2; // -2X
    //         4'd13, 4'd14:res = -a_ext; // -1X
    //         default: res = {RES_W{1'b0}};
    //     endcase
    // end
    assign res =
        (sel == 4'd0  || sel == 4'd15)  ? {RES_W{1'b0}} :
        (sel == 4'd1  || sel == 4'd2 )  ?  a_ext  :
        (sel == 4'd3  || sel == 4'd4 )  ?  a_x2   :
        (sel == 4'd5  || sel == 4'd6 )  ?  a_x3   :
        (sel == 4'd7 )                  ?  a_x4   :
        (sel == 4'd8 )                  ? -a_x4   :
        (sel == 4'd9  || sel == 4'd10)  ? -a_x3   :
        (sel == 4'd11 || sel == 4'd12)  ? -a_x2   :
        (sel == 4'd13 || sel == 4'd14)  ? -a_ext  :
                                        {RES_W{1'b0}};
endmodule

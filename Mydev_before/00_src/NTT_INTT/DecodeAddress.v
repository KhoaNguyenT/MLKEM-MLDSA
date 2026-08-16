module DecodeAddress #(
    parameter int ADDR_WIDTH = 8 // Tăng lên 8-bit để chứa được giá trị 224
)(
    input wire   [7:0] len,
    output wire  [ADDR_WIDTH-1:0] addr_core0,
    output wire  [ADDR_WIDTH-1:0] addr_core1,
    output wire  [ADDR_WIDTH-1:0] addr_core2,
    output wire  [ADDR_WIDTH-1:0] addr_core3,
    output wire  [ADDR_WIDTH-1:0] addr_core4,
    output wire  [ADDR_WIDTH-1:0] addr_core5,
    output wire  [ADDR_WIDTH-1:0] addr_core6,
    output wire  [ADDR_WIDTH-1:0] addr_core7
);
    // always_comb begin
    //     // Gán giá trị mặc định để tránh tạo Latch
    //     addr_core0 = '0;
    //     addr_core1 = '0; addr_core2 = '0; addr_core3 = '0;
    //     addr_core4 = '0; addr_core5 = '0; addr_core6 = '0; addr_core7 = '0;
    //     unique case (len)
    //         8'd2, 8'd4, 8'd8, 8'd16: begin
    //             addr_core1 = 8'd32; addr_core2 = 8'd64; addr_core3 = 8'd96;
    //             addr_core4 = 8'd128; addr_core5 = 8'd160; addr_core6 = 8'd192;
    //             addr_core7 = 8'd224;
    //         end
    //         8'd32: begin
    //             addr_core1 = 8'd16; addr_core2 = 8'd64; addr_core3 = 8'd80;
    //             addr_core4 = 8'd128; addr_core5 = 8'd144; addr_core6 = 8'd192;
    //             addr_core7 = 8'd208;
    //         end
    //         8'd64: begin
    //             addr_core1 = 8'd16; addr_core2 = 8'd32; addr_core3 = 8'd48;
    //             addr_core4 = 8'd128; addr_core5 = 8'd144; addr_core6 = 8'd160;
    //             addr_core7 = 8'd176;
    //         end
    //         8'd128: begin
    //             addr_core1 = 8'd16; addr_core2 = 8'd32; addr_core3 = 8'd48;
    //             addr_core4 = 8'd64; addr_core5 = 8'd80; addr_core6 = 8'd96;
    //             addr_core7 = 8'd112;
    //         end
    //         default: ; // Đã có gán mặc định ở trên
    //     endcase
    // end
    assign addr_core0 = 8'd0;

    assign addr_core1 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd32 :
        (len==8'd32)  ? 8'd16 :
        (len==8'd64)  ? 8'd16 :
        (len==8'd128) ? 8'd16 :
                        8'd0;

    assign addr_core2 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd64 :
        (len==8'd32)  ? 8'd64 :
        (len==8'd64)  ? 8'd32 :
        (len==8'd128) ? 8'd32 :
                        8'd0;

    assign addr_core3 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd96 :
        (len==8'd32)  ? 8'd80 :
        (len==8'd64)  ? 8'd48 :
        (len==8'd128) ? 8'd48 :
                        8'd0;

    assign addr_core4 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd128 :
        (len==8'd32)  ? 8'd128 :
        (len==8'd64)  ? 8'd128 :
        (len==8'd128) ? 8'd64 :
                        8'd0;

    assign addr_core5 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd160 :
        (len==8'd32)  ? 8'd144 :
        (len==8'd64)  ? 8'd144 :
        (len==8'd128) ? 8'd80 :
                        8'd0;

    assign addr_core6 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd192 :
        (len==8'd32)  ? 8'd192 :
        (len==8'd64)  ? 8'd160 :
        (len==8'd128) ? 8'd96 :
                        8'd0;

    assign addr_core7 =
        (len==8'd2  || len==8'd4  || len==8'd8  || len==8'd16) ? 8'd224 :
        (len==8'd32)  ? 8'd208 :
        (len==8'd64)  ? 8'd176 :
        (len==8'd128) ? 8'd112 :
                        8'd0;
endmodule

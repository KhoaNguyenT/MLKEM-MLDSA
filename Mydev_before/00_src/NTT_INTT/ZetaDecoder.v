module ZetaDecoder #(
parameter int ADDR_WIDTH = 7
)(
    input   wire  [7:0] len,
    input   wire  is_NTT,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta0,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta1,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta2,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta3,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta4,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta5,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta6,
    output  wire  [ADDR_WIDTH-1:0] addr_zeta7
);
    // Sử dụng always_comb cho logic tổ hợp
    // always_comb begin
    //     // unique case giúp tối ưu mạch chọn và báo lỗi nếu thiếu trường hợp
    //     if (is_NTT) begin
    //         unique case (len)
    //             8'd128: begin
    //                 addr_zeta0 = 7'd1; addr_zeta1 = 7'd1; addr_zeta2 = 7'd1; addr_zeta3 = 7'd1;
    //                 addr_zeta4 = 7'd1; addr_zeta5 = 7'd1; addr_zeta6 = 7'd1; addr_zeta7 = 7'd1;
    //             end
    //                 8'd64: begin
    //                 addr_zeta0 = 7'd2; addr_zeta1 = 7'd2; addr_zeta2 = 7'd2; addr_zeta3 = 7'd2;
    //                 addr_zeta4 = 7'd3; addr_zeta5 = 7'd3; addr_zeta6 = 7'd3; addr_zeta7 = 7'd3;
    //             end
    //             8'd32: begin
    //                 addr_zeta0 = 7'd4; addr_zeta1 = 7'd4; addr_zeta2 = 7'd5; addr_zeta3 = 7'd5;
    //                 addr_zeta4 = 7'd6; addr_zeta5 = 7'd6; addr_zeta6 = 7'd7; addr_zeta7 = 7'd7;
    //             end
    //             8'd16: begin
    //                 addr_zeta0 = 7'd8; addr_zeta1 = 7'd9; addr_zeta2 = 7'd10; addr_zeta3 = 7'd11;
    //                 addr_zeta4 = 7'd12; addr_zeta5 = 7'd13; addr_zeta6 = 7'd14; addr_zeta7 = 7'd15;
    //             end
    //             8'd8: begin
    //                 addr_zeta0 = 7'd16; addr_zeta1 = 7'd18; addr_zeta2 = 7'd20; addr_zeta3 = 7'd22;
    //                 addr_zeta4 = 7'd24; addr_zeta5 = 7'd26; addr_zeta6 = 7'd28; addr_zeta7 = 7'd30;
    //             end
    //             8'd4: begin
    //                 addr_zeta0 = 7'd32; addr_zeta1 = 7'd36; addr_zeta2 = 7'd40; addr_zeta3 = 7'd44;
    //                 addr_zeta4 = 7'd48; addr_zeta5 = 7'd52; addr_zeta6 = 7'd56; addr_zeta7 = 7'd60;
    //             end
    //             8'd2: begin
    //                 addr_zeta0 = 7'd64; addr_zeta1 = 7'd72; addr_zeta2 = 7'd80; addr_zeta3 = 7'd88;
    //                 addr_zeta4 = 7'd96; addr_zeta5 = 7'd104;addr_zeta6 = 7'd112;addr_zeta7 = 7'd120;
    //             end
    //             default: begin
    //             // Tránh tạo ra chốt (latch) bằng cách gán giá trị mặc định
    //                 addr_zeta0 = '0; addr_zeta1 = '0; addr_zeta2 = '0; addr_zeta3 = '0;
    //                 addr_zeta4 = '0; addr_zeta5 = '0; addr_zeta6 = '0; addr_zeta7 = '0;
    //             end
    //         endcase
    //     end else begin
    //     unique case (len)
    //             8'd128: begin
    //                 addr_zeta0 = 7'd1;  addr_zeta1 = 7'd1;    addr_zeta2 = 7'd1;   addr_zeta3 = 7'd1;
    //                 addr_zeta4 = 7'd1;  addr_zeta5 = 7'd1;    addr_zeta6 = 7'd1;   addr_zeta7 = 7'd1;
    //             end
    //             8'd64: begin
    //                 addr_zeta0 = 7'd3;  addr_zeta1 = 7'd3;    addr_zeta2 = 7'd3;   addr_zeta3 = 7'd3;
    //                 addr_zeta4 = 7'd2;  addr_zeta5 = 7'd2;    addr_zeta6 = 7'd2;   addr_zeta7 = 7'd2;
    //             end
    //             8'd32: begin
    //                 addr_zeta0 = 7'd7;  addr_zeta1 = 7'd7;    addr_zeta2 = 7'd6;   addr_zeta3 = 7'd6;
    //                 addr_zeta4 = 7'd5;  addr_zeta5 = 7'd5;    addr_zeta6 = 7'd4;   addr_zeta7 = 7'd4;
    //             end
    //             8'd16: begin
    //                 addr_zeta0 = 7'd15;  addr_zeta1 = 7'd14;  addr_zeta2 = 7'd13;  addr_zeta3 = 7'd12;
    //                 addr_zeta4 = 7'd11;  addr_zeta5 = 7'd10;  addr_zeta6 = 7'd9;   addr_zeta7 = 7'd8;
    //             end
    //             8'd8: begin
    //                 addr_zeta0 = 7'd31;  addr_zeta1 = 7'd29;  addr_zeta2 = 7'd27;  addr_zeta3 = 7'd25;
    //                 addr_zeta4 = 7'd23;  addr_zeta5 = 7'd21;  addr_zeta6 = 7'd19;  addr_zeta7 = 7'd17;
    //             end
    //             8'd4: begin
    //                 addr_zeta0 = 7'd63;  addr_zeta1 = 7'd59;  addr_zeta2 = 7'd55;  addr_zeta3 = 7'd51;
    //                 addr_zeta4 = 7'd47;  addr_zeta5 = 7'd43;  addr_zeta6 = 7'd39;  addr_zeta7 = 7'd35;
    //             end
    //             8'd2: begin
    //                 addr_zeta0 = 7'd127; addr_zeta1 = 7'd119; addr_zeta2 = 7'd111; addr_zeta3 = 7'd103;
    //                 addr_zeta4 = 7'd95;  addr_zeta5 = 7'd87;  addr_zeta6 = 7'd79;  addr_zeta7 = 7'd71;
    //             end
    //             default: begin
    //             // Tránh tạo ra chốt (latch) bằng cách gán giá trị mặc định
    //                 addr_zeta0 = '0; addr_zeta1 = '0; addr_zeta2 = '0; addr_zeta3 = '0;
    //                 addr_zeta4 = '0; addr_zeta5 = '0; addr_zeta6 = '0; addr_zeta7 = '0;
    //             end
    //         endcase
    //     end
    // end

    wire [ADDR_WIDTH-1:0] addr_ntt [0:7];
    wire [ADDR_WIDTH-1:0] addr_inv [0:7];
    assign {addr_ntt[0],addr_ntt[1],addr_ntt[2],addr_ntt[3],
            addr_ntt[4],addr_ntt[5],addr_ntt[6],addr_ntt[7]} =
        (len == 8'd128) ? {8{7'd1}} :
        (len == 8'd64 ) ? {{7'd2}, {7'd2}, {7'd2}, {7'd2}, {7'd3}, {7'd3}, {7'd3}, {7'd3}} :
        (len == 8'd32 ) ? {7'd4,7'd4,7'd5,7'd5,7'd6,7'd6,7'd7,7'd7} :
        (len == 8'd16 ) ? {7'd8,7'd9,7'd10,7'd11,7'd12,7'd13,7'd14,7'd15} :
        (len == 8'd8  ) ? {7'd16,7'd18,7'd20,7'd22,7'd24,7'd26,7'd28,7'd30} :
        (len == 8'd4  ) ? {7'd32,7'd36,7'd40,7'd44,7'd48,7'd52,7'd56,7'd60} :
        (len == 8'd2  ) ? {7'd64,7'd72,7'd80,7'd88,7'd96,7'd104,7'd112,7'd120} :
                        {8{7'd0}};
    assign {addr_inv[0],addr_inv[1],addr_inv[2],addr_inv[3],
            addr_inv[4],addr_inv[5],addr_inv[6],addr_inv[7]} =
        (len == 8'd128) ? {8{7'd1}} :
        (len == 8'd64 ) ? {{7'd3}, {7'd3}, {7'd3}, {7'd3}, {7'd2}, {7'd2}, {7'd2}, {7'd2}} :
        (len == 8'd32 ) ? {7'd7,7'd7,7'd6,7'd6,7'd5,7'd5,7'd4,7'd4} :
        (len == 8'd16 ) ? {7'd15,7'd14,7'd13,7'd12,7'd11,7'd10,7'd9,7'd8} :
        (len == 8'd8  ) ? {7'd31,7'd29,7'd27,7'd25,7'd23,7'd21,7'd19,7'd17} :
        (len == 8'd4  ) ? {7'd63,7'd59,7'd55,7'd51,7'd47,7'd43,7'd39,7'd35} :
        (len == 8'd2  ) ? {7'd127,7'd119,7'd111,7'd103,7'd95,7'd87,7'd79,7'd71} :
                        {8{7'd0}};
    assign addr_zeta0 = is_NTT ? addr_ntt[0] : addr_inv[0];
    assign addr_zeta1 = is_NTT ? addr_ntt[1] : addr_inv[1];
    assign addr_zeta2 = is_NTT ? addr_ntt[2] : addr_inv[2];
    assign addr_zeta3 = is_NTT ? addr_ntt[3] : addr_inv[3];
    assign addr_zeta4 = is_NTT ? addr_ntt[4] : addr_inv[4];
    assign addr_zeta5 = is_NTT ? addr_ntt[5] : addr_inv[5];
    assign addr_zeta6 = is_NTT ? addr_ntt[6] : addr_inv[6];
    assign addr_zeta7 = is_NTT ? addr_ntt[7] : addr_inv[7];
endmodule


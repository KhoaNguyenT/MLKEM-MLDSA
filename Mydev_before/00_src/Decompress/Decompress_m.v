module Decompress_m (
    input  wire         clk_i,
    input  wire         rst_i,
    input  wire         ena_i,
    input  wire         shift_next,
    input  wire [263:0] data_i,
    output wire         valid_o,
    output wire [191:0] data_o
);

    // ----------------------------
    // internal registers / wires
    // ----------------------------
    reg  [263:0] input_reg;
    reg  [4:0]   shift_count;

    wire [263:0] input_decomp;
    genvar i, j;
    generate
        for (i = 0; i < 22 ;i = i + 1) begin : g_chunk_12b
            localparam HIGH = 263 - (i * 12);
            localparam LOW  = HIGH - 11;
            for (j = 0; j < 12 ;j = j + 1) begin : g_bit_rev
                assign input_decomp[HIGH-j] = data_i[LOW + j];
            end
        end
    endgenerate
    // (B?n c� th? thay ??i th? t? byte n?u c?n; m�nh gi? c?u tr�c h?p l�: msb..lsb)

    // outputs of decompress blocks (16 x 12 bits)
    wire [11:0] out0;
    wire [11:0] out1;
    wire [11:0] out2;
    wire [11:0] out3;
    wire [11:0] out4;
    wire [11:0] out5;
    wire [11:0] out6;
    wire [11:0] out7;
    wire [11:0] out8;
    wire [11:0] out9;
    wire [11:0] out10;
    wire [11:0] out11;
    wire [11:0] out12;
    wire [11:0] out13;
    wire [11:0] out14;
    wire [11:0] out15;

    always @(posedge clk_i) begin
        if (rst_i) begin
            input_reg <= 264'd0;
            shift_count <= 5'd0;
        end else begin
            if (ena_i & ~|shift_count) begin
                input_reg   <= input_decomp;
                shift_count <= 5'd16;
            end else if (|shift_count & shift_next) begin 
                shift_count <= shift_count - 1;
                input_reg <= input_reg << 16;
            end else if (|shift_count & ~shift_next) begin 
                shift_count <= shift_count;
                input_reg <= input_reg;
            end
        end
    end
    
    assign out0  = (input_reg[263])  ? 12'd1665 : 12'd0;
    assign out1  = (input_reg[262])  ? 12'd1665 : 12'd0;
    assign out2  = (input_reg[261])  ? 12'd1665 : 12'd0;
    assign out3  = (input_reg[260])  ? 12'd1665 : 12'd0;
    assign out4  = (input_reg[259])  ? 12'd1665 : 12'd0;
    assign out5  = (input_reg[258])  ? 12'd1665 : 12'd0;
    assign out6  = (input_reg[257])  ? 12'd1665 : 12'd0;
    assign out7  = (input_reg[256])  ? 12'd1665 : 12'd0;
    assign out8  = (input_reg[255])  ? 12'd1665 : 12'd0;
    assign out9  = (input_reg[254])  ? 12'd1665 : 12'd0;
    assign out10 = (input_reg[253])  ? 12'd1665 : 12'd0;
    assign out11 = (input_reg[252])  ? 12'd1665 : 12'd0;
    assign out12 = (input_reg[251])  ? 12'd1665 : 12'd0;
    assign out13 = (input_reg[250])  ? 12'd1665 : 12'd0;
    assign out14 = (input_reg[249])  ? 12'd1665 : 12'd0;
    assign out15 = (input_reg[248])  ? 12'd1665 : 12'd0;

    
    assign data_o = {
        out0,   out1,   out2,   out3,
        out4,   out5,   out6,   out7,
        out8,   out9,   out10,  out11,
        out12,  out13,  out14,  out15
    };
    
    assign valid_o = |shift_count;

endmodule

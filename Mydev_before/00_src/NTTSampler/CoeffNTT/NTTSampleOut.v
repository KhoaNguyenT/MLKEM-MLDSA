module NTTSampleOut (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire    [47:0]      data_i,
    input   wire    [3:0]       valid_i,
    output  wire    [191:0]     data_o,
    output  wire                valid_o,
    output  wire                done_o
);

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/
    // debug
    wire    [11:0]  data_i_0;
    wire    [11:0]  data_i_1;
    wire    [11:0]  data_i_2;
    wire    [11:0]  data_i_3;

    assign data_i_0  = data_i[47:36];
    assign data_i_1  = data_i[35:24];
    assign data_i_2  = data_i[23:12];
    assign data_i_3  = data_i[11:0];

    reg     [7:0]   count;
    reg     [4:0]   count_round;
    reg     [227:0] buffer_o;           // 204 = 192 + 12 du 1 gia tri cho truong hop loi
    wire    [7:0]   count_temp;
    wire    [7:0]   count_sub;
    wire    [7:0]   count_temp_0;
    wire    [7:0]   count_temp_1;
    wire    [7:0]   idx_0;
    wire    [7:0]   idx_1;
    wire    [7:0]   idx_2;
    wire    [7:0]   idx_3;
    wire    [7:0]   temp_add;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/

    assign  done_o      = count_round[4];     //hoan thanh 1 lan 256 he so (192 = 16 he so * 12b) => 16 * 16 he so = 256 he so
    assign  valid_o     = count[4];
    assign  data_o      = buffer_o[227:36];
    assign  count_temp_0= ((count_sub << 2) + (count_sub << 3));
    assign  count_temp_1= ((count << 2) + (count << 3));
    assign  count_sub   = count - 16;
    assign  count_temp  = (count[4]) ? count_temp_0: count_temp_1;
    assign  idx_0       = 216 - count_temp; // count*12 = count*4 + count*8
    assign  idx_1       = idx_0 - 12;
    assign  idx_2       = idx_0 - 24;
    assign  idx_3       = idx_0 - 36;
    assign  temp_add    = {7'b00, valid_i[3]} + {7'b00, valid_i[2]}  + {7'b00, valid_i[1]}  + {7'b00, valid_i[0]};
    
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            count       <= 0;
            count_round <= 0;
            buffer_o    <= 0;
        end
        else begin
            if (count[4]) begin
                count_round <= count_round + 1;
                buffer_o    <= buffer_o << 192;
                count[4]    <= 1'b0;
                count[3:0]  <= temp_add[3:0] + count[3:0];
            end
            else begin 
                if (count_round[4]) count_round[4] <= 0;
                count       <= temp_add + count;
            end
            // data_i[47:36]
            // data_i[35:24]
            // data_i[23:12]
            // data_i[11:0]
            casez (valid_i)
                4'b1???                  :  buffer_o[idx_0 +: 12] <= data_i_0;
                4'b01??                  :  buffer_o[idx_0 +: 12] <= data_i_1;
                4'b001?                  :  buffer_o[idx_0 +: 12] <= data_i_2;
                4'b0001                  :  buffer_o[idx_0 +: 12] <= data_i_3;
                default: buffer_o[idx_0 +: 12]  <= 12'b0;
            endcase
            casez (valid_i)
                4'b11??                  :  buffer_o[idx_1 +: 12] <= data_i_1;
                4'b101?, 4'b011?         :  buffer_o[idx_1 +: 12] <= data_i_2;
                4'b1001, 4'b0101, 4'b0011:  buffer_o[idx_1 +: 12] <= data_i_3;
                default: buffer_o[idx_1 +: 12]  <= 12'b0;
            endcase
            casez (valid_i)
                4'b111?                  :  buffer_o[idx_2 +: 12] <= data_i_2;
                4'b1101, 4'b1011, 4'b0111:  buffer_o[idx_2 +: 12] <= data_i_3;
                default: buffer_o[idx_2 +: 12]  <= 12'b0;
            endcase
            casez (valid_i)
                4'b1111                  :  buffer_o[idx_3 +: 12] <= data_i_3;
                default: buffer_o[idx_3 +: 12]  <= 12'b0;
            endcase
            // buffer_o[idx_0 +: 12] <= (valid_i[0]) ? data_i[47:36] : (valid_i[1]) ? data_i[35:24] : (valid_i[2]) ? data_i[23:12] : (valid_i[3]) ? data_i[11:0] : 12'd0;
            // buffer_o[idx_1 +: 12] <= (valid_i[0] & valid_i[1]) ? data_i[35:24] : ((valid_i[0] ^ valid_i[1]) & valid_i[2]) ? data_i[23:12] : (valid_i[3]) ? data_i[11:0] : 12'd0;
            // buffer_o[idx_2 +: 12] <= (valid_i[0] & valid_i[1] & valid_i[2]) ? data_i[23:12] : ((valid_i[0] & (valid_i[1] ^ valid_i[2])) | (!valid_i[0] & valid_i[1] & valid_i[2])) ? data_i[11:0] : 12'd0;
            // buffer_o[idx_3 +: 12] <= (valid_i[0] & valid_i[1] & valid_i[2] & valid_i[3]) ? data_i[11:0]: 12'd0;
        end
    end
endmodule

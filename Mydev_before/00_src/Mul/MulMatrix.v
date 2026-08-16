module MulMatrix #(
    parameter WIDTH = 12,
    parameter num   = 16
)(
    input  wire                         clk_i,
    input  wire                         rst_i,
    input  wire                         valid_data,
    input  wire     [2:0]               k, 
    input  wire     [(WIDTH*num)-1:0]   a,
    input  wire     [(WIDTH*num)-1:0]   b,
    output wire     [(WIDTH*num)-1:0]   res,
    output wire                         valid_output,
    // output wire                         pre1_valid_output,
    output wire                         before_valid_output
);
    localparam num_flag = 24;

    reg     [(WIDTH*num)-1:0]           tmp_res;
    reg     [2:0]                       count_k;
    reg     [3:0]                       count_addr;
    reg                                 done_flag;
    reg                                 valid_sum;
    reg     [num_flag - 1:0]            reg_done_flag;
    reg     [num_flag - 1:0]            reg_valid_flag;

    wire [(WIDTH*num)-1:0]          add_tmp;
    wire [(WIDTH*num)-1:0]          tmp;

    // -------------------------------------------- count k, addr, done_flag --------------------------------------------
    integer i;
    always @(posedge clk_i) begin
        if (rst_i) begin
            count_k         <= 3'd0;
            count_addr      <= 4'd0;
            done_flag       <= 1'b0;
            valid_sum       <= 1'b0;
            reg_done_flag   <= {num_flag{1'b0}};
            reg_valid_flag  <= {num_flag{1'b0}};
        end 
        else begin 
            if (valid_data) begin
                if (count_k < k - 1'b1) begin
                    count_k <= count_k + 1'b1;
                end
                else begin
                    count_k     <= 3'd0;
                    count_addr  <= count_addr + 1'b1;
                end
                valid_sum   <= 1'b1;
            end 
            else begin
                valid_sum   <= 1'b0;
            end 
            if (count_k == k - 1'b1) begin
                done_flag   <= 1'b1;
            end 
            else begin
                done_flag   <= 1'b0;
            end 
            reg_done_flag   <= {reg_done_flag[num_flag-2:0], done_flag};
            reg_valid_flag  <= {reg_done_flag[num_flag-2:0], valid_sum};
        end
    end

    // -------------------------------------------- cong don --------------------------------------------
    
    logic   re_temp_signal;
    assign re_temp_signal       =   reg_done_flag[17];
    // assign re_temp_signal   =   reg_done_flag[16];
    // assign re_temp_signal   =   (k == 2)  ?   reg_done_flag[16]
    //                         :   (k == 3)  ?   reg_done_flag[16] | reg_done_flag[15]
    //                         :   (k == 4)  ?   reg_done_flag[16] | reg_done_flag[15] | reg_done_flag[14]
    //                         :   0;
    always @(posedge clk_i) begin
        if (rst_i) begin
            tmp_res <= 0;
        end 
        else begin 
            if (re_temp_signal) begin
                tmp_res <= 0;
            end 
            else begin
                tmp_res <= add_tmp;
            end 
        end
    end 

    add add_inst (
        .iA_flat (tmp),        // 12bit * 16
        .iB_flat (tmp_res),    // 12bit * 16
        .is_SUB(1'b0),
        .oSum_flat(add_tmp)   // 12bit * 16
    );

    // -------------------------------------------- mod barret --------------------------------------------
    genvar gi;
    generate
        for (gi = 0; gi < num; gi = gi + 1) begin : gen_res
            wire [WIDTH-1:0] resi = add_tmp[((gi+1)*(WIDTH))-1 : gi*(WIDTH)]; // 12 bit
            wire [15:0] out_barret;

            Barret_mul Barret_mul_inst (
                .clk_i(clk_i),
                .rst_i(rst_i),
                .C    ({20'd0, resi}),
                .R    (out_barret)
            );

            assign res[((gi+1)*WIDTH)-1 : gi*WIDTH] = out_barret[11:0];
        end
    endgenerate

    // -------------------------------------------- mul poly matrix --------------------------------------------

    MulPolyMatrix MulPolyMatrix_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .addr(count_addr),
        .a(a),
        .b(b),
        .res(tmp)
    );

    // -------------------------------------------- debug --------------------------------------------
    // wire [11:0] test_a [3:0];
    // wire [11:0] test_b [3:0];
    // wire [11:0] test_tmp [3:0];
    // wire [14:0] test_add_tmp[3:0];
    // wire [14:0] test_res_tmp[3:0];
    // genvar gj;
    // generate
    //     for (gj = 0; gj < 4; gj = gj + 1) begin : gen_test
    //         assign test_a[gj]   = a[((gj+13)*WIDTH)-1 : (gj +12)*WIDTH];
    //         assign test_b[gj]   = b[((gj+13)*WIDTH)-1 : (gj + 12)*WIDTH];
    //         assign test_tmp[gj] = tmp[((gj+13)*WIDTH)-1 : (gj+ 12)*WIDTH];
    //         assign test_add_tmp[gj] = add_tmp[((gj+13)*(WIDTH + 2))-1 : (gj+ 12)*(WIDTH + 2)];
    //         assign test_res_tmp[gj] = tmp_res[((gj+13)*(WIDTH + 2))-1 : (gj+ 12)*(WIDTH + 2)];
    //     end
    // endgenerate

    // -------------------------------------------- valid output --------------------------------------------
    // always @(*) begin
    //     case(k)
    //         3'd2: begin
    //             valid_output = reg_done_flag[21];
    //             before_valid_output = reg_done_flag[19];
    //         end
    //         3'd3: begin
    //             valid_output = reg_done_flag[21];
    //             before_valid_output = reg_done_flag[18];
    //         end
    //         3'd4: begin
    //             valid_output = reg_done_flag[21];
    //             before_valid_output = reg_done_flag[17];
    //         end
    //         default: valid_output = 1'b0;
    //     endcase
    //     // pre1_valid_output = reg_done_flag[20];
    // end 
    assign valid_output =
        (k == 3'd2 || k == 3'd3 || k == 3'd4) ?
        reg_done_flag[21] : 1'b0;
    assign before_valid_output =
        (k == 3'd2 || k == 3'd3 || k == 3'd4) ?
        reg_done_flag[21 - {2'b0, k}] : 1'b0;
endmodule

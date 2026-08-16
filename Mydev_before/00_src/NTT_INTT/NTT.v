module NTT #(
    parameter DATA_WIDTH = 13,
    parameter INPUT_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter ADDR_ZETA = 7
)(
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        start,
    input   wire                        is_NTT,
    input   wire                        valid_input,
    input   wire    [INPUT_WIDTH-1:0]   in,
    output  wire                        load_done,
    output  wire                        done_compute,
    output  reg                         done_o,
    output  wire                        valid_output,
    output  wire                        pre_valid_output,
    output  wire    [INPUT_WIDTH-1:0]   out

    
    // output  [DATA_WIDTH-1:0]    dout0, dout1, dout2, dout3, dout4, dout5, dout6, dout7, dout8, dout9, dout10, dout11, dout12, dout13, dout14, dout15,
);
    // ---------------------------------------------------- FSM ----------------------------------------------------
    // wire  done_compute;
    localparam IDLE = 0, LOAD = 1, COMPUTE = 2, WRITE_OUT = 3, DONE = 4;
    reg   [2:0] state; 
    wire  [2:0] next_state;
    reg   [6:0] count;
    reg   [7:0] count_load;
    wire  done_gen_addr;
    reg                         valid_ntt;
    wire                        pre_valid_ntt;
    wire    [INPUT_WIDTH-1:0]   out_ntt;

    wire                        valid_intt;
    wire                        pre_valid_intt;
    wire    [INPUT_WIDTH-1:0]   out_intt;

    assign valid_output     = (done_o) ? 0
                            : ((is_NTT) ? valid_ntt : valid_intt);
    assign pre_valid_output = (done_o) ? 0
                            : ((is_NTT) ? pre_valid_ntt : pre_valid_intt);
    assign out              = (done_o) ? 0
                            : ((is_NTT) ? out_ntt : out_intt);
    // wire                        load_done;
    // assign done_o = done_gen_addr;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end 
    end

    // always @(*) begin
    //     case(state)
    //         IDLE:       next_state = (start)        ? LOAD : IDLE;
    //         LOAD:       next_state = (load_done)    ? COMPUTE : LOAD;
    //         COMPUTE:    next_state = (done_compute) ? WRITE_OUT : COMPUTE;
    //         WRITE_OUT:  next_state = (((count_load == 8'd15) & is_NTT) | ((count_load == 8'd19) & ~is_NTT)) ? DONE : WRITE_OUT;
    //         DONE:       next_state = IDLE;
    //         default:    next_state = IDLE;
    //     endcase
    // end 
    assign next_state =
        (state == IDLE) ? (start ? LOAD : IDLE) : 
        (state == LOAD) ? (load_done ? COMPUTE : LOAD) :
        (state == COMPUTE) ? (done_compute ? WRITE_OUT : COMPUTE) :
        (state == WRITE_OUT) ? (((count_load == 8'd15) &&  is_NTT) || ((count_load == 8'd19) && !is_NTT)) ? DONE : WRITE_OUT :
        (state == DONE) ? IDLE :
                        IDLE;
    always @(posedge clk_i) begin
        if (rst_i) begin
            count       <= 7'd0;
            count_load  <= 8'd0;
        end 
        else begin
            case(state)
                IDLE:       count <= 7'd0;
                LOAD: begin       
                    if (valid_input) begin
                        count_load <= count_load + 1'b1;
                    end
                end 
                COMPUTE: begin
                    count       <= count + 7'b1;
                    count_load  <= 8'd0;
                end 
                WRITE_OUT: begin
                    count_load  <= count_load + 1'b1;
                end 
                DONE:       count <= 7'd0;
                default:    count <= 7'd0;
            endcase
        end 
    end 

    assign pre_valid_ntt = (state == WRITE_OUT);
    assign load_done    = (count_load == 8'd15) & (state == LOAD) & valid_input;
    assign done_compute = ((count == 7'd120 & is_NTT) | (count == 7'd124 & ~is_NTT)) ? 1'b1 : 1'b0;
    // ---------------------------------------------------- 8 core BU ----------------------------------------------------
    wire  [ADDR_ZETA-1:0]    addr_zeta0, addr_zeta1, addr_zeta2, addr_zeta3, addr_zeta4, addr_zeta5, addr_zeta6, addr_zeta7;
    wire  [ADDR_WIDTH-1:0]   addr_core0, addr_core1, addr_core2, addr_core3, addr_core4, addr_core5, addr_core6, addr_core7;
    wire  [ADDR_WIDTH-1:0]   len; // => lenght which used to excute 7 step
    wire  [DATA_WIDTH-2:0]   zeta0, zeta1, zeta2, zeta3, zeta4, zeta5, zeta6, zeta7;
    wire  [DATA_WIDTH-2:0]   A_NTT0, B_NTT0, A_iNTT0, B_iNTT0;
    wire  [DATA_WIDTH-2:0]   A_NTT1, B_NTT1, A_iNTT1, B_iNTT1;
    wire  [DATA_WIDTH-2:0]   A_NTT2, B_NTT2, A_iNTT2, B_iNTT2;
    wire  [DATA_WIDTH-2:0]   A_NTT3, B_NTT3, A_iNTT3, B_iNTT3;
    wire  [DATA_WIDTH-2:0]   A_NTT4, B_NTT4, A_iNTT4, B_iNTT4;
    wire  [DATA_WIDTH-2:0]   A_NTT5, B_NTT5, A_iNTT5, B_iNTT5;
    wire  [DATA_WIDTH-2:0]   A_NTT6, B_NTT6, A_iNTT6, B_iNTT6;
    wire  [DATA_WIDTH-2:0]   A_NTT7, B_NTT7, A_iNTT7, B_iNTT7;
    // ---------------------------------------------------- Hold_addr ----------------------------------------------------
    localparam HOLD = 7;
    reg   [ADDR_WIDTH-1:0] hold_addr0 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr1 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr2 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr3 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr4 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr5 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr6 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_addr7 [HOLD-1:0];
    reg   [ADDR_WIDTH-1:0] hold_len   [HOLD-1:0];

    integer i;
    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < HOLD; i = i + 1) begin
                hold_addr0[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr1[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr2[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr3[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr4[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr5[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr6[i] <= {ADDR_WIDTH{1'b0}};
                hold_addr7[i] <= {ADDR_WIDTH{1'b0}};
                hold_len[i]   <= {ADDR_WIDTH{1'b0}};
            end
        end 
        else begin
            hold_len[0] <= len;
            hold_len[1] <= hold_len[0];
            hold_len[2] <= hold_len[1];
            hold_len[3] <= hold_len[2];
            hold_len[4] <= hold_len[3];
            hold_len[5] <= hold_len[4];
            hold_len[6] <= hold_len[5];

            hold_addr0[0] <= addr_core0;
            hold_addr0[1] <= hold_addr0[0];
            hold_addr0[2] <= hold_addr0[1];
            hold_addr0[3] <= hold_addr0[2];
            hold_addr0[4] <= hold_addr0[3];
            hold_addr0[5] <= hold_addr0[4];
            hold_addr0[6] <= hold_addr0[5];

            hold_addr1[0] <= addr_core1;
            hold_addr1[1] <= hold_addr1[0];
            hold_addr1[2] <= hold_addr1[1];
            hold_addr1[3] <= hold_addr1[2];
            hold_addr1[4] <= hold_addr1[3];
            hold_addr1[5] <= hold_addr1[4];
            hold_addr1[6] <= hold_addr1[5];

            hold_addr2[0] <= addr_core2;
            hold_addr2[1] <= hold_addr2[0];
            hold_addr2[2] <= hold_addr2[1];
            hold_addr2[3] <= hold_addr2[2];
            hold_addr2[4] <= hold_addr2[3];
            hold_addr2[5] <= hold_addr2[4];
            hold_addr2[6] <= hold_addr2[5];

            hold_addr3[0] <= addr_core3;
            hold_addr3[1] <= hold_addr3[0];
            hold_addr3[2] <= hold_addr3[1];
            hold_addr3[3] <= hold_addr3[2];
            hold_addr3[4] <= hold_addr3[3];
            hold_addr3[5] <= hold_addr3[4];
            hold_addr3[6] <= hold_addr3[5];

            hold_addr4[0] <= addr_core4;
            hold_addr4[1] <= hold_addr4[0];
            hold_addr4[2] <= hold_addr4[1];
            hold_addr4[3] <= hold_addr4[2];
            hold_addr4[4] <= hold_addr4[3];
            hold_addr4[5] <= hold_addr4[4];
            hold_addr4[6] <= hold_addr4[5];

            hold_addr5[0] <= addr_core5;
            hold_addr5[1] <= hold_addr5[0];
            hold_addr5[2] <= hold_addr5[1];
            hold_addr5[3] <= hold_addr5[2];
            hold_addr5[4] <= hold_addr5[3];
            hold_addr5[5] <= hold_addr5[4];
            hold_addr5[6] <= hold_addr5[5];

            hold_addr6[0] <= addr_core6;
            hold_addr6[1] <= hold_addr6[0];
            hold_addr6[2] <= hold_addr6[1];
            hold_addr6[3] <= hold_addr6[2];
            hold_addr6[4] <= hold_addr6[3];
            hold_addr6[5] <= hold_addr6[4];
            hold_addr6[6] <= hold_addr6[5];

            hold_addr7[0] <= addr_core7;
            hold_addr7[1] <= hold_addr7[0];
            hold_addr7[2] <= hold_addr7[1];
            hold_addr7[3] <= hold_addr7[2];
            hold_addr7[4] <= hold_addr7[3];
            hold_addr7[5] <= hold_addr7[4];
            hold_addr7[6] <= hold_addr7[5];
        end 
    end 
    // ---------------------------------------------------- Memory control ----------------------------------------------------
    reg   we;
    reg   [ADDR_WIDTH-1:0] raddr0, raddr1, raddr2, raddr3, raddr4, raddr5, raddr6, raddr7, raddr8, raddr9, raddr10, raddr11, raddr12, raddr13, raddr14, raddr15;
    reg   [ADDR_WIDTH-1:0] waddr0, waddr1, waddr2, waddr3, waddr4, waddr5, waddr6, waddr7, waddr8, waddr9, waddr10, waddr11, waddr12, waddr13, waddr14, waddr15;
    //
    reg   [ADDR_WIDTH-2:0] addr_core0_d, addr_core1_d, addr_core2_d, addr_core3_d, addr_core4_d, addr_core5_d, addr_core6_d, addr_core7_d;
    
    reg   [INPUT_WIDTH-1:0] din;
    wire  [11:0] A[7:0];
    wire  [11:0] B[7:0];
    wire  [DATA_WIDTH-2:0] din0, din1, din2, din3, din4, din5, din6, din7, din8, din9, din10, din11, din12, din13, din14, din15;

    always @(posedge clk_i) begin
        if (rst_i) begin
            done_o          <= 1'b0;
            we              <= 1'b0;
            valid_ntt    <= 1'b0;
            din     <= {INPUT_WIDTH{1'b0}};
            raddr0  <= {ADDR_WIDTH{1'b0}};
            raddr1  <= {ADDR_WIDTH{1'b0}};
            raddr2  <= {ADDR_WIDTH{1'b0}};
            raddr3  <= {ADDR_WIDTH{1'b0}};
            raddr4  <= {ADDR_WIDTH{1'b0}};
            raddr5  <= {ADDR_WIDTH{1'b0}};
            raddr6  <= {ADDR_WIDTH{1'b0}};
            raddr7  <= {ADDR_WIDTH{1'b0}};
            raddr8  <= {ADDR_WIDTH{1'b0}};
            raddr9  <= {ADDR_WIDTH{1'b0}};
            raddr10 <= {ADDR_WIDTH{1'b0}};
            raddr11 <= {ADDR_WIDTH{1'b0}};
            raddr12 <= {ADDR_WIDTH{1'b0}};
            raddr13 <= {ADDR_WIDTH{1'b0}};
            raddr14 <= {ADDR_WIDTH{1'b0}};
            raddr15 <= {ADDR_WIDTH{1'b0}};

            addr_core0_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core1_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core2_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core3_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core4_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core5_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core6_d <= {(ADDR_WIDTH-1){1'b0}};
            addr_core7_d <= {(ADDR_WIDTH-1){1'b0}};

            waddr0  <= {ADDR_WIDTH{1'b0}};
            waddr1  <= {ADDR_WIDTH{1'b0}};
            waddr2  <= {ADDR_WIDTH{1'b0}};
            waddr3  <= {ADDR_WIDTH{1'b0}};
            waddr4  <= {ADDR_WIDTH{1'b0}};
            waddr5  <= {ADDR_WIDTH{1'b0}};
            waddr6  <= {ADDR_WIDTH{1'b0}};
            waddr7  <= {ADDR_WIDTH{1'b0}};
            waddr8  <= {ADDR_WIDTH{1'b0}};
            waddr9  <= {ADDR_WIDTH{1'b0}};
            waddr10 <= {ADDR_WIDTH{1'b0}};
            waddr11 <= {ADDR_WIDTH{1'b0}};
            waddr12 <= {ADDR_WIDTH{1'b0}};
            waddr13 <= {ADDR_WIDTH{1'b0}};
            waddr14 <= {ADDR_WIDTH{1'b0}};
            waddr15 <= {ADDR_WIDTH{1'b0}};
        end 
        else begin
            case(state)
                IDLE: begin
                    we              <= 1'b0;
                    valid_ntt    <= 1'b0;
                    raddr0  <= {ADDR_WIDTH{1'b0}};
                    raddr1  <= {ADDR_WIDTH{1'b0}};
                    raddr2  <= {ADDR_WIDTH{1'b0}};
                    raddr3  <= {ADDR_WIDTH{1'b0}};
                    raddr4  <= {ADDR_WIDTH{1'b0}};
                    raddr5  <= {ADDR_WIDTH{1'b0}};
                    raddr6  <= {ADDR_WIDTH{1'b0}};
                    raddr7  <= {ADDR_WIDTH{1'b0}};
                    raddr8  <= {ADDR_WIDTH{1'b0}};
                    raddr9  <= {ADDR_WIDTH{1'b0}};
                    raddr10 <= {ADDR_WIDTH{1'b0}};
                    raddr11 <= {ADDR_WIDTH{1'b0}};
                    raddr12 <= {ADDR_WIDTH{1'b0}};
                    raddr13 <= {ADDR_WIDTH{1'b0}};
                    raddr14 <= {ADDR_WIDTH{1'b0}};
                    raddr15 <= {ADDR_WIDTH{1'b0}};

                    addr_core0_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core1_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core2_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core3_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core4_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core5_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core6_d <= {(ADDR_WIDTH-1){1'b0}};
                    addr_core7_d <= {(ADDR_WIDTH-1){1'b0}};
        
                    waddr0  <= {ADDR_WIDTH{1'b0}};
                    waddr1  <= {ADDR_WIDTH{1'b0}};
                    waddr2  <= {ADDR_WIDTH{1'b0}};
                    waddr3  <= {ADDR_WIDTH{1'b0}};
                    waddr4  <= {ADDR_WIDTH{1'b0}};
                    waddr5  <= {ADDR_WIDTH{1'b0}};
                    waddr6  <= {ADDR_WIDTH{1'b0}};
                    waddr7  <= {ADDR_WIDTH{1'b0}};
                    waddr8  <= {ADDR_WIDTH{1'b0}};
                    waddr9  <= {ADDR_WIDTH{1'b0}};
                    waddr10 <= {ADDR_WIDTH{1'b0}};
                    waddr11 <= {ADDR_WIDTH{1'b0}};
                    waddr12 <= {ADDR_WIDTH{1'b0}};
                    waddr13 <= {ADDR_WIDTH{1'b0}};
                    waddr14 <= {ADDR_WIDTH{1'b0}};
                    waddr15 <= {ADDR_WIDTH{1'b0}};

                    din     <= {INPUT_WIDTH{1'b0}};
                end 
                LOAD: begin
                    if (valid_input) begin
                        we      <= 1'b1;
                        din     <= in;
                        waddr15 <= (count_load << 4);
                        waddr14 <= (count_load << 4) + 8'd1;
                        waddr13 <= (count_load << 4) + 8'd2;
                        waddr12 <= (count_load << 4) + 8'd3;
                        waddr11 <= (count_load << 4) + 8'd4;
                        waddr10 <= (count_load << 4) + 8'd5;
                        waddr9  <= (count_load << 4) + 8'd6;
                        waddr8  <= (count_load << 4) + 8'd7;
                        waddr7  <= (count_load << 4) + 8'd8;
                        waddr6  <= (count_load << 4) + 8'd9;
                        waddr5  <= (count_load << 4) + 8'd10;
                        waddr4  <= (count_load << 4) + 8'd11;
                        waddr3  <= (count_load << 4) + 8'd12;
                        waddr2  <= (count_load << 4) + 8'd13;
                        waddr1  <= (count_load << 4) + 8'd14;
                        waddr0  <= (count_load << 4) + 8'd15;
                    end 
                    else begin
                        we <= 1'b0;
                    end 
                end
                COMPUTE: begin
                    we              <= ((count >= 7'd8) & (count < 7'd120)) ? 1'b1 : 1'b0;
                    raddr0          <= addr_core0;
                    raddr1          <= addr_core0 + len;
                    raddr2          <= addr_core1;
                    raddr3          <= addr_core1 + len;
                    raddr4          <= addr_core2;
                    raddr5          <= addr_core2 + len;
                    raddr6          <= addr_core3;
                    raddr7          <= addr_core3 + len;
                    raddr8          <= addr_core4;
                    raddr9          <= addr_core4 + len;
                    raddr10         <= addr_core5;
                    raddr11         <= addr_core5 + len;
                    raddr12         <= addr_core6;
                    raddr13         <= addr_core6 + len;
                    raddr14         <= addr_core7;
                    raddr15         <= addr_core7 + len;

                    waddr0          <= hold_addr0[6];
                    waddr1          <= hold_addr0[6] + hold_len[6];
                    waddr2          <= hold_addr1[6];
                    waddr3          <= hold_addr1[6] + hold_len[6];
                    waddr4          <= hold_addr2[6];
                    waddr5          <= hold_addr2[6] + hold_len[6];
                    waddr6          <= hold_addr3[6];
                    waddr7          <= hold_addr3[6] + hold_len[6];
                    waddr8          <= hold_addr4[6];
                    waddr9          <= hold_addr4[6] + hold_len[6];
                    waddr10         <= hold_addr5[6];
                    waddr11         <= hold_addr5[6] + hold_len[6];
                    waddr12         <= hold_addr6[6];
                    waddr13         <= hold_addr6[6] + hold_len[6];
                    waddr14         <= hold_addr7[6];
                    waddr15         <= hold_addr7[6] + hold_len[6];

                    addr_core0_d    <= addr_zeta0;
                    addr_core1_d    <= addr_zeta1;
                    addr_core2_d    <= addr_zeta2;
                    addr_core3_d    <= addr_zeta3;
                    addr_core4_d    <= addr_zeta4;
                    addr_core5_d    <= addr_zeta5;
                    addr_core6_d    <= addr_zeta6;
                    addr_core7_d    <= addr_zeta7;

                    din             <= {din15[11:0], din14[11:0], din13[11:0], din12[11:0], din11[11:0], din10[11:0], 
                                        din9[11:0], din8[11:0], din7[11:0], din6[11:0], din5[11:0], din4[11:0], din3[11:0], din2[11:0], din1[11:0], din0[11:0]};
                end 
                WRITE_OUT: begin
                    we              <= 1'b0;
                    valid_ntt    <= 1'b1;
                    raddr15         <= count_load << 4;
                    raddr14         <= (count_load << 4) + 8'd1;
                    raddr13         <= (count_load << 4) + 8'd2;
                    raddr12         <= (count_load << 4) + 8'd3;
                    raddr11         <= (count_load << 4) + 8'd4;
                    raddr10         <= (count_load << 4) + 8'd5;
                    raddr9          <= (count_load << 4) + 8'd6;
                    raddr8          <= (count_load << 4) + 8'd7;
                    raddr7          <= (count_load << 4) + 8'd8;
                    raddr6          <= (count_load << 4) + 8'd9;
                    raddr5          <= (count_load << 4) + 8'd10;
                    raddr4          <= (count_load << 4) + 8'd11;
                    raddr3          <= (count_load << 4) + 8'd12;
                    raddr2          <= (count_load << 4) + 8'd13;
                    raddr1          <= (count_load << 4) + 8'd14;
                    raddr0          <= (count_load << 4) + 8'd15;
                end 
                DONE: begin
                    done_o          <=  1'b1;
                    valid_ntt    <= 1'b0;
                    we              <= 1'b0;
                end

            endcase
        end 
    end
    assign din0     = (is_NTT) ? A_NTT0 : A_iNTT0;
    assign din1     = (is_NTT) ? B_NTT0 : B_iNTT0;
    assign din2     = (is_NTT) ? A_NTT1 : A_iNTT1;
    assign din3     = (is_NTT) ? B_NTT1 : B_iNTT1;
    assign din4     = (is_NTT) ? A_NTT2 : A_iNTT2;
    assign din5     = (is_NTT) ? B_NTT2 : B_iNTT2;
    assign din6     = (is_NTT) ? A_NTT3 : A_iNTT3;
    assign din7     = (is_NTT) ? B_NTT3 : B_iNTT3;
    assign din8     = (is_NTT) ? A_NTT4 : A_iNTT4;
    assign din9     = (is_NTT) ? B_NTT4 : B_iNTT4;
    assign din10    = (is_NTT) ? A_NTT5 : A_iNTT5;
    assign din11    = (is_NTT) ? B_NTT5 : B_iNTT5;
    assign din12    = (is_NTT) ? A_NTT6 : A_iNTT6;
    assign din13    = (is_NTT) ? B_NTT6 : B_iNTT6;
    assign din14    = (is_NTT) ? A_NTT7 : A_iNTT7;
    assign din15    = (is_NTT) ? B_NTT7 : B_iNTT7;
    assign out_ntt = (valid_ntt) ? {B[7], A[7], B[6], A[6], B[5], A[5], B[4], A[4], B[3], A[3], B[2], A[2], B[1], A[1], B[0], A[0]} : {INPUT_WIDTH{1'b0}};

    // ---------------------------------------------------- Sub module ----------------------------------------------------
    GenAddress #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ADDR_ZETA(ADDR_ZETA)
    ) gen_address (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_gen(load_done),
        .is_NTT(is_NTT),
        .addr_core0(addr_core0), .addr_core1(addr_core1), .addr_core2(addr_core2), .addr_core3(addr_core3), .addr_core4(addr_core4), .addr_core5(addr_core5), .addr_core6(addr_core6), .addr_core7(addr_core7),
        .addr_zeta0(addr_zeta0), .addr_zeta1(addr_zeta1), .addr_zeta2(addr_zeta2), .addr_zeta3(addr_zeta3), .addr_zeta4(addr_zeta4), .addr_zeta5(addr_zeta5), .addr_zeta6(addr_zeta6), .addr_zeta7(addr_zeta7),
        .olen(len),
        .done_o(done_gen_addr)
    );

    RomNTT  rom_ntt (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .address0(addr_core0_d), 
        .address1(addr_core1_d), 
        .address2(addr_core2_d), 
        .address3(addr_core3_d), 
        .address4(addr_core4_d), 
        .address5(addr_core5_d), 
        .address6(addr_core6_d), 
        .address7(addr_core7_d),
        .q0(zeta0), .q1(zeta1), .q2(zeta2), .q3(zeta3), .q4(zeta4), .q5(zeta5), .q6(zeta6), .q7(zeta7)
    );

    MyReg mem(
        .clk_i(clk_i), .rst_i(rst_i),
        .we(we),
        .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2),      .raddr3(raddr3),    .raddr4(raddr4),    .raddr5(raddr5),    .raddr6(raddr6),    .raddr7(raddr7),
        .raddr8(raddr8), .raddr9(raddr9), .raddr10(raddr10),    .raddr11(raddr11),  .raddr12(raddr12),  .raddr13(raddr13),  .raddr14(raddr14),  .raddr15(raddr15),
        .waddr0(waddr0), .waddr1(waddr1), .waddr2(waddr2),      .waddr3(waddr3),    .waddr4(waddr4),    .waddr5(waddr5),    .waddr6(waddr6),    .waddr7(waddr7),
        .waddr8(waddr8), .waddr9(waddr9), .waddr10(waddr10),    .waddr11(waddr11),  .waddr12(waddr12),  .waddr13(waddr13),  .waddr14(waddr14),  .waddr15(waddr15),
        .din(din),
        .dout0(A[0]), .dout1(B[0]),     .dout2(A[1]),   .dout3(B[1]),   .dout4(A[2]),   .dout5(B[2]),   .dout6(A[3]),   .dout7(B[3]), 
        .dout8(A[4]), .dout9(B[4]),     .dout10(A[5]),  .dout11(B[5]),  .dout12(A[6]),  .dout13(B[6]),  .dout14(A[7]),  .dout15(B[7])
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu0 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[0]}), .B({1'b0, B[0]}), .Zeta(zeta0),
        .A_NTT(A_NTT0), .B_NTT(B_NTT0), .A_iNTT(A_iNTT0), .B_iNTT(B_iNTT0)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu1 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[1]}), .B({1'b0, B[1]}), .Zeta(zeta1),
        .A_NTT(A_NTT1), .B_NTT(B_NTT1), .A_iNTT(A_iNTT1), .B_iNTT(B_iNTT1)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu2 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[2]}), .B({1'b0, B[2]}), .Zeta(zeta2),
        .A_NTT(A_NTT2), .B_NTT(B_NTT2), .A_iNTT(A_iNTT2), .B_iNTT(B_iNTT2)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu3 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[3]}), .B({1'b0, B[3]}), .Zeta(zeta3),
        .A_NTT(A_NTT3), .B_NTT(B_NTT3), .A_iNTT(A_iNTT3), .B_iNTT(B_iNTT3)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu4 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[4]}), .B({1'b0, B[4]}), .Zeta(zeta4),
        .A_NTT(A_NTT4), .B_NTT(B_NTT4), .A_iNTT(A_iNTT4), .B_iNTT(B_iNTT4)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu5 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[5]}), .B({1'b0, B[5]}), .Zeta(zeta5),
        .A_NTT(A_NTT5), .B_NTT(B_NTT5), .A_iNTT(A_iNTT5), .B_iNTT(B_iNTT5)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu6 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[6]}), .B({1'b0, B[6]}), .Zeta(zeta6),
        .A_NTT(A_NTT6), .B_NTT(B_NTT6), .A_iNTT(A_iNTT6), .B_iNTT(B_iNTT6)
    );

    BU #(
        .DATA_WIDTH(DATA_WIDTH)
    ) bu7 (
        .clk_i(clk_i), .rst_i(rst_i), .is_NTT(is_NTT),
        .A({1'b0, A[7]}), .B({1'b0, B[7]}), .Zeta(zeta7),
        .A_NTT(A_NTT7), .B_NTT(B_NTT7), .A_iNTT(A_iNTT7), .B_iNTT(B_iNTT7)
    );
    MulPolyiNTT MulPolyiNTT_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .valid_i(valid_ntt),
        .data_i(out_ntt),
        .valid_o(valid_intt),
        .pre_valid_o(pre_valid_intt),
        .data_o(out_intt)
    );
endmodule


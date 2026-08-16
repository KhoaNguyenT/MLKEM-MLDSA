module GenAddress #(
    parameter ADDR_WIDTH = 8,
    parameter ADDR_ZETA = 7
)(
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        start_gen,
    input   wire                        is_NTT,
    output  wire    [ADDR_WIDTH-1:0]    addr_core0,
    output  wire    [ADDR_WIDTH-1:0]    addr_core1,
    output  wire    [ADDR_WIDTH-1:0]    addr_core2,
    output  wire    [ADDR_WIDTH-1:0]    addr_core3,
    output  wire    [ADDR_WIDTH-1:0]    addr_core4,
    output  wire    [ADDR_WIDTH-1:0]    addr_core5,
    output  wire    [ADDR_WIDTH-1:0]    addr_core6,
    output  wire    [ADDR_WIDTH-1:0]    addr_core7,
    output  wire    [ADDR_WIDTH-1:0]    olen,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta0,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta1,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta2,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta3,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta4,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta5,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta6,
    output  wire    [ADDR_ZETA-1:0]     addr_zeta7,
    output  wire                        done_o
);
    localparam IDLE = 0, INIT = 1, GEN = 2, DONE = 3;
    reg   [1:0]               state;
    wire  [1:0]               next_state;  
    reg   [4:0]               count, count_zeta;
    reg   [ADDR_WIDTH-1:0]    len, first_len;
    reg   [ADDR_WIDTH-1:0]    addr_core [0:7];
    reg   [6:0]               addr_zeta [0:7];

    wire  [ADDR_WIDTH-1:0]   start_addr_core0;
    wire  [ADDR_WIDTH-1:0]   start_addr_core1;
    wire  [ADDR_WIDTH-1:0]   start_addr_core2;
    wire  [ADDR_WIDTH-1:0]   start_addr_core3;
    wire  [ADDR_WIDTH-1:0]   start_addr_core4;
    wire  [ADDR_WIDTH-1:0]   start_addr_core5;
    wire  [ADDR_WIDTH-1:0]   start_addr_core6;
    wire  [ADDR_WIDTH-1:0]   start_addr_core7;

    wire  [6:0]              start_addr_zeta0;
    wire  [6:0]              start_addr_zeta1;
    wire  [6:0]              start_addr_zeta2;
    wire  [6:0]              start_addr_zeta3;
    wire  [6:0]              start_addr_zeta4;
    wire  [6:0]              start_addr_zeta5;
    wire  [6:0]              start_addr_zeta6;
    wire  [6:0]              start_addr_zeta7;

    wire  check; 
    reg   done;
    assign done_o = done;
    assign check = (is_NTT) ? (len == 8'd2) : (len == 8'd128);

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
    //         IDLE: next_state = (start_gen) ? INIT : IDLE;
    //         INIT: next_state = GEN;
    //         GEN:  next_state = (check & (count == 5'd15)) ? DONE : GEN;
    //         DONE: next_state = IDLE;
    //         default: next_state = IDLE;
    //     endcase
    // end 
    assign next_state =
        (state == IDLE) ? (start_gen ? INIT : IDLE) :
        (state == INIT) ? GEN :
        (state == GEN)  ? ((check && (count == 5'd15)) ? DONE : GEN) :
        (state == DONE) ?  IDLE :
                        IDLE;
    integer i;
    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < 8; i = i + 1) begin
                addr_core[i] <= {ADDR_WIDTH{1'b0}};
                addr_zeta[i] <= 7'd0;
            end
            len             <= 8'd0;
            first_len       <= 8'd0;
            count           <= 5'd0;
            count_zeta      <= 5'd0;
            done            <= 1'b0;
        end 
        else begin
            case(state)
                IDLE: begin
                    done            <= 1'b0;
                    addr_core[0]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[1]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[2]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[3]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[4]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[5]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[6]    <= {ADDR_WIDTH{1'b0}};
                    addr_core[7]    <= {ADDR_WIDTH{1'b0}};
                    count           <= 5'd0;
                    count_zeta      <= 5'd0;
                    len             <= 8'd0;
                    first_len       <= 8'd0;
                end 
                INIT: begin
                    addr_core[0]    <= 8'd0;
                    len             <= (is_NTT) ? 8'd128 : 8'd2 ;
                    case(is_NTT) 
                        1'b0: begin
                            addr_core[1] <= 8'd32;
                            addr_core[2] <= 8'd64;
                            addr_core[3] <= 8'd96;
                            addr_core[4] <= 8'd128;
                            addr_core[5] <= 8'd160;
                            addr_core[6] <= 8'd192;
                            addr_core[7] <= 8'd224;

                            addr_zeta[0] <= 7'd127;
                            addr_zeta[1] <= 7'd119;
                            addr_zeta[2] <= 7'd111;
                            addr_zeta[3] <= 7'd103;
                            addr_zeta[4] <= 7'd95;
                            addr_zeta[5] <= 7'd87;
                            addr_zeta[6] <= 7'd79;
                            addr_zeta[7] <= 7'd71;
                        end 
                        1'b1: begin
                            addr_core[1] <= 8'd16 ;
                            addr_core[2] <= 8'd32 ;
                            addr_core[3] <= 8'd48 ;
                            addr_core[4] <= 8'd64 ;
                            addr_core[5] <= 8'd80 ;
                            addr_core[6] <= 8'd96 ;
                            addr_core[7] <= 8'd112;

                            addr_zeta[0] <= 7'd1;
                            addr_zeta[1] <= 7'd1;
                            addr_zeta[2] <= 7'd1;
                            addr_zeta[3] <= 7'd1;
                            addr_zeta[4] <= 7'd1;
                            addr_zeta[5] <= 7'd1;
                            addr_zeta[6] <= 7'd1;
                            addr_zeta[7] <= 7'd1;
                        end
                    endcase
                end 
                GEN: begin
                    if (first_len == len - 1) begin
                        first_len       <= 8'd0;
                    end
                    else if (count == 5'd15)
                        first_len   <= 8'd0;
                    else
                        first_len   <= first_len + 1'b1;

                    if (count == 5'd15) begin
                        count           <= 5'd0;
                        count_zeta      <= 5'd0;
                        len             <= (is_NTT) ? (len >> 1) : (len << 1);
                        addr_core[0]    <= start_addr_core0;
                        addr_core[1]    <= start_addr_core1;
                        addr_core[2]    <= start_addr_core2;
                        addr_core[3]    <= start_addr_core3;
                        addr_core[4]    <= start_addr_core4;
                        addr_core[5]    <= start_addr_core5;
                        addr_core[6]    <= start_addr_core6;
                        addr_core[7]    <= start_addr_core7;

                        addr_zeta[0]    <= start_addr_zeta0;
                        addr_zeta[1]    <= start_addr_zeta1;
                        addr_zeta[2]    <= start_addr_zeta2;
                        addr_zeta[3]    <= start_addr_zeta3;
                        addr_zeta[4]    <= start_addr_zeta4;
                        addr_zeta[5]    <= start_addr_zeta5;
                        addr_zeta[6]    <= start_addr_zeta6;
                        addr_zeta[7]    <= start_addr_zeta7;
                    end
                    else begin
                        count   <= count + 1'b1;
                        // addr_core[0]    <= addr_core[0] + 1'b1;
                        // addr_core[1]    <= addr_core[1] + 1'b1;
                        // addr_core[2]    <= addr_core[2] + 1'b1;
                        // addr_core[3]    <= addr_core[3] + 1'b1;
                        // addr_core[4]    <= addr_core[4] + 1'b1;
                        // addr_core[5]    <= addr_core[5] + 1'b1;
                        // addr_core[6]    <= addr_core[6] + 1'b1;
                        // addr_core[7]    <= addr_core[7] + 1'b1;
                        if (is_NTT) begin
                            if (len <= 8'd8) begin
                                if (count_zeta == len[4:0] - 5'd1) begin
                                    count_zeta      <= '0;
                                    addr_zeta[0]    <= addr_zeta[0] + 7'd1;
                                    addr_zeta[1]    <= addr_zeta[1] + 7'd1;
                                    addr_zeta[2]    <= addr_zeta[2] + 7'd1;
                                    addr_zeta[3]    <= addr_zeta[3] + 7'd1;
                                    addr_zeta[4]    <= addr_zeta[4] + 7'd1;
                                    addr_zeta[5]    <= addr_zeta[5] + 7'd1;
                                    addr_zeta[6]    <= addr_zeta[6] + 7'd1;
                                    addr_zeta[7]    <= addr_zeta[7] + 7'd1;
                                end 
                                else begin
                                    count_zeta  <= count_zeta + 1'b1;
                                end 
                            end
                        end
                        else begin
                            if (count_zeta == len[4:0] - 5'd1) begin
                                count_zeta      <= '0;
                                addr_zeta[0]    <= addr_zeta[0] - 7'd1;
                                addr_zeta[1]    <= addr_zeta[1] - 7'd1;
                                addr_zeta[2]    <= addr_zeta[2] - 7'd1;
                                addr_zeta[3]    <= addr_zeta[3] - 7'd1;
                                addr_zeta[4]    <= addr_zeta[4] - 7'd1;
                                addr_zeta[5]    <= addr_zeta[5] - 7'd1;
                                addr_zeta[6]    <= addr_zeta[6] - 7'd1;
                                addr_zeta[7]    <= addr_zeta[7] - 7'd1;
                            end 
                            else begin
                                count_zeta  <= count_zeta + 1'b1;
                            end 
                        end
                        
                        
                        if (len >= 8'd16) begin
                            addr_core[0]    <= addr_core[0] + 8'd1;
                            addr_core[1]    <= addr_core[1] + 8'd1;
                            addr_core[2]    <= addr_core[2] + 8'd1;
                            addr_core[3]    <= addr_core[3] + 8'd1;
                            addr_core[4]    <= addr_core[4] + 8'd1;
                            addr_core[5]    <= addr_core[5] + 8'd1;
                            addr_core[6]    <= addr_core[6] + 8'd1;
                            addr_core[7]    <= addr_core[7] + 8'd1;
                        end
                        else begin
                            if (first_len == len - 1) begin
                                addr_core[0]    <= addr_core[0] + 8'd1 + len;
                                addr_core[1]    <= addr_core[1] + 8'd1 + len;
                                addr_core[2]    <= addr_core[2] + 8'd1 + len;
                                addr_core[3]    <= addr_core[3] + 8'd1 + len;
                                addr_core[4]    <= addr_core[4] + 8'd1 + len;
                                addr_core[5]    <= addr_core[5] + 8'd1 + len;
                                addr_core[6]    <= addr_core[6] + 8'd1 + len;
                                addr_core[7]    <= addr_core[7] + 8'd1 + len;    
                            end 
                            else begin
                                addr_core[0]    <= addr_core[0] + 8'd1;
                                addr_core[1]    <= addr_core[1] + 8'd1;
                                addr_core[2]    <= addr_core[2] + 8'd1;
                                addr_core[3]    <= addr_core[3] + 8'd1;
                                addr_core[4]    <= addr_core[4] + 8'd1;
                                addr_core[5]    <= addr_core[5] + 8'd1;
                                addr_core[6]    <= addr_core[6] + 8'd1;
                                addr_core[7]    <= addr_core[7] + 8'd1;
                            end
                        end  

                    end 
                    
                end 
                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end 
    end 

    DecodeAddress #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) decode_inst (
        .len((is_NTT) ? len >> 1 : len << 1),
        .addr_core0(start_addr_core0),
        .addr_core1(start_addr_core1),
        .addr_core2(start_addr_core2),
        .addr_core3(start_addr_core3),
        .addr_core4(start_addr_core4),
        .addr_core5(start_addr_core5),
        .addr_core6(start_addr_core6),
        .addr_core7(start_addr_core7)
    );
    
    ZetaDecoder #(
        .ADDR_WIDTH(ADDR_ZETA)
    ) ZetaDecoder (
        .len((is_NTT) ? len >> 1 : len << 1),
        .is_NTT(is_NTT),
        .addr_zeta0(start_addr_zeta0),
        .addr_zeta1(start_addr_zeta1),
        .addr_zeta2(start_addr_zeta2),
        .addr_zeta3(start_addr_zeta3),
        .addr_zeta4(start_addr_zeta4),
        .addr_zeta5(start_addr_zeta5),
        .addr_zeta6(start_addr_zeta6),
        .addr_zeta7(start_addr_zeta7)
    );

    assign addr_core0   = addr_core[0];
    assign addr_core1   = addr_core[1];
    assign addr_core2   = addr_core[2];
    assign addr_core3   = addr_core[3];
    assign addr_core4   = addr_core[4];
    assign addr_core5   = addr_core[5];
    assign addr_core6   = addr_core[6];
    assign addr_core7   = addr_core[7];

    assign addr_zeta0   = addr_zeta[0];
    assign addr_zeta1   = addr_zeta[1];
    assign addr_zeta2   = addr_zeta[2];
    assign addr_zeta3   = addr_zeta[3];
    assign addr_zeta4   = addr_zeta[4];
    assign addr_zeta5   = addr_zeta[5];
    assign addr_zeta6   = addr_zeta[6];
    assign addr_zeta7   = addr_zeta[7];
    assign olen         = len;
endmodule


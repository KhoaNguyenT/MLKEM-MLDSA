module MulPoly #(
    parameter WIDTH = 12
    )(
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire    [WIDTH-1:0] a0,
    input   wire    [WIDTH-1:0] a1,
    input   wire    [WIDTH-1:0] b0,
    input   wire    [WIDTH-1:0] b1,
    input   wire    [WIDTH:0]   zetas,
    output  wire    [WIDTH-1:0] res0,
    output  wire    [WIDTH-1:0] res1 
    );
    localparam num_reg_zeta     = 9;
    localparam num_reg_a0_b0    = 9;
    localparam num_reg_obarret3 = 9;

    wire  [((WIDTH + 1) * 2) - 1:0]  a0_b0;
    wire  [((WIDTH + 1) * 2) - 1:0]  a1_b1;
    wire  [((WIDTH + 1) * 2) - 1:0]  a1_b0;
    wire  [((WIDTH + 1) * 2) - 1:0]  a0_b1;
    wire  [((WIDTH + 1) * 2) - 1:0]  a1_b1_zetas;
    wire  [15:0]                     obarret1, obarret2, obarret3;
    wire  [((WIDTH + 1) * 2) - 1:0]  add2, add1;

    reg   [WIDTH - 1:0]                                 reg_res0; 
    reg   [WIDTH - 1:0]                                 reg_res1; 
    reg   [((WIDTH + 1) * num_reg_zeta) - 1:0]          reg_zeta;
    reg   [((WIDTH + 1) * 2 * num_reg_a0_b0) - 1:0]     reg_a0_b0;
    reg   [(WIDTH * num_reg_obarret3) - 1:0]            reg_obarret3;
    
    wire   temp_out;
    assign  temp_out = (&obarret1[15:12]) & (&obarret2[15:12]) & (&obarret3[15:12]);
    
    always @(posedge clk_i) begin
        if(rst_i) begin
            reg_res0        <= 12'b0;
            reg_res1        <= 12'b0;
            reg_zeta        <= {((WIDTH + 1) * num_reg_zeta){1'b0}};
            reg_a0_b0       <= {((WIDTH + 1) * 2 * num_reg_a0_b0){1'b0}};
            reg_obarret3    <= {(WIDTH * num_reg_obarret3){1'b0}};
        end 
        else begin
            reg_zeta        <= {reg_zeta[((WIDTH + 1) * (num_reg_zeta - 1)) - 1:0], zetas};

            reg_a0_b0       <= {reg_a0_b0[(((WIDTH + 1) * 2) * (num_reg_a0_b0 - 1)) - 1:0], a0_b0};
            reg_obarret3    <= {reg_obarret3[(WIDTH * (num_reg_obarret3 - 1)) - 1:0], obarret3[11:0]};
            
            reg_res0        <= obarret2[11:0];
            reg_res1        <= reg_obarret3[(WIDTH * num_reg_obarret3) - 1: WIDTH * (num_reg_obarret3 - 1)];
        end 
    end 

    assign res0 = reg_res0 + {11'b0, temp_out};
    assign res1 = reg_res1;
    wire [25:0] temp_0;
    assign temp_0 = reg_a0_b0[((WIDTH + 1) * 2 * num_reg_a0_b0) - 1: ((WIDTH + 1) * 2) * (num_reg_a0_b0 - 1)];
    assign add1 = a1_b1_zetas   + temp_0;
    assign add2 = a1_b0         + a0_b1;

    Barret_mul barret_inst0(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .C({6'b0, a1_b1}),
        .R(obarret1)
    );

    Barret_mul barret_inst1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .C({{6{add1[((WIDTH+1)*2)-1]}}, add1}),
        // {6{add1[((WIDTH+1)*2)-1]}}  6'b0,
        .R(obarret2)
    );

    Barret_mul barret_inst2(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .C({6'd0, add2}),
        .R(obarret3)
    );

    Mul_12b mul_inst0(
        .clk(clk_i),
        .rst_n(~rst_i),
        .A({1'b0, a0}),
        .B({1'b0, b0}),
        .R(a0_b0)
    );

    Mul_12b mul_inst1(
        .clk(clk_i),
        .rst_n(~rst_i),
        .A({1'b0, a1}),
        .B({1'b0, b1}),
        .R(a1_b1)
    );

    Mul_12b mul_inst2(
        .clk(clk_i),
        .rst_n(~rst_i),
        .A({1'b0, a1}),
        .B({1'b0, b0}),
        .R(a1_b0)
    );

    Mul_12b mul_inst3(
        .clk(clk_i),
        .rst_n(~rst_i),
        .A({1'b0, a0}),
        .B({1'b0, b1}),
        .R(a0_b1)
    );
    logic [12:0] temp;
    assign temp = {reg_zeta[((WIDTH + 1) * num_reg_zeta) - 1: (WIDTH + 1) * (num_reg_zeta - 1)]};
    Mul_12b mul_inst4(
        .clk(clk_i),
        .rst_n(~rst_i),
        .A(obarret1[12:0]),
        //          [            116                 :     104                           ]
        .B(temp),
        .R(a1_b1_zetas)
    );
endmodule 



module MulPolyMatrix #(
    parameter ADDR   = 16,
    parameter WIDTH = 12
)(
    input   wire                       clk_i,
    input   wire                       rst_i,
    input   wire  [3:0]                addr,
    input   wire  [(WIDTH*ADDR)-1:0]   a,    // 16 s? 12-bit
    input   wire  [(WIDTH*ADDR)-1:0]   b,    // 16 s? 12-bit
    output  wire  [(WIDTH*ADDR)-1:0]   res
);

    wire  [WIDTH-1:0] zeta1, zeta2, zeta3, zeta4;

    RomMul RomMul_inst (
        // .clk_i(clk_i),
        // .rst_i(rst_i),
        .address(addr),
        .q({zeta1, zeta2, zeta3, zeta4})   // q[47:36]=z1, [35:24]=z2, [23:12]=z3, [11:0]=z4
    );

    wire  [11:0] tmp [0:15]; // 8 k?t qu? con

    // i = 0: L0 = 0*2*W = 0, GROUP=0 => zeta1, ODD=0 => +zeta1
    MulPoly u_mul0 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[0*2*WIDTH       +: WIDTH]),
        .a0    (a[0*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[0*2*WIDTH       +: WIDTH]),
        .b0    (b[0*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b1, ~zeta4} + 1'b1),
        .res0  (tmp[1]),
        .res1  (tmp[0])
    );

    // i = 1: L0 = 1*2*W = 2W, GROUP=0 => zeta1, ODD=1 => -zeta1
    MulPoly u_mul1 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[1*2*WIDTH       +: WIDTH]),
        .a0    (a[1*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[1*2*WIDTH       +: WIDTH]),
        .b0    (b[1*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b0, zeta4}),
        .res0  (tmp[3]),
        .res1  (tmp[2])
    );

    // i = 2: GROUP=1 => zeta2, ODD=0
    MulPoly u_mul2 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[2*2*WIDTH       +: WIDTH]),
        .a0    (a[2*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[2*2*WIDTH       +: WIDTH]),
        .b0    (b[2*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b1, ~zeta3} + 1'b1),
        .res0  (tmp[5]),
        .res1  (tmp[4])
    );

    // i = 3: GROUP=1 => zeta2, ODD=1 => -zeta2
    MulPoly u_mul3 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[3*2*WIDTH       +: WIDTH]),
        .a0    (a[3*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[3*2*WIDTH       +: WIDTH]),
        .b0    (b[3*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b0, zeta3}),
        .res0  (tmp[7]),
        .res1  (tmp[6])
    );

    // i = 4: GROUP=2 => zeta3, ODD=0
    MulPoly u_mul4 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[4*2*WIDTH       +: WIDTH]),
        .a0    (a[4*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[4*2*WIDTH       +: WIDTH]),
        .b0    (b[4*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b1, ~zeta2} + 1'b1),
        .res0  (tmp[9]),
        .res1  (tmp[8])
    );

    // i = 5: GROUP=2 => zeta3, ODD=1 => -zeta3
    MulPoly u_mul5 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[5*2*WIDTH       +: WIDTH]),
        .a0    (a[5*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[5*2*WIDTH       +: WIDTH]),
        .b0    (b[5*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b0, zeta2}),
        .res0  (tmp[11]),
        .res1  (tmp[10])
    );

    // i = 6: GROUP=3 => zeta4, ODD=0
    MulPoly u_mul6 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[6*2*WIDTH       +: WIDTH]),
        .a0    (a[6*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[6*2*WIDTH       +: WIDTH]),
        .b0    (b[6*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b1, ~zeta1} + 1'b1),
        .res0  (tmp[13]),
        .res1  (tmp[12])
    );

    // i = 7: GROUP=3 => zeta4, ODD=1 => -zeta4
    MulPoly u_mul7 (
        .clk_i   (clk_i),
        .rst_i (rst_i),
        .a1    (a[7*2*WIDTH       +: WIDTH]),
        .a0    (a[7*2*WIDTH+WIDTH +: WIDTH]),
        .b1    (b[7*2*WIDTH       +: WIDTH]),
        .b0    (b[7*2*WIDTH+WIDTH +: WIDTH]),
        .zetas ({1'b0, zeta1}),
        .res0  (tmp[15]),
        .res1  (tmp[14])
    );

    // assign res = {{2'b0, tmp[15]}, {2'b0, tmp[14]}, {2'b0, tmp[13]}, {2'b0, tmp[12]}, {2'b0, tmp[11]}, {2'b0, tmp[10]}, {2'b0, tmp[9]}, {2'b0, tmp[8]},
    //               {2'b0, tmp[7]},  {2'b0, tmp[6]},  {2'b0, tmp[5]},  {2'b0, tmp[4]},  {2'b0, tmp[3]},  {2'b0, tmp[2]},  {2'b0, tmp[1]},  {2'b0, tmp[0]}};

    assign res = {tmp[15], tmp[14], tmp[13], tmp[12], tmp[11], tmp[10], tmp[9], tmp[8],
                  tmp[7],  tmp[6],  tmp[5],  tmp[4],  tmp[3],  tmp[2],  tmp[1],  tmp[0]};
endmodule

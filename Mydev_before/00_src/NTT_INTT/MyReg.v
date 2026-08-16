module MyReg #(
parameter WIDTH = 12,
parameter DEPTH = 256,
parameter INPUT_WIDTH = WIDTH * 16,
parameter ADDR_WIDTH = 8
)(
input   wire                    clk_i,
input   wire                    rst_i,
input   wire                    we,
/*--------------------------------*/
input   wire  [ADDR_WIDTH - 1:0] raddr0 , 
input   wire  [ADDR_WIDTH - 1:0] raddr1 , 
input   wire  [ADDR_WIDTH - 1:0] raddr2 , 
input   wire  [ADDR_WIDTH - 1:0] raddr3 , 
input   wire  [ADDR_WIDTH - 1:0] raddr4 , 
input   wire  [ADDR_WIDTH - 1:0] raddr5 , 
input   wire  [ADDR_WIDTH - 1:0] raddr6 , 
input   wire  [ADDR_WIDTH - 1:0] raddr7 , 
input   wire  [ADDR_WIDTH - 1:0] raddr8 , 
input   wire  [ADDR_WIDTH - 1:0] raddr9 , 
input   wire  [ADDR_WIDTH - 1:0] raddr10,
input   wire  [ADDR_WIDTH - 1:0] raddr11,
input   wire  [ADDR_WIDTH - 1:0] raddr12,
input   wire  [ADDR_WIDTH - 1:0] raddr13,
input   wire  [ADDR_WIDTH - 1:0] raddr14,
input   wire  [ADDR_WIDTH - 1:0] raddr15,

input   wire  [ADDR_WIDTH - 1:0] waddr0 , 
input   wire  [ADDR_WIDTH - 1:0] waddr1 , 
input   wire  [ADDR_WIDTH - 1:0] waddr2 , 
input   wire  [ADDR_WIDTH - 1:0] waddr3 , 
input   wire  [ADDR_WIDTH - 1:0] waddr4 , 
input   wire  [ADDR_WIDTH - 1:0] waddr5 , 
input   wire  [ADDR_WIDTH - 1:0] waddr6 , 
input   wire  [ADDR_WIDTH - 1:0] waddr7 , 
input   wire  [ADDR_WIDTH - 1:0] waddr8 , 
input   wire  [ADDR_WIDTH - 1:0] waddr9 , 
input   wire  [ADDR_WIDTH - 1:0] waddr10,
input   wire  [ADDR_WIDTH - 1:0] waddr11,
input   wire  [ADDR_WIDTH - 1:0] waddr12,
input   wire  [ADDR_WIDTH - 1:0] waddr13,
input   wire  [ADDR_WIDTH - 1:0] waddr14,
input   wire  [ADDR_WIDTH - 1:0] waddr15,

input   wire  [INPUT_WIDTH-1:0] din,
/*--------------------------------*/
output  wire  [WIDTH - 1:0] dout0 , 
output  wire  [WIDTH - 1:0] dout1 , 
output  wire  [WIDTH - 1:0] dout2 , 
output  wire  [WIDTH - 1:0] dout3 , 
output  wire  [WIDTH - 1:0] dout4 , 
output  wire  [WIDTH - 1:0] dout5 , 
output  wire  [WIDTH - 1:0] dout6 , 
output  wire  [WIDTH - 1:0] dout7 , 
output  wire  [WIDTH - 1:0] dout8 , 
output  wire  [WIDTH - 1:0] dout9 , 
output  wire  [WIDTH - 1:0] dout10,
output  wire  [WIDTH - 1:0] dout11,
output  wire  [WIDTH - 1:0] dout12,
output  wire  [WIDTH - 1:0] dout13,
output  wire  [WIDTH - 1:0] dout14,
output  wire  [WIDTH - 1:0] dout15
);
    reg     [WIDTH -1: 0] memory [0:DEPTH-1];
    integer i;
    always @(posedge clk_i) begin
        if (rst_i) begin
            for (i = 0; i < DEPTH; i = i + 1'b1)
                memory[i] <= {WIDTH{1'b0}};
        end
        else begin
            if (we) begin
                memory[waddr0] <= din[WIDTH-1:0];
                memory[waddr1] <= din[2*WIDTH-1:WIDTH];
                memory[waddr2] <= din[3*WIDTH-1:2*WIDTH];
                memory[waddr3] <= din[4*WIDTH-1:3*WIDTH];
                memory[waddr4] <= din[5*WIDTH-1:4*WIDTH];
                memory[waddr5] <= din[6*WIDTH-1:5*WIDTH];
                memory[waddr6] <= din[7*WIDTH-1:6*WIDTH];
                memory[waddr7] <= din[8*WIDTH-1:7*WIDTH];
                memory[waddr8] <= din[9*WIDTH-1:8*WIDTH];
                memory[waddr9] <= din[10*WIDTH-1:9*WIDTH];
                memory[waddr10] <= din[11*WIDTH-1:10*WIDTH];
                memory[waddr11] <= din[12*WIDTH-1:11*WIDTH];
                memory[waddr12] <= din[13*WIDTH-1:12*WIDTH];
                memory[waddr13] <= din[14*WIDTH-1:13*WIDTH];
                memory[waddr14] <= din[15*WIDTH-1:14*WIDTH];
                memory[waddr15] <= din[16*WIDTH-1:15*WIDTH];
            end
        end
    end
    assign dout0 = memory[raddr0];
    assign dout1 = memory[raddr1];
    assign dout2 = memory[raddr2];
    assign dout3 = memory[raddr3];
    assign dout4 = memory[raddr4];
    assign dout5 = memory[raddr5];
    assign dout6 = memory[raddr6];
    assign dout7 = memory[raddr7];
    assign dout8 = memory[raddr8];
    assign dout9 = memory[raddr9];
    assign dout10 = memory[raddr10];
    assign dout11 = memory[raddr11];
    assign dout12 = memory[raddr12];
    assign dout13 = memory[raddr13];
    assign dout14 = memory[raddr14];
    assign dout15 = memory[raddr15];
endmodule

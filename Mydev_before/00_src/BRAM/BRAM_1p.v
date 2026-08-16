module BRAM_1p #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH      = (1 <<ADDR_WIDTH)
) (
    input   wire                       clk ,
    input   wire                       ena ,
    input   wire                       wea ,
    input   wire   [ADDR_WIDTH-1:0]    addr,
    input   wire   [DATA_WIDTH-1:0]    din ,
    output  reg    [DATA_WIDTH-1:0]    dout

);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // logic [DATA_WIDTH-1:0] temp_reg, temp_reg_b;

    always @(posedge clk) begin
        if (ena) begin
            if (wea) begin
                mem[addr] <= din;
                dout  <= din;
            end
            else begin
                dout  <= mem[addr];
            end
            // dout  <=  temp_reg;
        end
        else begin
            dout  <=  0;
        end
    end
endmodule

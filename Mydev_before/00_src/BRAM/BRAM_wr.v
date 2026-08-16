module BRAM_wr #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH      = (1 <<ADDR_WIDTH)
) (
    input   wire                       clk,
    input   wire                       we,
    input   wire   [ADDR_WIDTH-1:0]    addr_write,
    input   wire   [DATA_WIDTH-1:0]    din,

    
    input   wire   [ADDR_WIDTH-1:0]    addr_read,
    output  reg    [DATA_WIDTH-1:0]    dout

);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // logic [DATA_WIDTH-1:0] temp_reg, temp_reg_b;

    always @(posedge clk) begin
        if (we) begin
            mem[addr_write] <= din;
        end
        dout <= mem[addr_read];
    end
endmodule

module BRAM_2p #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH      = (1 << ADDR_WIDTH)
) (
    input   wire                       clk_a ,
    input   wire                       ena_a ,
    input   wire                       wea_a ,
    input   wire   [ADDR_WIDTH-1:0]    addr_a,
    input   wire   [DATA_WIDTH-1:0]    din_a ,
    output  reg    [DATA_WIDTH-1:0]    dout_a,

    
    input   wire                       clk_b ,
    input   wire                       ena_b ,
    input   wire                       wea_b ,
    input   wire   [ADDR_WIDTH-1:0]    addr_b,
    input   wire   [DATA_WIDTH-1:0]    din_b ,
    output  reg    [DATA_WIDTH-1:0]    dout_b
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    // logic [DATA_WIDTH-1:0] temp_reg_a, temp_reg_b;

    always @(posedge clk_a) begin
        if (ena_a) begin
            if (wea_a) begin
                mem[addr_a] <= din_a;
                dout_a  <= din_a;
            end
            else begin
                dout_a  <= mem[addr_a];
            end
            // dout_a  <=  temp_reg_a;
        end
        else begin
            dout_a  <=  0;
        end
    end
    always @(posedge clk_b) begin
        if (ena_b) begin
            if (wea_b) begin
                mem[addr_b] <= din_b;
                dout_b  <= din_b;
            end
            else begin
                dout_b  <= mem[addr_b];
            end
            // dout_b  <=  temp_reg_b;
        end
        else begin
            dout_b  <=  0;
        end
    end
endmodule

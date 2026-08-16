module test (	
    input   logic               clk_i,
	// input   logic               clk_a ,
    input   logic               ena_a ,
    input   logic               wea_a ,
    input   logic   [10-1:0]    addr_a,
    input   logic   [192-1:0]   din_a ,
    output  logic   [192-1:0]   dout_a,

    
    // input   logic               clk_b ,
    input   logic               ena_b ,
    input   logic               wea_b ,
    input   logic   [10-1:0]    addr_b,
    input   logic   [192-1:0]   din_b ,
    output  logic   [192-1:0]   dout_b
);

logic ena_a_reg, wea_a_reg;
logic [10-1:0] addr_a_reg;
logic [192-1:0] din_a_reg;

logic ena_b_reg, wea_b_reg;
logic [10-1:0] addr_b_reg;
logic [192-1:0] din_b_reg;

always @(posedge clk_i) begin
    ena_a_reg   <= ena_a;
    wea_a_reg   <= wea_a;
    addr_a_reg  <= addr_a;
    din_a_reg   <= din_a;
    
    ena_b_reg   <= ena_b;
    wea_b_reg   <= wea_b;
    addr_b_reg  <= addr_b;
    din_b_reg   <= din_b;
end

    BRAM module_inst(
        .clk_a (clk_i),
        .ena_a (ena_a_reg ),
        .wea_a (wea_a_reg ),
        .addr_a(addr_a_reg),
        .din_a (din_a_reg ),
        .dout_a(dout_a),
        .clk_b (clk_i),
        .ena_b (ena_b_reg ),
        .wea_b (wea_b_reg ),
        .addr_b(addr_b_reg),
        .din_b (din_b_reg ),
        .dout_b(dout_b)
    );
endmodule

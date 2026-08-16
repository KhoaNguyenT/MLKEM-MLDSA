module top (
    input   logic           clk_i,
    input   logic           rst_i,
    input   logic           id_i,
    input   logic   [10:0]  CMP_data_i,
    output  logic   [11:0]  CMP_data_o
);
    logic           id_i_reg;
    logic   [10:0]  CMP_data_i_reg;
    always @(posedge clk_i) begin
        if (rst_i) begin
            id_i_reg        <= 0;
            CMP_data_i_reg  <= 0;
        end
        else begin
            id_i_reg        <= id_i;
            CMP_data_i_reg  <= CMP_data_i;
        end
    end
    
    test test_inst (
        .iD(id_i_reg),
        .iCoeff(CMP_data_i),
        .oCoeff(CMP_data_o)
    );
endmodule
module CBDSampleOut (
    input   wire           clk_i,
    input   wire           rst_i,
    input   wire           valid_i,
    output  wire           done_ring_o
);
    reg   [4:0] count_valid;
    assign  done_ring_o = count_valid[4];
    always @(posedge clk_i) begin
        if (rst_i) begin
            count_valid <= 0;
        end
        else if (valid_i & !rst_i) begin
            count_valid <= count_valid + 1;
        end
    end
endmodule

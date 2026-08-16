module KeccakLData (
    input   wire            ena_i,
    input   wire    [7:0]   last_Block_i,
    input   wire            mode_last_i,

    output  wire    [63:0]  last_Block_o,
    output  wire            last_hash_o,
    output  wire    [2:0]   lnum_hash_o
);
    assign last_Block_o = {last_Block_i, 56'b0};
    assign last_hash_o  = ena_i;

    assign lnum_hash_o  = (mode_last_i) ? 3'b001 : 3'b000;
endmodule

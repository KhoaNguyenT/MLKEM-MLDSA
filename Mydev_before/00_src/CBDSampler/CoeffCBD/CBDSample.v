module CBDSample (
    input  wire    [5:0]   bits_i,
    input  wire            eta_i, // 0: Eta=2, 1: Eta=3
    output wire    [11:0]  coeff_o
);
    localparam          Q = 3329;
    wire           [2:0] a, b;              
    wire           [3:0] diff_signed; 

    assign a = {2'b00, bits_i[0]} + {2'b00, bits_i[1]} + {2'b00, (eta_i & bits_i[2])};

    assign b = {2'b00, (~eta_i & bits_i[2])} + {2'b00, bits_i[3]} + {2'b00, bits_i[4]} + {2'b00, bits_i[5]};

    assign diff_signed = {1'b0, a} - {1'b0, b};

    assign coeff_o = (diff_signed[3]) ? {{8{diff_signed[3]}}, diff_signed} + Q : {8'b0, diff_signed};

endmodule

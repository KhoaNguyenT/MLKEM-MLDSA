module Controller_ADD (
    input   wire           A_valid_i,
    input   wire [191:0]   A, // 16 số x 12 bit = 192 bit
    input   wire           B_valid_i,
    input   wire [191:0]   B, // 16 số x 12 bit = 192 bit
    
    output  wire           oSum_valid_i,
    output  wire [191:0]   oSum // 16 kết quả x 12 bit = 192 bit
);  
    assign oSum_valid_i = A_valid_i & B_valid_i;
    add add_inst (
        .iA_flat(A),
        .iB_flat(B),
        .oSum_flat(oSum)
    );
endmodule

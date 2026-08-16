module BoothDecode_mul #(
    parameter WIDTH = 13
)(
    input   wire   [WIDTH-1:0] A,
    input   wire   [2:0]       sel,
    output  wire   [WIDTH:0]   res
);
    wire [WIDTH:0] pp;
    wire [WIDTH:0] temp_A;
    assign temp_A = {1'b0, A};
    // always @(*) begin
    //     case(sel)
    //         3'b000, 3'b111: pp = {(WIDTH + 1){1'b0}};   // no operation
    //         3'b001, 3'b010: pp = temp_A;             // +A
    //         3'b011: pp = temp_A << 1;                        // +2A
    //         3'b100: pp = ~(temp_A << 1) + 1'b1;              // -2A
    //         3'b101, 3'b110: pp = ~(temp_A) + 1'b1;           // -A
    //         default: pp = {(WIDTH + 1){1'b0}};
    //     endcase
    // end 
    assign pp =
        (sel == 3'b000 || sel == 3'b111) ? {(WIDTH+1){1'b0}} :
        (sel == 3'b001 || sel == 3'b010) ?  temp_A :
        (sel == 3'b011)                  ?  (temp_A << 1) :
        (sel == 3'b100)                  ?  (~(temp_A << 1) + 1'b1) :
        (sel == 3'b101 || sel == 3'b110) ?  (~temp_A + 1'b1) :
                                            {(WIDTH+1){1'b0}};
    assign res = pp;
endmodule

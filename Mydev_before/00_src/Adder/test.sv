module test (
    input   logic   [32-1:0]   a,
    input   logic   [32-1:0]   b,
    input   logic   [32-1:0]   cin,
    output  logic   [32-1:0]   sum,
    output  logic   [32-1:0]   carry
);
    CSA CSA_m (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .carry(carry)
    );
endmodule

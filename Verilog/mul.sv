
module WallaceTreeMultiplier #(
    parameter N = 4
)(
    input [N-1:0] a,
    input [N-1:0] b,
    output [(2*N)-1:0] product
);

    wire [N-1:0]a_unsigned = (a[N-1] == 1'b1) ? -a : a;
    wire [N-1:0]b_unsigned = (b[N-1] == 1'b1) ? -b : b;
    wire [(2*N)-1:0] product_unsigned;

    WallaceTreeMultiplierUnsigned #(.N(N)) multiplier_unsigned (
        .a({a_unsigned}),
        .b({b_unsigned}),
        .product(product_unsigned)
    );

    assign product = a[N-1] == b[N-1] ? product_unsigned : -product_unsigned;

endmodule

module WallaceTreeMultiplierUnsigned #(
    parameter N = 4
)(
    input [N-1:0] a,
    input [N-1:0] b,
    output [(2*N)-1:0] product
);

    // Generate partial products (PP0-PP3)
    wire [(2*N)-1:0] PP0, PP1, PP2, PP3;

    assign PP0 = {{N{1'b0}}, a & {N{b[0]}}};           // PP0 = a * b[0], shifted by 0
    assign PP1 = {{(N-1){1'b0}}, (a & {N{b[1]}}), 1'b0};   // PP1 = a * b[1], shifted by 1
    assign PP2 = {{(N-2){1'b0}}, (a & {N{b[2]}}), 2'b0};   // PP2 = a * b[2], shifted by 2
    assign PP3 = {{(N-3){1'b0}}, (a & {N{b[3]}}), 3'b0};   // PP3 = a * b[3], shifted by 3

    // Stage 1: Reduce PP0, PP1, PP2 to S1 and C1
    wire [(2*N)-1:0] S1;
    wire [(2*N)-1:0] C1;
    CSA #(.N(2*N)) csa_stage1 (
        .A(PP0),
        .B(PP1),
        .C(PP2),
        .S(S1),
        .Cout(C1)
    );

    // Stage 2: Reduce S1, C1, PP3 to S2 and C2
    wire [(2*N)-1:0] S2;
    wire [(2*N)-1:0] C2;
    CSA #(.N(2*N)) csa_stage2 (
        .A(S1),
        .B({C1[(2*N)-2:0], 1'b0}),  // Shift C1 left by 1
        .C(PP3),
        .S(S2),
        .Cout(C2)
    );

    // Final adder: Add S2 and C2 (with carry-in)
    wire [(2*N)-1:0] sum;
    assign sum = S2 + {C2[(2*N)-2:0], 1'b0};  // Shift C2 left by 1

    assign product = sum;

endmodule

module CSA #(parameter N = 8) (
    input [N-1:0] A,
    input [N-1:0] B,
    input [N-1:0] C,
    output [N-1:0] S,
    output [N-1:0] Cout  // Carry is N bits (no extra bit)
);

    // Bitwise sum and carry generation
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : csa_loop
            assign S[i] = A[i] ^ B[i] ^ C[i];
            assign Cout[i] = (A[i] & B[i]) | (A[i] & C[i]) | (B[i] & C[i]);
        end
    endgenerate

endmodule
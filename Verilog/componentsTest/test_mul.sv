module test_mul;

reg signed[7:0] a, b;
wire signed[15:0] product;
WallaceTreeMultiplier #(.N(8)) test_mul (
    .a(a),
    .b(b),
    .product(product)
);

initial begin
    shortint i, j;

    $write("B \\A:");
    for (i = -128; i < 128; i = i + 8) begin
        a = i;
        #1
        $write("  %d", a);
    end
    for (i = -128; i < 128; i = i + 8) begin
        a = i;
        #1
        $write("\n%d:", a);
        for (j = -128; j < 128; j = j + 8) begin
            b = j;
            #1;
            $write("%d", product);
        end
    end    
end

endmodule
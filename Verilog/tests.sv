module tests();
reg [4:0]test = 5'b00000;

wire testxor = ~|test;

initial begin
    repeat(32) begin
        $display("test %b testxor = %b",test, testxor);
        test = test + 1;
    end    

    $finish;
end

endmodule
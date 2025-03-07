module test_alu;
    reg clock;
    reg write;
    reg use_pc;
    reg [31:0] program_counter;
    reg use_immediate;
    reg signed [31:0] a;
    reg signed [31:0] b;
    reg signed [31:0] immediate;
    reg [4:0] operation;
    wire [31:0] result;
    wire [3:0] cnzv;
    
    alu alu0 (
        .clock(clock),
        .write(write),
        .use_pc(use_pc),
        .a(a),
        .program_counter(program_counter),
        .use_immediate(use_immediate),
        .b(b),
        .immediate(immediate),
        .operation(operation),
        .result(result),
        .cnzv(cnzv)
    );

    initial begin
        // Initialize clock
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        // Test ADD (operation 0)
        a = -50; b = 43; operation = 0; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("ADD: %0d + %0d = %0d, CNZV = %b", a, b, result, cnzv);
        
        // Test for overflow
        a = 2147483647; b = 1; operation = 0; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("ADD Overflow: %0d + %0d = %0d, CNZV = %b", a, b, $signed(result), cnzv);
           
        // Test for Carry
        a = 4294967295; b = 1; operation = 0; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("ADD Carry(unsigned): %0d + %0d = %0d, CNZV = %b", $unsigned(a), b, result, cnzv);
       
        // Test for Zero
        a = 0; b = 0; operation = 0; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("ADD Zero: %0d + %0d = %0d, CNZV = %b", a, b, result, cnzv);
        
        // Test Shift Left (operation 1)
        a = 15; b = 2; operation = 1; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("Shift Left: %0d << %0d = %0d", a, b, result);
        
        // Test Less Than (signed) (operation 2)
        a = -1; b = 0; operation = 2; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("Less Than: %0d < %0d = %0d, alu_res = %0d", a, b, result, alu0.result);
        
        // Test Less Than (unsigned) (operation 3)
        a = -1; b = 0; operation = 3; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("Less Than (unsigned): %0d < %0d =  %0d, alu_res = %0d", $unsigned(a), $unsigned(b), result, alu0.result);

        // Test XOR (operation 4)
        a = 15; b = 27; operation = 4; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("XOR: %0d ^ %0d = %0d", a, b, result);
        
        // Test Shift Right (logical) (operation 5)
        a = 16; b = 2; operation = 5; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("Shift Right: %0d >> %0d = %0d", a, b, result);
        
        // Test OR (operation 6)
        a = 15; b = 27; operation = 6; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("OR: %0d | %0d = %0d", a, b, result);
        
        // Test AND (operation 7)
        a = 15; b = 27; operation = 7; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("AND: %0d & %0d = %0d", a, b, result);
        
        // Test Multiply (operation 8)
        a = -43; b = 43; operation = 8; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("MUL: %0d * %0d = %0d", a, b, result);
        
        // Test Multiply High Signed x Signed (operation 9)
        a = -43; b = 43; operation = 9; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("MULHS: %0d * %0d = %0d", a, b, result);

        // Test Multiply High Signed x Unsigned (operation 10)
        a = -43; b = 43; operation = 10; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("MULHSU: %0d * %0d = %0d", a, b, result);
        
        // Test Multiply High Signed x Unsigned (operation 10)
        a = 43; b = -43; operation = 10; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("MULHSU: %0d * %0d = %0d", a, b, result);

        // Test Multiply High Unsigned x Unsigned (operation 11)
        a = 43; b = -43; operation = 11; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("MULHU: %0d * %0d = %0d", a, b, result);
        
        // Test Subtract (operation 16)
        a = 100; b = 43; operation = 16; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("SUB: %0d - %0d = %0d", a, b, result);
        
        // Test for overflow
        a = -2147483648; b = 1; operation = 16; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("SUB Overflow: %0d - %0d = %0d, CNZV = %b", a, b, result, cnzv);
        
        // Test Arithmetic Shift Right (operation 21)
        a = -16; b = 2; operation = 21; write = 1; use_pc = 0; use_immediate = 0;
        #10 write = 0; #10;
        $display("Arithmetic Shift Right: %0d >>> %0d = %0d", a, b, result);

        $finish;
    end
endmodule
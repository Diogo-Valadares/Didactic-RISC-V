module test_register_bank;
    reg clock;
    reg reset;
    reg write;
    reg [4:0] a_address;
    reg [4:0] b_address;
    reg [4:0] c_address;
    reg [31:0] c_in;
    wire [31:0] a_out;
    wire [31:0] b_out;

    // Instantiate the register_bank module
    register_bank uut (
        .clock(clock),
        .reset(reset),
        .write(write),
        .a_address(a_address),
        .b_address(b_address),
        .c_address(c_address),
        .c_in(c_in),
        .a_out(a_out),
        .b_out(b_out)
    );

    // Generate clock signal
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Clock period of 10 units
    end

    initial begin
        // Initialize signals
        reset = 0;
        write = 0;
        a_address = 0;
        b_address = 0;
        c_address = 0;
        c_in = 32'b0;
        
        // Apply reset
        #10 reset = 1;
        #10 reset = 0;

        // Test write to register
        #10 write = 1; c_address = 5; c_in = 32'hDEADBEEF;
        #10 write = 0;

        // Test read from register
        #10 a_address = 5;
        #10 b_address = 5;

        // Apply reset during operation
        #10 reset = 1;
        #10 reset = 0;

        // Test write to register after reset
        #10 write = 1; c_address = 10; c_in = 32'hCAFEBABE;
        #10 write = 0;

        // Test read from register after reset
        #10 a_address = 10;
        #10 b_address = 10;

        // Finish simulation
        #50 $finish;
    end

    // Monitor output signals
    initial begin
        $monitor("Time: %0t | reset: %b, write: %b, a_address: %h, b_address: %h, c_address: %h, c_in: %h | a_out: %h, b_out: %h",
                  $time, reset, write, a_address, b_address, c_address, c_in, a_out, b_out);
    end

endmodule

module test_program_counter;

    reg reset;
    reg clock;
    reg write;
    reg jump;
    reg use_offset;
    reg address_in_to_AD;
    reg [31:0] address_in;
    wire [1:0] data_offset;
    wire [31:0] next;
    wire [31:0] current;
    wire [31:0] last;
    wire [31:0] AD_Bus;

    // Instantiate the program_counter module
    program_counter uut (
        .reset(reset),
        .clock(clock),
        .write(write),
        .jump(jump),
        .use_offset(use_offset),
        .address_in_to_AD(address_in_to_AD),
        .address_in(address_in),
        .data_offset(data_offset),
        .next(next),
        .current(current),
        .last(last),
        .AD_Bus(AD_Bus)
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
        jump = 0;
        use_offset = 0;
        address_in_to_AD = 0;
        address_in = 32'b0;
        
        // Apply reset
        #10 reset = 1;
        #10 reset = 0;

        // Test normal increment
        #10 write = 1;
        #10 write = 0;
        #10 write = 1;
        #10 write = 0;
        #10 write = 1;
        #10 write = 0;
        #10 write = 1;
        #10 write = 0;

        // Test jump
        #10 address_in = 32'h00000020; jump = 1; write = 1;
        #10 jump = 0; write = 0;

        // Test use_offset
        #10 address_in_to_AD = 1; use_offset = 1; address_in = 32'h00000011;
        #10 address_in_to_AD = 0; use_offset = 0;
        #10 address_in_to_AD = 1; use_offset = 1; address_in = 32'h00000012;
        #10 address_in_to_AD = 0; use_offset = 0;
        #10 address_in_to_AD = 1; use_offset = 1; address_in = 32'h00000013;
        #10 address_in_to_AD = 0; use_offset = 0;
        // Test reset during operation
        #10 write = 1; reset = 1;
        #10 reset = 0; write = 0;

        // Finish simulation
        #10$finish;
    end

    // Monitor output signals
    initial begin
        $monitor("Time: %0t | reset: %b, write: %b, jump: %b, use_offset: %b, address_in_to_AD: %b, address_in: %h | next: %h, current: %h, last: %h, AD_Bus: %h, data_offset: %b",
                  $time, reset, write, jump, use_offset, address_in_to_AD, address_in, next, current, last, AD_Bus, data_offset);
    end

endmodule
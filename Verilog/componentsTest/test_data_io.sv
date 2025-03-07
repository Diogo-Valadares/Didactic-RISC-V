module test_data_io;

    reg clock;
    reg store;
    reg load;
    reg [2:0] data_type;
    reg [1:0] data_offset;
    reg [31:0] cpu_in;
    reg [31:0] io_in;
    wire [31:0] cpu_out;
    wire [31:0] io_out;

    // Instantiate the data_io module
    data_io uut (
        .clock(clock),
        .store(store),
        .load(load),
        .data_type(data_type),
        .data_offset(data_offset),
        .cpu_in(cpu_in),
        .io_in(io_in),
        .cpu_out(cpu_out),
        .io_out(io_out)
    );

    // Generate clock signal
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Clock period of 10 units
    end

    initial begin
        // Initialize signals
        store = 0;
        load = 0;
        data_type = 3'b000;
        data_offset = 2'b00;
        cpu_in = 32'hDDCCBBAA;
        io_in = 32'hDDCCBBAA;
        
        // Apply store
        #10 store = 1;
        #10 store = 0;

        // Apply load
        #10 load = 1;
        #10 load = 0;
        
        // Test different data types
        $display("0 offset");
        #10 data_type = 3'b000; data_offset = 2'b00; // Byte load
        #10 data_type = 3'b001; data_offset = 2'b00; // Half-word load
        #10 data_type = 3'b100; data_offset = 2'b00; // Signed byte load
        #10 data_type = 3'b101; data_offset = 2'b00; // Signed half-word load
        #10 data_type = 3'b111; data_offset = 2'b00; // Word load
        #10 $display("1 offset");
        #10 data_type = 3'b000; data_offset = 2'b01; // Byte load
        #10 data_type = 3'b001; data_offset = 2'b01; // Half-word load
        #10 data_type = 3'b100; data_offset = 2'b01; // Signed byte load
        #10 data_type = 3'b101; data_offset = 2'b01; // Signed half-word load
        #10 $display("2 offset");
        #10 data_type = 3'b000; data_offset = 2'b10; // Byte load
        #10 data_type = 3'b001; data_offset = 2'b10; // Half-word load
        #10 data_type = 3'b100; data_offset = 2'b10; // Signed byte load
        #10 data_type = 3'b101; data_offset = 2'b10; // Signed half-word load
        #10 $display("3 offset");
        #10 data_type = 3'b000; data_offset = 2'b11; // Byte load
        #10 data_type = 3'b100; data_offset = 2'b11; // Signed byte load

        // Finish simulation
        #50 $finish;
    end

    // Monitor output signals
    initial begin
        $monitor("Time: %0t | store: %b, load: %b, data_type: %b, data_offset: %b, cpu_in: %h, io_in: %h | cpu_out: %h, io_out: %h",
                  $time, store, load, data_type, data_offset, cpu_in, io_in, cpu_out, io_out);
    end

endmodule

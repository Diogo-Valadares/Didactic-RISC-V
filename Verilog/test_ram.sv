module test_ram;

    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter MEM_DEPTH = 1 << ADDR_WIDTH;

    // Signals
    reg clock;
    reg write;
    reg read;
    reg write_address;
    reg [1:0] data_size;
    reg [ADDR_WIDTH-1 : 0] address;
    wire [31:0] data;
    reg [31:0] data_reg;
    assign data = (write) ? data_reg : 32'bz;

    // Instantiate the RAM module
    ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .MEM_DEPTH(MEM_DEPTH)
    ) uut (
        .clock(clock),
        .write(write),
        .read(read),
        .write_address(write_address),
        .data_size(data_size),
        .address(address),
        .data(data)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Test sequence
    initial begin
        // Initialize signals
        write = 0;
        read = 0;
        write_address = 0;
        data_size = 2'b00;
        address = 0;
        data_reg = 0;

        // Test 1: Write and read 1 byte
        #10;
        write_address = 1;
        address = 16'h0001;
        #10;
        write_address = 0;
        write = 1;
        data_size = 2'b00;
        data_reg = 32'h000000AA;
        #10;
        write = 0;
        read = 1;
        #10;
        $display("Test 1: Read data = %h", data);
        read = 0;

        // Test 2: Write and read 2 bytes
        #10;
        write_address = 1;
        address = 16'h0002;
        #10;
        write_address = 0;
        write = 1;
        data_size = 2'b01;
        data_reg = 32'h0000BBCC;
        #10;
        write = 0;
        read = 1;
        #10;
        $display("Test 2: Read data = %h", data);
        read = 0;

        // Test 3: Write and read 4 bytes
        #10;
        write_address = 1;
        address = 16'h0003;
        #10;
        write_address = 0;
        write = 1;
        data_size = 2'b11;
        data_reg = 32'hDDEEFF00;
        #10;
        write = 0;
        read = 1;
        #10;
        $display("Test 3: Read data = %h", data);
        read = 0;

        // Test 4: Write and read at different addresses
        #10;
        write_address = 1;
        address = 16'h0004;
        #10;
        write_address = 0;
        write = 1;
        data_size = 2'b00;
        data_reg = 32'h00000011;
        #10;
        write = 0;
        read = 1;
        #10;
        $display("Test 4: Read data = %h", data);
        read = 0;

        // End of test
        #10;
        $finish;
    end

endmodule
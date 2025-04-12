`include "real_time_clock.sv"
`timescale 1s/1s
module tb_csr_timer_device();
    reg clock;
    reg reset;
    reg read;
    reg write;
    reg [1:0] address;
    wire timer_interrupt;
    
    wire [31:0] data = write ? data_in : 32'bz;

    reg [31:0] data_in;

    // Instantiate DUT
    real_time_clock #(
        .FREQUENCY(10)
    ) dut (
        .clock(clock),
        .reset(reset),
        .read(read),
        .write(write),
        .address(address),
        .data(data),
        .timer_interrupt(timer_interrupt)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Main test sequence
    initial begin
        $dumpfile("tb_csr_timer_device.vcd");
        $dumpvars(0, tb_csr_timer_device);
        
        initialize();

        //test1 reset
        reset = 1;
        #10 
        reset = 0;
        read = 1;
        address = 0;
        #10
        $display("reset mtime[31:0] = %0d", data);
        address = 1;
        #10
        $display("reset mtime[63:32] = %0d", data);
        address = 2;
        #10
        $display("reset mtimecmp[31:0] = %0d", data);
        address = 3;
        #10
        $display("reset mtimecmp[63:32] = %0d", data);
        
        //test2 write
        write = 1;
        address = 0;
        data_in = 100;
        #10
        write = 0;
        #10
        $display("write mtime[31:0] = %0d", data);
        address = 1;
        data_in = 200;
        write = 1;
        #10
        write = 0;
        #10
        $display("write mtime[63:32] = %0d", data);
        address = 2;
        data_in = 300;
        write = 1;
        #10
        write = 0;
        #10
        $display("write mtimecmp[31:0] = %0d", data);
        address = 3;
        data_in = 400;
        write = 1;
        #10
        write = 0;
        #10
        $display("write mtimecmp[63:32] = %0d", data);
        
        //test3 interrupt
        
        reset = 1;
        #10
        reset = 0;
        address = 2;
        data_in = 500;
        write = 1;
        #10
        write = 0;
        address = 0;
        while (!timer_interrupt) begin         
            #50  
            $display("mtime = %0d, interrupt = %b", data, timer_interrupt);            
        end

        $finish;
    end

    task initialize();
        reset = 0;
        read = 0;
        write = 0;
        address = 0;
        data_in = 0;
    endtask
endmodule
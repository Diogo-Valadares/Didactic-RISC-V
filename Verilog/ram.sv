module ram #(
    parameter MEM_INIT_FILE = "",
    parameter ADDR_WIDTH = 16,
    parameter MEM_DEPTH = 1 << ADDR_WIDTH,
    parameter PROGRAM_SIZE = MEM_DEPTH
) (
    input clock,
    input reset,
    input write,
    input read,
    input write_address, 
    input [1:0] data_size, // 00: 1 byte, 01: 2 bytes, 11: 4 bytes
    input [ADDR_WIDTH-1 : 0] address,
    inout [31:0] data
);

    // Memory array
    reg [7:0] mem [0:MEM_DEPTH-1];
    reg [ADDR_WIDTH-1 : 0] stored_address = 32'b0; 

    assign data = (read && !write) ? {mem[stored_address+3], mem[stored_address+2], mem[stored_address+1], mem[stored_address]} : 32'bz;

    initial begin
        integer i;
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 8'b0;
        end
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem, 0, PROGRAM_SIZE-1);
        end
    end

    always @(posedge clock) begin
        if (write) begin
            case (data_size)
                2'b00: mem[stored_address] <= data[7:0];
                2'b01: begin
                    mem[stored_address] <= data[7:0];
                    mem[stored_address+1] <= data[15:8];
                end
                2'b10: ; // Invalid case, do nothing
                2'b11: begin
                    mem[stored_address] <= data[7:0];
                    mem[stored_address+1] <= data[15:8];
                    mem[stored_address+2] <= data[23:16];
                    mem[stored_address+3] <= data[31:24];
                end
            endcase
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            stored_address <= 32'b0;
        end
        else if (write_address) begin
            stored_address <= address;
        end
    end

endmodule

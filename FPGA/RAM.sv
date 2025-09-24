`timescale 1s/1s
module ram #(
    string HEX_STRING = "09 93 47 99 18 67 ab af 7e 7d 9a";
    parameter ADDR_WIDTH = 12,
    parameter MEM_DEPTH = 1 << ADDR_WIDTH
) (
    input clock,
    input write,
    input read,
    input [1:0] data_size, // 00: 1 byte, 01: 2 bytes, 11: 4 bytes
    input [ADDR_WIDTH-1 : 0] address,
    inout [31:0] data
);

    // Memory array
    reg [7:0] mem [0:MEM_DEPTH-1];

    assign data = (read && !write) ? {mem[address+3], mem[address+2], mem[address+1], mem[address]} : 32'bz;
	 
    initial begin
        integer i, j;
        reg [7:0] byte_value;
        integer str_len;

        // Split the string into bytes and initialize memory by bytes (8-bit)
        str_len = HEX_STRING.len();
        i = 0;
        j = 0;
        while (i < str_len) begin
            // Read two characters (one byte in hex)
            if (i + 1 < str_len && HEX_STRING[i] != " ") begin
                byte_value = $sscanf(HEX_STRING.substr(i, 2), "%h");
                mem[j] = byte_value;
                j = j + 1;
                i = i + 3;
            end else begin
                i = i + 1;
            end
        end
    end
	

    always @(posedge clock) begin
        if (write) begin
            case (data_size)
                2'b00: mem[address] <= data[7:0];
                2'b01: begin
                    mem[address] <= data[7:0];
                    mem[address+1] <= data[15:8];
                end
                2'b10: ; // Invalid case, do nothing
                2'b11: begin
                    mem[address] <= data[7:0];
                    mem[address+1] <= data[15:8];
                    mem[address+2] <= data[23:16];
                    mem[address+3] <= data[31:24];
                end
            endcase
        end
    end
endmodule

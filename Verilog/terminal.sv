`timescale 1s/1s
module terminal #(
    parameter string TERMINAL_FILE = "terminal.mem"
) (
    input logic clock,
    input logic reset, // Added reset signal
    input logic write,
    input logic [7:0] data
);

    logic [7:0] buffer [0:63];

    always @(negedge clock) begin
        integer file_handle;
        if (reset) begin
            for (int i = 0; i < 64; i++) begin
                buffer[i] <= 8'd0;
            end
            file_handle = $fopen(TERMINAL_FILE, "w");
            if (file_handle != 0) begin
                $fclose(file_handle);
            end 
        end 
        else if (write) begin
            for (int i = 63; i > 0; i--) begin
                buffer[i] <= buffer[i-1];
            end
            buffer[0] <= data;

            // Clear the file before writing new buffer contents
            file_handle = $fopen(TERMINAL_FILE, "w");
            if (file_handle) begin
                foreach (buffer[i]) begin
                    $fdisplay(file_handle, "%h", buffer[i]);
                end
                $fclose(file_handle);
            end
        end
    end

endmodule

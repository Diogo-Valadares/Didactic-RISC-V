`timescale 1s/1s
module video_controller #(
    parameter SCREEN_WIDTH_BIT_WIDTH = 8,
    parameter SCREEN_HEIGHT_BIT_WIDTH = 8,
    parameter SCREEN_WIDTH = 1 << SCREEN_WIDTH_BIT_WIDTH,
    parameter SCREEN_HEIGHT = 1 << SCREEN_HEIGHT_BIT_WIDTH,
    parameter SCREEN_FILE = "screen.mem",
    parameter WRITE_INTERVAL = 100  // Clock cycles between write attempts
)(
    input clock,
    input reset,
    input write,
    input [SCREEN_WIDTH_BIT_WIDTH + SCREEN_HEIGHT_BIT_WIDTH - 1 : 0] address,
    input [31:0] data
);

logic [23:0] screenBuffer [0 : SCREEN_WIDTH * SCREEN_HEIGHT - 1];
logic [31:0] write_counter;
logic buffer_modified;  // Modification flag
integer file_handle;

// Initialize memory
initial begin
    foreach (screenBuffer[i]) screenBuffer[i] = 24'b0;
    write_counter = 0;
    buffer_modified = 0;
end

// Main buffer and file control
always @(posedge clock) begin
    if (reset) begin
        // Reset memory and flags
        foreach (screenBuffer[i]) screenBuffer[i] = 24'b0;
        write_counter <= 0;
        buffer_modified <= 0;
    end
    else begin
        // Handle screen writes and track modifications
        if (write) begin
            screenBuffer[address] <= data[23:0];
            buffer_modified <= 1'b1;  // Set modification flag
        end

        // File writing logic (only when modified)
        write_counter <= write_counter + 1;
        if (write_counter >= WRITE_INTERVAL && buffer_modified) begin
            write_counter <= 0;
            file_handle = $fopen(SCREEN_FILE, "w");
            if (file_handle) begin
                foreach (screenBuffer[i]) begin
                    $fdisplay(file_handle, "%h", screenBuffer[i]);
                end
                $fclose(file_handle);
                buffer_modified <= 1'b0;  // Clear flag after successful write
            end
        end
    end
end

endmodule
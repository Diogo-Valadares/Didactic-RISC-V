`timescale 1s/1s
module user_input #(
    parameter KEYBOARD_FILE = "keyboard.mem"
) (
    input read,
    input clock,
    input reset,
    output [31:0] data_out
);

integer file_ptr = 0;
integer char1, char2;  // Use integers to handle EOF (-1)
reg [31:0] data_reg;
reg [7:0] random;
reg [7:0] separator;   // Explicit register for separator

assign data_out = read ? data_reg : 32'hZ;

function automatic [3:0] hex_to_nibble(input [7:0] c);
    case(c)
        "0": return 4'h0;
        "1": return 4'h1;
        "2": return 4'h2;
        "3": return 4'h3;
        "4": return 4'h4;
        "5": return 4'h5;
        "6": return 4'h6;
        "7": return 4'h7;
        "8": return 4'h8;
        "9": return 4'h9;
        "A","a": return 4'hA;
        "B","b": return 4'hB;
        "C","c": return 4'hC;
        "D","d": return 4'hD;
        "E","e": return 4'hE;
        "F","f": return 4'hF;
        default: return 4'hF;
    endcase
endfunction

always @(negedge clock) begin
    if (reset) begin
        // Close file if already open
        if (file_ptr) begin
            $fclose(file_ptr);
            file_ptr = 0;
        end
        // Open in read mode
        file_ptr = $fopen(KEYBOARD_FILE, "r");
        if (file_ptr == 0)
            $display("Error: Cannot open %s", KEYBOARD_FILE);
        data_reg = 32'hFF000000;  // Default reset value
    end
    else if (read) begin
        random = $random;  // Get new random value

        if (file_ptr == 0) begin
            // File not open - use default
            data_reg = {8'hFF, 16'h0, random};
        end
        else begin
            char1 = $fgetc(file_ptr);  // Read first char

            if (char1 == -1) begin  // Check EOF
                data_reg = {8'hFF, 16'h0, random};
            end
            else begin
                char2 = $fgetc(file_ptr);  // Read second char

                if (char2 == -1) begin
                    // Single character case
                    data_reg = {
                        {hex_to_nibble(char1[7:0]), 4'h0},
                        16'h0,
                        random
                    };
                end
                else begin
                    // Read separator normally
                    separator = $fgetc(file_ptr);  // Discard separator

                    // Process both characters
                    data_reg = {
                        {hex_to_nibble(char1[7:0]), hex_to_nibble(char2[7:0])},
                        16'h0,
                        random
                    };
                end
            end
        end
    end
end

endmodule
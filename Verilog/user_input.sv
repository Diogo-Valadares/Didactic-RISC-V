`timescale 1s/1s
module user_input #(
    parameter KEYBOARD_FILE = "keyboard.mem"
) (
    input read,
    input clock,
    input reset,
    output [31:0] data_out
);

integer file_ptr;
reg [7:0] char1, char2, space;
reg [31:0] position = 0;
reg [31:0] data_reg;
reg [7:0] random;
logic status;

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

always @(posedge clock) begin
    if (reset) begin
        file_ptr = $fopen(KEYBOARD_FILE, "r");
        position = 0;
    end
    else begin
        if (read) begin
            random = $random;
            status = $fseek(file_ptr, position, 0);

            char1 = $fgetc(file_ptr);
            char2 = $fgetc(file_ptr);
            space = $fgetc(file_ptr);
            
            if (!$feof(file_ptr) && space == " ") begin
                data_reg <= {{hex_to_nibble(char1), hex_to_nibble(char2)}, 
                    16'h0,
                    random
                };
                position += 3;
            end
            else begin
                data_reg <= 32'hFF000000; 
            end
        end
    end
end

endmodule
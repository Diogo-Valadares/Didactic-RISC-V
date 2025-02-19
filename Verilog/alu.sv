module alu(
    input clock,
    input write,
    input use_pc,
    input [31:0] a,
    input [31:0] program_counter,
    input use_immediate,
    input [31:0] b,
    input [31:0] immediate,
    input [4:0] operation,
    output reg [31:0] result,
    output reg [3:0] cnzv
    );
    
    reg [31:0] a_reg;
    reg [31:0] b_reg;
    reg [63:0] r64;
    
    wire [4:0]op = (use_immediate & ~(operation == 1 | operation == 5 | operation == 21)) ? {2'b0, operation[2:0]} : operation;
    
    always@(posedge clock) begin
        
        if(write) begin
            a_reg <= use_pc ? program_counter : a;
            b_reg <= use_immediate ? immediate : b;
        end
    end
    
    always@(*) begin
        case(op)
            0: {cnzv[0], result} = a_reg + b_reg;
            1: result = a_reg << b_reg[4:0];
            2: result = ($signed(a_reg) < $signed(b_reg)) ? 1 : 0;
            3: result = ($unsigned(a_reg) < $unsigned(b_reg)) ? 1 : 0;
            4: result = a_reg ^ b_reg;
            5: result = a_reg >> b_reg[4:0];
            6: result = a_reg | b_reg;
            7: result = a_reg & b_reg;
            8: result = a_reg * b_reg;
            9: begin
                r64 = $signed(a_reg) * $signed(b_reg); 
                result = r64[63:32];
            end
            10: begin 
                r64 = $signed({a_reg[31],a_reg}) * $signed({1'b0, b_reg});
                result = r64[63:32];
            end
            11: begin
                r64 = a_reg * b_reg;
                result = r64[63:32];
            end
            16: {cnzv[0], result} = a_reg - b_reg;
            21: result = $signed(a_reg) >>> b_reg[4:0];
            default: result = 32'b0;
        endcase
        cnzv[3:1] = {
            (operation == 16 ^ (a_reg[31] == b_reg[31]) && (result[31] != a_reg[31])), 
            result == 0 ? 1'b1 : 1'b0 , 
            result[31]
        };
    end
endmodule
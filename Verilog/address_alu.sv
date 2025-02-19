module address_alu(
    input clock,
    input write,
    input use_pc,
    input [31:0] a,
    input [31:0] program_counter,
    input [31:0] immediate,
    output [31:0] result
    );
    
    reg [31:0] a_reg;
    reg [31:0] b_reg;
    
    assign result = a_reg + b_reg;

    always @(posedge clock) begin
        if (write) begin
            a_reg <= use_pc ? program_counter : a;
            b_reg <= immediate;
        end       
    end
endmodule
`timescale 1s/1s
module alu(
    input use_pc,
    input [31:0] a,
    input [31:0] program_counter,
    input use_immediate,
    input [31:0] b,
    input [31:0] immediate,
    input [4:0] operation,
    output logic [31:0] result,
    output logic [3:0] cnzv
    );

    wire [4:0]op = (use_immediate & ~(operation == 1 | operation == 5 | operation == 21)) ?
                        {2'b0, operation[2:0]} :
                        operation;
    wire [31:0] source1 = use_pc ? program_counter : a;
    wire [31:0] source2 = use_immediate ? immediate : b;

    always@ * begin
        case(op)
            0: {cnzv[0], result} = source1 + source2;
            1: result = source1 << source2[4:0];
            2: result = ($signed(source1) < $signed(source2)) ? 1 : 0;
            3: result = ($unsigned(source1) < $unsigned(source2)) ? 1 : 0;
            4: result = source1 ^ source2;
            5: result = source1 >> source2[4:0];
            6: result = source1 | source2;
            7: result = source1 & source2;
            8: result = source1 * source2;
            9: begin
                logic [63:0] r64;
                r64 = $signed(source1) * $signed(source2);
                result = r64[63:32];
            end
            10: begin
                logic [63:0] r64;
                r64 = $signed({source1[31],source1}) * $signed({1'b0, source2});
                result = r64[63:32];
            end
            11: begin
                logic [63:0] r64;
                r64 = source1 * source2;
                result = r64[63:32];
            end
            16: {cnzv[0], result} = source1 - source2;
            21: result = $signed(source1) >>> source2[4:0];
            default: result = 32'b0;
        endcase
        cnzv[3:1] = {
            (operation == 16 ^ (source1[31] == source2[31]) && (result[31] != source1[31])),
            result == 0,
            result[31]
        };
    end
endmodule
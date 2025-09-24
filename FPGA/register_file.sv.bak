`timescale 1s/1s
module register_file(
    input clock,
    input reset,
    input write,
    input [4:0] a_address,
    input [4:0] b_address,
    input [4:0] c_address,
    input [31:0] c_in,
    output [31:0] a_out,
    output [31:0] b_out
);

    reg [31:0] registers [0:31];

    assign a_out = (a_address == 5'd0) ? 32'b0 : registers[a_address];
    assign b_out = (b_address == 5'd0) ? 32'b0 : registers[b_address];

    always @(posedge clock) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else if (write && c_address != 5'd0) begin
            registers[c_address] <= c_in;
        end
    end

endmodule

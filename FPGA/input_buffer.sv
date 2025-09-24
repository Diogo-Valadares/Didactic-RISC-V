`timescale 1s/1s
module input_buffer(
    input clock,
    input write,
    input [2:0] data_type,
    input [1:0] data_offset,
    input [31:0] io_in,
    output logic [31:0] cpu_out
);
    reg [31:0] data_reg;

    always@(posedge clock) begin
        if(write) begin
            data_reg <= io_in;
        end
    end

  	always@(*) begin
        case (data_type)
            3'b100: cpu_out = {24'h0, data_reg[data_offset*8+7 -: 8]};
            3'b101: cpu_out = {16'h0, data_reg[data_offset*8+15 -: 16]};
            3'b000: cpu_out = {{24{data_reg[data_offset*8+7]}}, data_reg[data_offset*8+7 -: 8]};
            3'b001: cpu_out = {{16{data_reg[data_offset*8+15]}}, data_reg[data_offset*8+15 -: 16]};
            default: cpu_out = data_reg;
        endcase
    end
endmodule
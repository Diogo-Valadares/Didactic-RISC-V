module data_io(
    input clock,
    input store,
    input load,
    input [2:0] data_type,
    input [1:0] data_offset,
    input [31:0] cpu_in,
    input [31:0] io_in,
    output logic [31:0] cpu_out,
    output [31:0] io_out
);
    reg [31:0] output_reg;
    reg [31:0] input_reg;

    assign io_out = output_reg;     
  
    always@(posedge clock) begin
        if(store) begin
            output_reg <= cpu_in;
        end
        if(load) begin
            input_reg <= io_in;
        end
    end
  
  	always@(*) begin
        case (data_type)
            3'b000: cpu_out = {24'h0, input_reg[data_offset*8+7 -: 8]};
            3'b001: cpu_out = {16'h0, input_reg[data_offset*8+15 -: 16]};
            3'b100: cpu_out = {{24{input_reg[data_offset*8+7]}}, input_reg[data_offset*8+7 -: 8]};
            3'b101: cpu_out = {{16{input_reg[data_offset*8+15]}}, input_reg[data_offset*8+15 -: 16]};
            default: cpu_out = input_reg;
        endcase
    end
endmodule
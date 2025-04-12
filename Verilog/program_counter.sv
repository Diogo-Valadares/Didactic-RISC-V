`timescale 1s/1s
module program_counter(
    input reset,
    input clock,
    input write,
    input jump,
    input pc_relative,
    input use_offset,
    input forward_address,
    input [31:0] immediate,
    input [31:0] address_in,
    input system_jump,
    input system_load,
    input [31:0] system_address_target,
    output reg [1:0] data_offset,
    output [31:0] calculated_address,
    output [31:0] next,
    output [31:0] current,
    output [31:0] last,
    output [31:0] address_bus
    );

    reg [29:0] next_reg;
    reg [29:0] current_reg;
    reg [29:0] last_reg;

    assign calculated_address = pc_relative ? current + immediate : address_in + immediate;
    assign next = {next_reg, 2'b00};
    assign current = {current_reg, 2'b00};
    assign last = {last_reg, 2'b00};
    assign address_bus = forward_address ? 
                        (system_load ? system_address_target :
                         use_offset ? calculated_address : {calculated_address[31:2], 2'b00}) : 
                        {next_reg, 2'b00};

    always@(posedge clock) begin
        if(reset) begin
            current_reg <= 30'b0;
            last_reg <= 30'b0;
            next_reg <= 30'b0;
            data_offset <= 2'b0;
        end
        else if(system_jump) next_reg <= system_address_target[31:2];
        else if(jump) next_reg <= calculated_address[31:2];
        else if(write) next_reg <= next_reg + 1;
        
        if(write) begin
            last_reg <= current_reg;
            current_reg <= next_reg;
        end

        if(forward_address) begin
            data_offset <= calculated_address[1:0];
        end
    end

endmodule
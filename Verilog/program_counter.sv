module program_counter(
    input reset,
    input clock,
    input write,
    input jump,
    input use_offset,
    input address_in_to_AD,
    input [31:0] address_in,
    output reg [1:0] data_offset,
    output [31:0] next,
    output [31:0] current,
    output [31:0] last,
    output [31:0] AD_Bus
    );
    
    reg [29:0] next_reg;
    reg [29:0] current_reg;
    reg [29:0] last_reg;

    assign next = {next_reg, 2'b00};
    assign current = {current_reg, 2'b00};
    assign last = {last_reg, 2'b00};
    assign AD_Bus = address_in_to_AD ? 
                        (use_offset ? address_in : {address_in[31:2], 2'b00}) : 
                        {next_reg, 2'b00};

    always@(posedge clock) begin
        if(reset) begin
            current_reg <= 30'b0;
            last_reg <= 30'b0;
            next_reg <= 30'b0;
            data_offset <= 2'b0;
        end
        else if(jump) begin
            next_reg <= address_in[31:2];
        end
        else if(write) begin
            last_reg <= current_reg;
            current_reg <= next_reg;
            next_reg <= next_reg + 1;
        end
        if(address_in_to_AD) begin
            data_offset <= address_in[1:0];
        end
    end

endmodule
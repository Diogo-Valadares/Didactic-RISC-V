module phase_generator(
    input clock,
    input reset,
    output [3:1] phase
);
    reg [3:1] phase_reg;

    always @(posedge clock) begin
        if (reset) begin
            phase_reg <= 3'b010;
        end
        else begin
            phase_reg <= {phase_reg[2:1], phase_reg[3]};
        end
    end

    assign phase = phase_reg;
endmodule
module phase_generator(
    input clock,
    input reset,
    output [2:1] phase
);
    reg phase_reg;

    assign phase = {~phase_reg, phase_reg};

    always @(posedge clock) begin
        if (reset) phase_reg <= 0;
        else phase_reg <= ~phase_reg;
    end
endmodule
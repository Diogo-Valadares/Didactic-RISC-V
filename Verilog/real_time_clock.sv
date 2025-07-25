`timescale 1s/1us
module real_time_clock
#(
    parameter FREQUENCY = 1
)(
    input wire clock,
    input wire reset,
    input wire read,
    input wire write,
    input wire [1:0] address,
    inout wire [31:0] data,
    output wire timer_interrupt
);
    reg internal_clock;
    reg [64:0] mtime;
    reg [64:0] mtimecmp;

    assign data = (read && !write) ? (
            address == 0 ? mtime[31:0] :
            address == 1 ? mtime[63:32] :
            address == 2 ? mtimecmp[31:0] :
            mtimecmp[63:32]
        ) : 32'bz;

    assign timer_interrupt = mtime >= mtimecmp;

    initial begin
        internal_clock = 0;
        forever #(1s/FREQUENCY) internal_clock = ~internal_clock;
    end

    always @(posedge clock) begin
        if(reset) begin
            mtime <= 0;
            mtimecmp <= 0;
        end
        else if(write) begin
            if(address == 0) mtime[31:0] <= data;
            else if(address == 1) mtime[63:32] <= data;
            else if(address == 2) mtimecmp[31:0] <= data;
            else mtimecmp[63:32] <= data;
        end
    end

    always @(posedge internal_clock) begin
        if(!reset && !write) mtime <= mtime + 1;
    end
endmodule
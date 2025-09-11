module irReceiver2 (
    input logic clk_50,               // 50 MHz system clock
    input logic irSignal,             // IR input signal
    output logic [9:0] frame = 10'b0  // Decoded IR frame
);

    // States
    typedef enum logic [1:0] {
        IDLE,
        START,
        DECODING,
        FINISH
    } state_t;

    state_t current_state = IDLE;     // Current state
    state_t next_state;               // Next state

    // Control signals
    logic started = 0;                // Start of transfer detected
    logic decoded = 0;                // Frame decoded
    logic failed = 0;                 // Failed - unintelligible frame
    logic success = 0;                // Success - frame sent to output
    logic stored = 0;                 // Bit stored in vector

    // Counters
    int cycle_counter = 0;            // Cycle counter (20ns @ 50MHz)
    int bit_index = -1;               // Bit index (-1 to 12)

    // Auxiliary signals
    logic [11:0] data_buffer = 12'b0; // Auxiliary vector for storing received frame

    // State machine (Control Unit)
    always_comb begin
        case (current_state)
            IDLE: begin
                next_state = (irSignal == 0 && started == 0) ? START : IDLE;
            end

            START: begin
                if (failed) begin
                    next_state = IDLE;
                end else begin
                    next_state = (irSignal == 1 && started == 1) ? DECODING : START;
                end
            end

            DECODING: begin
                if (failed) begin
                    next_state = IDLE;
                end else begin
                    next_state = decoded ? FINISH : DECODING;
                end
            end

            FINISH: begin
                next_state = success ? IDLE : FINISH;
            end

            default: next_state = IDLE;
        endcase
    end

    // Process unit
    always_ff @(posedge clk_50) begin
        // Update current state
        current_state <= next_state;

        case (current_state)
            IDLE: begin
                // Reset counters
                cycle_counter <= 0;
                bit_index <= -1;
                
                // Reset control signals
                failed <= 0;
                started <= 0;
                decoded <= 0;
                success <= 0;
                stored <= 0;
            end

            START: begin
                // Check if it's been 2.4ms at '0'
                if (cycle_counter < 120000) begin
                    cycle_counter <= cycle_counter + 1;
                    
                    // If start condition is interrupted, stop
                    if (cycle_counter < 100000 && irSignal == 1) begin
                        failed <= 1;
                    end
                end else begin
                    // 2.4ms have passed and start condition is met
                    started <= 1;
                    cycle_counter <= 0;
                end
            end

            DECODING: begin
                // Read data
                if (bit_index < 12) begin
                    // How long has the LED been emitting?
                    if (irSignal == 0) begin
                        stored <= 0;
                        cycle_counter <= cycle_counter + 1;
                    end else if (!stored) begin
                        // If LED emitted for more than 1ms, it's a '1', otherwise '0'
                        if (bit_index > -1) begin
                            data_buffer[bit_index] <= (cycle_counter > 50000) ? 1'b1 : 1'b0;
                        end
                        bit_index <= bit_index + 1;
                        cycle_counter <= 0;
                        stored <= 1;
                    end
                end else begin
                    decoded <= 1;
                end
            end

            FINISH: begin
                // Reception complete, update output vector
                frame <= data_buffer[11:2];
                success <= 1;
            end
        endcase
    end

endmodule
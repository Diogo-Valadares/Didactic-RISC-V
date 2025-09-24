module sdram_controller (
    // Processor Interface (32-bit)
    input logic clk,                    // System clock (100-133MHz)
    input logic rst,                    // Active-low reset
    input logic [31:0] proc_addr,       // Processor address bus
    inout logic [31:0] proc_data,       // Processor bidirectional data bus
    input logic proc_read,              // Processor read signal
    input logic proc_write,             // Processor write signal
    input logic [1:0] proc_wr_size,     // Write size (00=byte, 01=short, 11=word)
    output logic proc_ready,            // Indicates controller ready for command
    
    // SDRAM Physical Interface (16-bit)
    inout wire [15:0] SDRAM_DQ,         // SDRAM data bus
    output logic [11:0] SDRAM_A,        // SDRAM address bus
    output logic SDRAM_BS0,             // Bank select bit 0
    output logic SDRAM_BS1,             // Bank select bit 1
    output logic SDRAM_LDQM,            // Lower byte data mask
    output logic SDRAM_UDQM,            // Upper byte data mask
    output logic SDRAM_CKE,             // Clock enable
    output logic SDRAM_CLK,             // Clock to SDRAM
    output logic SDRAM_CS,              // Chip select (active low)
    output logic SDRAM_RAS,             // Row address strobe (active low)
    output logic SDRAM_CAS,             // Column address strobe (active low)
    output logic SDRAM_WE               // Write enable (active low)
);

// SDRAM Parameters for a typical 16-bit SDRAM (e.g., IS42S16400F)
parameter tRCD = 3'd2;          // RAS to CAS delay (cycles)
parameter tCAS = 3'd2;          // CAS latency (cycles)
parameter tRP = 3'd2;           // Precharge command period (cycles)
parameter tREF = 16'd780;       // Refresh interval (cycles)

// Internal registers
logic [31:0] proc_data_out;
logic [31:0] proc_data_in;
logic proc_data_dir; // 0 = input (read), 1 = output (write)

// SDRAM control signals
logic [15:0] sdram_data_out;
logic [15:0] sdram_data_in;
logic sdram_data_dir;

// Address decomposition for SDRAM
logic [1:0] bank_addr;
logic [11:0] row_addr;
logic [7:0] col_addr;  // Column address (we use 8 bits, ignoring lowest bit for 32-bit words)

// Extract bank, row, and column from processor address
// For a typical 64MB SDRAM with 4 banks, 4096 rows, and 256 columns (x16)
assign bank_addr = proc_addr[23:22];  // Bank selection bits
assign row_addr = proc_addr[21:10];   // Row address bits
assign col_addr = {proc_addr[9:2], 1'b0}; // Column address (word aligned)

// Bank select signals
assign SDRAM_BS0 = bank_addr[0];
assign SDRAM_BS1 = bank_addr[1];

// SDRAM command encoding
localparam CMD_LOAD_MODE = 4'b0000;
localparam CMD_AUTO_REFRESH = 4'b0001;
localparam CMD_PRECHARGE = 4'b0010;
localparam CMD_ACTIVATE = 4'b0011;
localparam CMD_WRITE = 4'b0100;
localparam CMD_READ = 4'b0101;
localparam CMD_NOP = 4'b0111;

// Controller state machine
typedef enum logic [3:0] {
    STATE_INIT_WAIT,
    STATE_INIT_PRECHARGE,
    STATE_INIT_REFRESH1,
    STATE_INIT_REFRESH2,
    STATE_INIT_LOAD_MODE,
    STATE_IDLE,
    STATE_ACTIVATE,
    STATE_READ,
    STATE_READ_WAIT,
    STATE_WRITE,
    STATE_WRITE_WAIT,
    STATE_PRECHARGE,
    STATE_AUTO_REFRESH
} state_t;

state_t current_state, next_state;

// Refresh counter
logic [15:0] refresh_counter;

// Command register
logic [3:0] command;

// Data handling for 32-bit to 16-bit conversion
logic upper_word_selected;
logic [31:0] write_data_latch;
logic [1:0] byte_mask;

// Tristate buffers for data buses
assign proc_data = proc_data_dir ? proc_data_out : 32'bz;
assign proc_data_in = proc_data;

assign SDRAM_DQ = sdram_data_dir ? sdram_data_out : 16'bz;
assign sdram_data_in = SDRAM_DQ;

// Generate SDRAM command signals from command register
assign {SDRAM_CS, SDRAM_RAS, SDRAM_CAS, SDRAM_WE} = command;

// SDRAM clock is the same as system clock (ensure proper constraints)
assign SDRAM_CLK = clk;
assign SDRAM_CKE = 1'b1;  // Always enable SDRAM clock

// Main state machine
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= STATE_INIT_WAIT;
        refresh_counter <= 0;
        command <= CMD_NOP;
        proc_ready <= 0;
        upper_word_selected <= 0;
        proc_data_dir <= 0;
        sdram_data_dir <= 0;
    end else begin
        current_state <= next_state;
        
        // Refresh counter
        if (refresh_counter >= tREF) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
        
        // Default to NOP command
        command <= CMD_NOP;
        
        case (current_state)
            STATE_INIT_WAIT: begin
                // Wait 200μs after power-up
                if (refresh_counter > 16'd20000) begin // Assuming 100MHz clock
                    next_state <= STATE_INIT_PRECHARGE;
                end
            end
            
            STATE_INIT_PRECHARGE: begin
                command <= CMD_PRECHARGE;
                SDRAM_A[10] <= 1'b1; // Precharge all banks
                next_state <= STATE_INIT_REFRESH1;
            end
            
            STATE_INIT_REFRESH1: begin
                command <= CMD_AUTO_REFRESH;
                next_state <= STATE_INIT_REFRESH2;
            end
            
            STATE_INIT_REFRESH2: begin
                command <= CMD_AUTO_REFRESH;
                next_state <= STATE_INIT_LOAD_MODE;
            end
            
            STATE_INIT_LOAD_MODE: begin
                command <= CMD_LOAD_MODE;
                // Set mode register: burst length=1, CAS latency=2, sequential
                SDRAM_A <= 12'b0000_0010_0010;
                next_state <= STATE_IDLE;
            end
            
            STATE_IDLE: begin
                proc_ready <= 1;
                if (proc_read || proc_write) begin
                    proc_ready <= 0;
                    write_data_latch <= proc_data_in;
                    next_state <= STATE_ACTIVATE;
                end else if (refresh_counter >= tREF) begin
                    next_state <= STATE_AUTO_REFRESH;
                end
            end
            
            STATE_ACTIVATE: begin
                command <= CMD_ACTIVATE;
                SDRAM_A <= row_addr;
                next_state <= proc_read ? STATE_READ : STATE_WRITE;
            end
            
            STATE_READ: begin
                command <= CMD_READ;
                SDRAM_A <= {4'b0000, col_addr[7:1], upper_word_selected};
                // Set auto precharge (A10 high) for single accesses
                SDRAM_A[10] <= 1'b1;
                next_state <= STATE_READ_WAIT;
            end
            
            STATE_READ_WAIT: begin
                // Wait for CAS latency
                if (refresh_counter >= tCAS) begin
                    proc_data_out[upper_word_selected*16 +:16] <= sdram_data_in;
                    if (upper_word_selected) begin
                        proc_data_dir <= 1; // Drive data bus
                        next_state <= STATE_PRECHARGE;
                    end else begin
                        upper_word_selected <= 1;
                        next_state <= STATE_READ;
                    end
                end
            end
            
            STATE_WRITE: begin
                command <= CMD_WRITE;
                SDRAM_A <= {4'b0000, col_addr[7:1], upper_word_selected};
                // Set auto precharge (A10 high) for single accesses
                SDRAM_A[10] <= 1'b1;
                
                // Set data masks based on write size and address
                case (proc_wr_size)
                    2'b00: begin // Byte write
                        SDRAM_LDQM <= ~(proc_addr[1:0] == 2'b00 || proc_addr[1:0] == 2'b01);
                        SDRAM_UDQM <= ~(proc_addr[1:0] == 2'b10 || proc_addr[1:0] == 2'b11);
                    end
                    2'b01: begin // Short (16-bit) write
                        SDRAM_LDQM <= 1'b0;
                        SDRAM_UDQM <= 1'b0;
                    end
                    2'b11: begin // Word (32-bit) write
                        SDRAM_LDQM <= 1'b0;
                        SDRAM_UDQM <= 1'b0;
                    end
                endcase
                
                sdram_data_out <= write_data_latch[upper_word_selected*16 +:16];
                sdram_data_dir <= 1; // Drive SDRAM data bus
                next_state <= STATE_WRITE_WAIT;
            end
            
            STATE_WRITE_WAIT: begin
                sdram_data_dir <= 0;
                if (upper_word_selected) begin
                    next_state <= STATE_PRECHARGE;
                end else begin
                    upper_word_selected <= 1;
                    next_state <= STATE_WRITE;
                end
            end
            
            STATE_PRECHARGE: begin
                command <= CMD_PRECHARGE;
                SDRAM_A[10] <= 1'b1; // Precharge all banks
                upper_word_selected <= 0;
                next_state <= STATE_IDLE;
            end
            
            STATE_AUTO_REFRESH: begin
                command <= CMD_AUTO_REFRESH;
                next_state <= STATE_IDLE;
            end
        endcase
    end
end

endmodule
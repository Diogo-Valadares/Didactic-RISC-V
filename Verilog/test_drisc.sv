module test_drisc;

    parameter MEM_WIDTH = 9;

    // Testbench signals
    reg clock;
    reg reset;
    wire [31:0] io_bus_ram;
    wire [31:0] io_bus_drisc;
    wire [1:0] data_size;
    wire write_address;
    wire write;
    wire read;
    wire [6:0] opcode_debug;
    wire [MEM_WIDTH-1:0] address_bus;

    // Instantiate the DUT (Device Under Test)
    drisc drisc_processor (
        .clock(clock),
        .reset(reset),
        .io_bus(io_bus_drisc),
        .address_bus(address_bus),
        .data_size(data_size),
        .write_address(write_address),
        .write(write),
        .read(read),
        .opcode_debug(opcode_debug)
    );

    // Instantiate the RAM
    ram #(
        .MEM_INIT_FILE("jump.mem"),
        .ADDR_WIDTH(MEM_WIDTH)
    ) ram_inst (
        .clock(clock),
        .reset(reset),
        .write(write),
        .write_address(write_address),
        .read(read),
        .data_size(data_size),
        .address(address_bus),
        .data(io_bus_drisc)
    );

    bit display_toggle = 1;

    initial begin
        clock = 1;
        forever #5 clock = ~clock; // 10ns period
    end

    initial begin
        $display("Time\t| Instruct | PC \t| Opcode\t(#hh)"); 
        forever #30 begin
            if (display_toggle) begin
                $display("%0d\t| %h | %0h  \t| %0s   \t(%0h)", 
                    $time,
                    drisc_processor.operation_controller_0.current_instruction, 
                    drisc_processor.pc_current_out[31:2], 
                    decoded_opcode,
                    opcode_debug
                );
            end
        end
    end

    initial begin
        #1;
        forever #5 begin
            if (!display_toggle) begin
                if(drisc_processor.phase == 3'b001 & clock == 1) begin
                    $display("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
                end
                $display("Time %0d | Phi %b clk %b| PC:Addr In %h, Next %h Curr %h| Instruction : Next %h | Bus A: %h (R[%d]), Bus B: %h (R[%d]), Bus C: %h (R[%d]), imm %h| IO bus: %h, Ram Addr %h %h, W_A/W/R %b%b%b | Opcode: %0s | cnzv: %b %b %b", 
                    $time,
                    drisc_processor.phase,
                    clock,
                    drisc_processor.pc_address_in,
                    drisc_processor.pc_next_out,
                    drisc_processor.pc_current_out,
                    drisc_processor.operation_controller_0.next_instruction,
                    drisc_processor.a_bus,
                    drisc_processor.registers_addresses[9:5],
                    drisc_processor.b_bus,
                    drisc_processor.registers_addresses[14:10],
                    drisc_processor.c_bus,
                    drisc_processor.registers_addresses[4:0],
                    drisc_processor.immediate,
                    io_bus_drisc,
                    address_bus,
                    ram_inst.stored_address,
                    write_address,
                    write,
                    read,
                    decoded_opcode,
                    drisc_processor.cnzv,
                    drisc_processor.operation_controller_0.decoded_cnzv,
                    drisc_processor.operation_controller_0.pc_jump
                );
            end        
        end
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        #20;
        reset = 0;
        #10; 
        #1600;
        dump_registers();
        dump_ram();
        $finish;
    end

    // Task to dump register values
    task dump_registers;
        integer i;
        reg [8*4:1] reg_name;
        begin
            $display("Register values:");
            for (i = 0; i < 32; i = i + 1) begin
                case (i)
                    0: reg_name = "zero";
                    1: reg_name = "ra ";
                    2: reg_name = "sp ";
                    3: reg_name = "gp ";
                    4: reg_name = "tp ";
                    5: reg_name = "t0 ";
                    6: reg_name = "t1 ";
                    7: reg_name = "t2 ";
                    8: reg_name = "s0 ";
                    9: reg_name = "s1 ";
                    10: reg_name = "a0 ";
                    11: reg_name = "a1 ";
                    12: reg_name = "a2 ";
                    13: reg_name = "a3 ";
                    14: reg_name = "a4 ";
                    15: reg_name = "a5 ";
                    16: reg_name = "a6 ";
                    17: reg_name = "a7 ";
                    18: reg_name = "s2 ";
                    19: reg_name = "s3 ";
                    20: reg_name = "s4 ";
                    21: reg_name = "s5 ";
                    22: reg_name = "s6 ";
                    23: reg_name = "s7 ";
                    24: reg_name = "s8 ";
                    25: reg_name = "s9 ";
                    26: reg_name = "s10";
                    27: reg_name = "s11";
                    28: reg_name = "t3 ";
                    29: reg_name = "t4 ";
                    30: reg_name = "t5 ";
                    31: reg_name = "t6 ";
                    default: reg_name = "???";
                endcase
                $display("R[%0d] (%s) = %h", i, reg_name, drisc_processor.register_file_0.registers[i]);
            end
        end
    endtask

    // Task to dump the first 512 addresses of the RAM as a matrix
    task dump_ram;
        integer i, j;
        begin
            $display("RAM values:");
            for (i = 0; i < 32; i = i + 1) begin
                $write("Address %h: ", i*16);
                for (j = 0; j < 16; j = j + 1) begin
                    $write("%h ", ram_inst.mem[i*16 + j]);
                end
                $display("");
            end
        end
    endtask

    // Monitor output signals
    wire [63:0] decoded_opcode = decode_opcode(opcode_debug);
    function bit [63:0] decode_opcode(input [6:0] opcode);
        case (opcode)
            7'h03: decode_opcode = "LOAD";
            7'h07: decode_opcode = "LOAD_FP";
            7'h13: decode_opcode = "OP_IMM";
            7'h17: decode_opcode = "AUIPC";
            7'h23: decode_opcode = "STORE";
            7'h2f: decode_opcode = "STORE_FP";
            7'h33: decode_opcode = "OP";
            7'h37: decode_opcode = "LUI";
            7'h53: decode_opcode = "OP_FP";
            7'h63: decode_opcode = "BRANCH";
            7'h67: decode_opcode = "JALR";
            7'h6f: decode_opcode = "JAL";
            7'h73: decode_opcode = "SYSTEM";
            default: decode_opcode = "UNKNOWN";
        endcase
    endfunction

endmodule
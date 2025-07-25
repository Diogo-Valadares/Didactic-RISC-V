`include "drisc.sv"
`include "ram.sv"
`include "user_input.sv"
`include "video_controller.sv"
`include "real_time_clock.sv"
`include "terminal.sv"
`timescale 1s/1s

module test_drisc;
    parameter RAM_DATA = "programs/csr_operations.mem";
    parameter ADDR_WIDTH = 12;
    parameter PROGRAM_SIZE = 512;

    parameter CLOCK_UPDATE_TIME = 1; //half clock cycle
    parameter INSTRUCTION_TIME = CLOCK_UPDATE_TIME * 4; // 2 clock cycles
    parameter INSTRUCTION_COUNT = 50000; //limit of instructions to execute
    parameter SIMULATION_TIME = INSTRUCTION_COUNT * INSTRUCTION_TIME;

    parameter DISPLAY_TOGGLE = 2;//super-simple=2 simple=1 complex=0
    parameter ALLOW_ILLEGAL_INSTRUCTIONS = 1;

    parameter CSR_ENABLED = 1;
    parameter TRAP_HANDLER_FILE = "programs/trap_handler.mem";
    parameter TRAP_HANDLER_ADDR_WIDTH = 12;
    parameter TRAP_HANDLER_SIZE = 1024;

    reg clock;
    reg reset;
    wire [31:0] data_bus;
    wire external_interrupt = 0;
    wire timer_interrupt;
    wire software_interrupt;
    wire [31:0] data_bus_drisc;
    wire [1:0] data_size;
    wire write;
    wire read;
    wire [31:0] address_bus;
    wire [31:0] current_instruction = drisc_processor.current_instruction;

    assign data_bus = write ? data_bus_drisc :
                      read && is_software_interrupt_address ? {31'h00000000, software_interrupt_reg} :
                      32'hz;

//The processor
    drisc #(
        .GENERATE_CSR_CONTROLLER(CSR_ENABLED)
    ) drisc_processor (
        .clock(clock),
        .reset(reset),
        .data_bus_in(data_bus),
        .external_interrupt(external_interrupt),
        .timer_interrupt(timer_interrupt),
        .software_interrupt(software_interrupt),
        .data_bus_out(data_bus_drisc),
        .address_bus(address_bus),
        .data_size(data_size),
        .write(write),
        .read(read)
    );

//IO devices
    wire is_ram_address = (address_bus < 32'h00fffffc);
    wire write_ram = write && is_ram_address;
    wire read_ram = read && is_ram_address;
    ram #(
        .MEM_INIT_FILE(RAM_DATA),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PROGRAM_SIZE(PROGRAM_SIZE)
    ) ram_inst (
        .clock(clock),
        .write(write_ram),
        .read(read_ram),
        .data_size(data_size),
        .address(address_bus[ADDR_WIDTH-1:0]),
        .data(data_bus)
    );

    wire read_user_input = read && (address_bus == 32'h00fffffc);
    user_input #(
        .KEYBOARD_FILE("interface/log.mem")
    ) user_input_inst (
        .read(read_user_input),
        .clock(clock),
        .reset(reset),
        .data_out(data_bus)
    );

    wire write_video_controller = write && (address_bus >= 32'h01000000) && (address_bus < 32'h01100000);
    video_controller #(
        .SCREEN_WIDTH_BIT_WIDTH(6),
        .SCREEN_HEIGHT_BIT_WIDTH(6),
        .SCREEN_FILE("interface/screen.mem")
    ) video_controller_inst (
        .clock(clock),
        .reset(reset),
        .write(write_video_controller),
        .address(address_bus[11:0]),
        .data(data_bus)
    );

    wire write_terminal = write && (address_bus == 32'h01100000);
    wire clear_terminal = reset || (write && (address_bus == 32'h01100001));
    terminal #(
        .TERMINAL_FILE("interface/terminal.mem")
    ) terminal_inst (
        .clock(clock),
        .reset(clear_terminal),
        .write(write_terminal),
        .data(data_bus[7:0])
    );

    wire read_trap_handler = read && (address_bus >= 32'h80000000 && address_bus < 32'h81000000);
    ram #(
        .MEM_INIT_FILE(TRAP_HANDLER_FILE),
        .ADDR_WIDTH(TRAP_HANDLER_ADDR_WIDTH),
        .PROGRAM_SIZE(TRAP_HANDLER_SIZE)
    ) trap_handler (
        .clock(clock),
        .write(1'b0),
        .read(read_trap_handler),
        .data_size(2'b11),
        .address(address_bus[ADDR_WIDTH-1:0]),
        .data(data_bus)
    );

    wire is_timer_address = (address_bus >= 32'h81000000 && address_bus < 32'h81000010);
    wire read_timer = read && is_timer_address;
    wire write_timer = write && is_timer_address;
    real_time_clock #(
        .FREQUENCY(10)
    ) timer_inst (
        .clock(clock),
        .reset(reset),
        .read(read_timer),
        .write(write_timer),
        .address(address_bus[3:2]),
        .data(data_bus),
        .timer_interrupt(timer_interrupt)
    );

    wire is_software_interrupt_address = (address_bus == 32'h81000014);
    assign software_interrupt = software_interrupt_reg;
    reg software_interrupt_reg;
    always @(posedge clock) begin
        if (reset) software_interrupt_reg <= 0;
        else if (write && is_software_interrupt_address) software_interrupt_reg <= data_bus[0];
    end

    wire is_os_ram_address = (address_bus >= 32'hff000000);
    wire write_os_ram = write && is_os_ram_address;
    wire read_os_ram = read && is_os_ram_address;
    ram #(
        .MEM_INIT_FILE(RAM_DATA),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PROGRAM_SIZE(PROGRAM_SIZE)
    ) os_ram (
        .clock(clock),
        .write(write_os_ram),
        .read(read_os_ram),
        .data_size(data_size),
        .address(address_bus[ADDR_WIDTH-1:0]),
        .data(data_bus)
    );

//clock generation
    initial begin
        clock = 1;
        forever #CLOCK_UPDATE_TIME clock = ~clock;
    end
// Simplified Debugging display
    initial begin
        if (DISPLAY_TOGGLE == 1) begin
            #INSTRUCTION_TIME;
            $printtimescale(test_drisc);
            $display("Clock cicle duration = %0d, Instruction duration = %0d, Simulation max duration = %0d", CLOCK_UPDATE_TIME * 2, INSTRUCTION_TIME, SIMULATION_TIME);
            $display("        |            |      | addr             addr            addr           |            |     Instruction    ");
            $display("  Time  | Instruction|  PC  | [ AA ]:Reg A    [ BB ]:Reg B    [ CC ]:Reg C    |  Immediate |   Code   Argument  ");
            forever #INSTRUCTION_TIME begin
                $display("%0s%0d\t|  %h  | %d | [%s]:%h [%s]:%h [%s]:%h |%d | %s %0s",
                    ($time % (2*INSTRUCTION_TIME)) < INSTRUCTION_TIME/4 ? "\033[0m" : "\033[1;30m",
                    $time,
                    current_instruction,
                    drisc_processor.pc_current_out[11:2],
                    decode_register(drisc_processor.registers_addresses[9:5]),
                    drisc_processor.a_bus,
                    decode_register(drisc_processor.registers_addresses[14:10]),
                    drisc_processor.b_bus,
                    decode_register(drisc_processor.registers_addresses[4:0]),
                    drisc_processor.c_bus,
                    $signed(drisc_processor.immediate),
                    decode_opcode(current_instruction[6:0]),
                    decode_op_function(drisc_processor.op_function,drisc_processor.data_type, current_instruction[6:0])
                );
            end
        end
    end
// Complex Debugging display
    initial begin
        if (DISPLAY_TOGGLE == 0) begin
            #INSTRUCTION_TIME;
            #1;//offsets so signals updated after the clock are displayed correctly
            forever #CLOCK_UPDATE_TIME begin
                if(drisc_processor.phase == 3'b001 & clock == 1) begin
                    $display("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
                end
                $display("%0sTime %0d | Phi %b clk %b r %b| PC: N %h C %h| Instruction : N %h C %h| Bus: A %h[%d] B %h[%d] C %h[%d], imm %h| IO bus: %h, Ram Addr %h %h, W/R %b%b | Opcode: %0s | cnzv: %b %b %b",
                    clock == 1? "\033[0m" : "\033[1;30m",
                    $time,
                    drisc_processor.phase,
                    clock,
                    reset,
                    drisc_processor.pc_next_out,
                    drisc_processor.pc_current_out,
                    drisc_processor.next_instruction,
                    current_instruction,
                    drisc_processor.a_bus,
                    drisc_processor.registers_addresses[9:5],
                    drisc_processor.b_bus,
                    drisc_processor.registers_addresses[14:10],
                    drisc_processor.c_bus,
                    drisc_processor.registers_addresses[4:0],
                    drisc_processor.immediate,
                    data_bus,
                    address_bus,
                    address_bus,
                    write,
                    read,
                    decode_opcode(current_instruction[6:0]),
                    drisc_processor.cnzv,
                    drisc_processor.operation_controller.decoded_cnzv,
                    drisc_processor.operation_controller.pc_jump
                );
            end
        end
    end

// even more simplified Debugging display
    initial begin
        if (DISPLAY_TOGGLE == 2) begin
            #(3*INSTRUCTION_TIME/2);
            $printtimescale(test_drisc);
            $display("Clock cicle duration = %0d, Instruction duration = %0d, Simulation max duration = %0d", CLOCK_UPDATE_TIME * 2, INSTRUCTION_TIME, SIMULATION_TIME);
            forever begin
                if(($time % INSTRUCTION_TIME) == INSTRUCTION_TIME/2 + 1)
                    #(INSTRUCTION_TIME-1);
                else #INSTRUCTION_TIME;
                $write("%0s%0d PC:%0h%s%s\t| %s %s",
                    (($time + INSTRUCTION_TIME / 2 ) % (2 * INSTRUCTION_TIME)) < INSTRUCTION_TIME / 4 ? "\033[0m" : "\033[1;30m",
                    $time,
                    drisc_processor.pc_current_out,
                    privilege(),
                    prev_privilege(),
                    current_instruction_string(),
                    current_trap()
                );
                if(current_instruction[6:0] == 7'h03) begin
                    #1;
                    $write("%0d (0x%0h)", drisc_processor.input_buffer_out,  drisc_processor.input_buffer_out);
                end
                if(CSR_ENABLED) $display("\n\t\t\t|");
                else $display("\n\t\t|");
            end
        end
    end

// Infinite loop and illegal instruction detection
    initial begin
        #(INSTRUCTION_TIME*4);
        forever #(INSTRUCTION_TIME) begin
            if (drisc_processor.jump && drisc_processor.program_counter.calculated_address == drisc_processor.program_counter.current) begin
                $display("\33[1;31mInfinite loop detected, exiting simulation");
                $display("\33[0m");
                dump_registers();
                dump_ram();
                $finish;
            end else if (decode_opcode(current_instruction[6:0]) == "UNKNOWN" && !ALLOW_ILLEGAL_INSTRUCTIONS) begin
                $display("\33[1;31mIllegal instruction detected, exiting simulation");
                $display("\33[0m");
                dump_registers();
                dump_ram();
                $finish;
            end
        end
    end

// Test sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0,test_drisc);
        #1
        // Initialize signals
        reset = 1;
        #INSTRUCTION_TIME;
        reset = 0;
        #SIMULATION_TIME;

        $display("\33[0m");
        dump_registers();
        dump_ram();
        $finish;
    end
// Helper tasks and functions
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
                $display("R[%0d] (%s) = %h", i, reg_name, drisc_processor.register_file.registers[i]);
            end
        end
    endtask

    task dump_ram;
        integer i, j, inc;
        bit print_zero;

        //inicialize test memory
        logic [7:0] mem [0:(1 << ADDR_WIDTH)-1];
        for (int i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            mem[i] = 8'h00;
        end
        $readmemh(RAM_DATA, mem, 0, PROGRAM_SIZE-1);

        begin
            print_zero = 1;
            $display("RAM values:");
            for (i = 0; i < (1 << ADDR_WIDTH)/16 ; i = i + 1) begin
                inc = 0;
                for(j = 0; j < 16; j = j + 1) begin
                    inc = mem[i * 16 + j] === ram_inst.mem[i * 16 + j] ?
                        inc | ram_inst.mem[i * 16 + j] : 1;
                end
                if (inc != 0) begin
                    $write("\033[0mAddress %h: ", i*16);
                    for (j = 0; j < 16; j = j + 1) begin
                        $write("%0s%h",(mem[i*16 + j] === ram_inst.mem[i*16 + j]) ?
                            "\033[0m" : "\033[1;31m", ram_inst.mem[i*16 + j]);
                        if ( ((j + 1) % 4) == 0 && j < 15) $write(".");
                        else $write(" ");
                    end
                    $display("");
                    print_zero = 1;
                end
                else if(print_zero) begin
                    $display("\033[0m\t\t\t(Zeroes Ommited)");
                    print_zero = 0;
                end
            end
        end
    endtask

    function string privilege();
        if (CSR_ENABLED) return drisc_processor.csr.csr_controller.privilege ? " P:M" : " P:U";
        else return "";
    endfunction

    function string prev_privilege();
        if (CSR_ENABLED) return drisc_processor.csr.csr_controller.previous_privilege ? " PP:M" : " PP:U";
        else return "";
    endfunction

    function bit [31:0] decode_register(input [4:0] register);
        case (register)
            5'b00000: decode_register = "zero";
            5'b00001: decode_register = "ra ";
            5'b00010: decode_register = "sp ";
            5'b00011: decode_register = "gp ";
            5'b00100: decode_register = "tp ";
            5'b00101: decode_register = "t0 ";
            5'b00110: decode_register = "t1 ";
            5'b00111: decode_register = "t2 ";
            5'b01000: decode_register = "s0 ";
            5'b01001: decode_register = "s1 ";
            5'b01010: decode_register = "a0 ";
            5'b01011: decode_register = "a1 ";
            5'b01100: decode_register = "a2 ";
            5'b01101: decode_register = "a3 ";
            5'b01110: decode_register = "a4 ";
            5'b01111: decode_register = "a5 ";
            5'b10000: decode_register = "a6 ";
            5'b10001: decode_register = "a7 ";
            5'b10010: decode_register = "s2 ";
            5'b10011: decode_register = "s3 ";
            5'b10100: decode_register = "s4 ";
            5'b10101: decode_register = "s5 ";
            5'b10110: decode_register = "s6 ";
            5'b10111: decode_register = "s7 ";
            5'b11000: decode_register = "s8 ";
            5'b11001: decode_register = "s9 ";
            5'b11010: decode_register = "s10";
            5'b11011: decode_register = "s11";
            5'b11100: decode_register = "t3 ";
            5'b11101: decode_register = "t4 ";
            5'b11110: decode_register = "t5 ";
            5'b11111: decode_register = "t6 ";
            default: decode_register = "????";
        endcase
    endfunction

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

    function bit [8*15-1:0] decode_op_function(input [4:0] op_function,input [2:0]funct_3, input [6:0] opcode);
        if(opcode != 7'h13 && opcode != 7'h33 && opcode != 7'h03 && opcode != 7'h23 && opcode != 7'h63) begin
            return "--------";
        end

        if(opcode == 7'h13 || opcode == 7'h33) begin
            case ((opcode == 7'h13 & ~(op_function == 1 | op_function == 5 | op_function == 21)) ?
                    {2'b0, op_function[2:0]} : op_function)
                0: decode_op_function = "ADD";
                1: decode_op_function = "SLL";
                2: decode_op_function = "SLT";
                3: decode_op_function = "SLTU";
                4: decode_op_function = "XOR";
                5: decode_op_function = "SRL";
                6: decode_op_function = "OR";
                7: decode_op_function = "AND";
                8: decode_op_function = "MUL";
                9: decode_op_function = "MULH";
                10: decode_op_function = "MULHSU";
                11: decode_op_function = "MULHU";
                12: decode_op_function = "DIV";
                13: decode_op_function = "DIVU";
                14: decode_op_function = "REM";
                15: decode_op_function = "REMU";
                16: decode_op_function = "SUB";
                21: decode_op_function = "SRA";
                default: decode_op_function = "UNKNOWN";
            endcase
        end
        else if(opcode == 7'h03 || opcode == 7'h23) begin
            case (funct_3)
                3'b000: decode_op_function = "BYTE";
                3'b001: decode_op_function = "HALF";
                3'b010: decode_op_function = "WORD";
                3'b100: decode_op_function = "U_BYTE";
                3'b101: decode_op_function = "U_HALF";
                default: decode_op_function = "INVALID";
            endcase
        end else if(opcode == 7'h63) begin
            case (funct_3)
                3'b000: decode_op_function = "EQUAL";
                3'b001: decode_op_function = "NOT_EQUAL";
                3'b100: decode_op_function = "LESS_THAN";
                3'b101: decode_op_function = "GREATER_EQUAL";
                3'b110: decode_op_function = "LESS_THAN_U";
                3'b111: decode_op_function = "GREATER_EQUAL_U";
                default: decode_op_function = "INVALID";
            endcase
        end
    endfunction

    //function for the simpler display mode
    function automatic string current_instruction_string();
        bit[31:0] a_address = decode_register(drisc_processor.register_file.a_address);
        bit[31:0] b_address = decode_register(drisc_processor.register_file.b_address);
        bit[31:0] c_address = decode_register(drisc_processor.register_file.c_address);
        integer a_bus = drisc_processor.a_bus;
        integer b_bus = drisc_processor.b_bus;
        integer c_bus = drisc_processor.c_bus;
        integer immediate = drisc_processor.immediate;
        bit is_shift = drisc_processor.op_function == 1 | drisc_processor.op_function == 5 | drisc_processor.op_function == 21;
        string op;

        if(current_instruction == 32'h00000013) return "No Operation\t\t\t\t---------------------------------";

        case(current_instruction[6:0])
            7'h13,7'h33: begin //alu operations
                case (drisc_processor.alu.op)
                    0: op = "+";
                    1: op = "<<";
                    2: op = "<";
                    3: op = "<u";
                    4: op = "^";
                    5: op = ">>";
                    6: op = "|";
                    7: op = "&";
                    8: op = "*";
                    9: op = "*H";
                    10: op = "*H_su";
                    11: op = "*H_u";
                    12: op = "/";
                    13: op = "/u";
                    14: op = "\%";
                    15: op = "\%u";
                    16: op = "-";
                    21: op = ">>>";
                    default: op = "UNK";
                endcase
                if(current_instruction[6:0] == 7'h13)//if is immediate instructions
                    if(is_shift) return $sformatf("%s <= %s %s immediate  \t\t%s <= %0d %s %0d = %0d (0x%h)",
                                trim(c_address), trim(a_address), op, trim(c_address), a_bus, op, immediate[4:0], c_bus, c_bus);
                    else return $sformatf("%s <= %s %s immediate  \t\t%s <= %0d %s %0d = %0d (0x%h)",
                                trim(c_address), trim(a_address), op, trim(c_address), a_bus, op, immediate, c_bus, c_bus);
                else return $sformatf("%s <= %s %s %s \t\t\t%s <= %0d %s %0d = %0d (0x%h)",
                        trim(c_address), trim(a_address), op, trim(b_address),trim(c_address), a_bus, op, b_bus, c_bus, c_bus);
            end
            7'h03,7'h23: begin
                case (current_instruction[14:12])
                    3'b000: op = "byte";
                    3'b001: op = "half";
                    3'b010: op = "word";
                    3'b100: op = "u_byte";
                    3'b101: op = "u_half";
                    default: op = "unknown";
                endcase
                if(current_instruction[6:0] == 7'h23)
                    return $sformatf("M[%s + %0d] <= %s (%s)  \t\tM[%0d + %0d] = %0d (0x%0h)",
                        trim(a_address), immediate, trim(b_address), op, a_bus, immediate, b_bus, b_bus);
                else
                    return $sformatf("%s <= M[%s + %0d] (%s)  \t\t%s <= M[%0d + %0d] =",
                        trim(c_address), trim(a_address), immediate, op, trim(c_address), a_bus, immediate);

            end
            7'h63: begin
                case (current_instruction[14:12])
                    3'b000: op = "==";
                    3'b001: op = "!=";
                    3'b100: op = "<";
                    3'b101: op = ">=";
                    3'b110: op = "<(u)";
                    3'b111: op = ">(u)";
                    default: op = "unknown";
                endcase
                return $sformatf("Next PC <= PC + %0d if(%s %s %s)  \t%0d %s %0d = %0s",
                    immediate, trim(a_address), op, trim(b_address), a_bus, op, b_bus, drisc_processor.operation_controller.jump ? "true" : "false");
            end
            7'h67: begin
                if(c_address == decode_register(5'b0)) begin
                    return $sformatf("Next PC <= %s + immediate\t\tPC <= %0d + %0d = %0d (0x%h)",
                        trim(a_address), a_bus, immediate, a_bus + immediate, a_bus + immediate);
                end
                return $sformatf("Next PC <= %s + immediate  %s <= PC\tPC <= %0d + %0d = %0d (0x%h)",
                    trim(a_address), trim(c_address), a_bus, immediate, a_bus + immediate, a_bus + immediate);
            end
            7'h6f: begin
                if(c_address == decode_register(5'b0)) begin
                    return $sformatf("Next PC <= PC + immediate  \t\tPC <= PC + %0d = %0d (0x%h)",
                    immediate, drisc_processor.pc_current_out + immediate, drisc_processor.pc_current_out + immediate);
                end
                return $sformatf("Next PC <= PC + immediate  %s <= PC\tPC <= PC + %0d = %0d (0x%h)",
                    trim(c_address), immediate, drisc_processor.pc_current_out + immediate, drisc_processor.pc_current_out + immediate);
            end
            7'h37: begin
                return $sformatf("%s <= immediate high\t\t\t%s <= %0d (0x%h)",
                    trim(c_address),trim(c_address),immediate, immediate);
            end
            7'h17: begin
                return $sformatf("%s <= PC + immediate high\t\t%s <= %0d + %0d = %0d (0x%h)",
                    trim(c_address),trim(c_address),drisc_processor.pc_current_out, immediate, drisc_processor.alu_out, drisc_processor.alu_out);
            end
            7'h73: begin
                if(!CSR_ENABLED) return "CSR Instruction, enable CSR support to execute properly";
                else if(current_instruction[14:12] == 3'b0) begin
                    case(current_instruction[31:20])
                        `MRET: return $sformatf("Machine Return    Privilege <= %0s   Next PC <= %0d (0x%h)",
                                trim(prev_privilege()), {drisc_processor.csr.csr_controller.mepc_reg,2'b0}, {drisc_processor.csr.csr_controller.mepc_reg,2'b0});
                        `EBREAK: return $sformatf("Environment Breakpoint  Privilege <= Kernel   Next PC <= %0d (0x%h)",
                                drisc_processor.system_address_target, drisc_processor.system_address_target);
                        `ECALL: return $sformatf("Environment Call  Privilege <= Kernel   Next PC <= %0d (0x%h)",
                                drisc_processor.system_address_target, drisc_processor.system_address_target);
                    endcase
                end
                else begin
                    if(trim(c_address) != "zero") begin
                        op = $sformatf("%s <= ", trim(c_address));
                    end

                    op = {op, current_csr()};

                    case(current_instruction[13:12])
                        2'b01: op = {op, $sformatf(" <= %0s   \t\t", trim(a_address))};
                        2'b10:
                            if(a_address == decode_register(5'b0)) op = {op, "   \t\t\t"};
                            else op = {op, $sformatf(" <= |= %0s   \t\t", trim(a_address))};
                        2'b11: op = {op, $sformatf(" <= &= ~ %0s   \t\t", trim(a_address))};
                        default: op = {op, "invalid_op"};
                    endcase

                    if(trim(c_address) != "zero") begin
                        op = {op, $sformatf("%s <= %0d(0x%8h)", trim(c_address),
                            drisc_processor.csr.csr_controller.c_bus, drisc_processor.csr.csr_controller.c_bus)};
                    end

                    op = {op,"\t"};

                    case(current_instruction[13:12])
                        2'b01: op = {op, $sformatf("%0s <= %0d(0x%8h)",current_csr(),
                            drisc_processor.a_bus,drisc_processor.a_bus)};
                        2'b10: op = {op, a_address == decode_register(5'b0) ? "" : {$sformatf("%0s <= |= %0d(0x%8h)",current_csr(),
                            drisc_processor.a_bus,drisc_processor.a_bus)}};
                        2'b11: op = {op, $sformatf("%0s <= &= ~%0d(0x%8h)", current_csr(),
                            drisc_processor.a_bus, drisc_processor.a_bus)};
                        default: op = {op, "invalid_op"};
                    endcase

                    return op;
                end
            end
        endcase

        return $sformatf("NOT IMPLEMENTED YET (0x%8h)", current_instruction);
    endfunction

    function string current_csr();
        case(current_instruction[31:20])
            `M_VENDOR_ID : current_csr = "m_vendor_id";
            `M_ARCH_ID : current_csr = "m_arch_id";
            `M_IMP_ID : current_csr = "m_imp_id";
            `M_HART_ID : current_csr = "m_hart_id";
            `M_STATUS : current_csr = "m_status";
            `M_ISA : current_csr = "m_isa";
            `M_I_E : current_csr = "m_i_e";
            `M_T_VEC : current_csr = "m_t_vec";
            `M_STATUS_H : current_csr = "m_status_h";
            `M_SCRATCH : current_csr = "m_scratch";
            `M_E_PC : current_csr = "m_e_pc";
            `M_CAUSE : current_csr = "m_cause";
            `M_T_VAL : current_csr = "m_t_val";
            `M_I_P : current_csr = "m_i_p";
            `CYCLE : current_csr = "cycle";
            `TIME : current_csr = "time";
            `INSTRET : current_csr = "inst_ret";
            `CYCLE_H : current_csr = "cycle_h";
            `TIME_H : current_csr = "time_h";
            `INSTRET_H : current_csr = "inst_ret_h";
            default : current_csr = "invalid_csr";
        endcase
    endfunction

    function automatic string trim(input string str);
        int first = 0;
        int last = str.len() - 1;

        while ((first <= last) && (str[first] == " ")) begin
            first++;
        end

        while ((last >= first) && (str[last] == " ")) begin
            last--;
        end

        if (first > last) return "";
        return str.substr(first, last);
    endfunction

    function string current_trap();
        if(!CSR_ENABLED) return "";
        else if(drisc_processor.csr.csr_controller.interrupt | drisc_processor.csr.csr_controller.exception) begin
            case(drisc_processor.csr.csr_controller.trap_cause)
                `MACHINE_SOFTWARE_INTERRUPT: return "\033[1;31mTrap Triggered: Software Interrupt\033[0m";
                `MACHINE_TIMER_INTERRUPT: return "\033[1;31mTrap Triggered: Timer Interrupt\033[0m";
                `MACHINE_EXTERNAL_INTERRUPT: return "\033[1;31mTrap Triggered: External Interrupt\033[0m";
                `INSTRUCTION_ADDRESS_MISALIGNED: return "\033[1;31mTrap Triggered: Illegal Address\033[0m";
                `ILLEGAL_INSTRUCTION: return "\033[1;31mTrap Triggered: Illegal Instruction\033[0m";
                `BREAKPOINT: return "\033[1;31mTrap Triggered: Breakpoint Reached\033[0m";
                `LOAD_ADDRESS_MISALIGNED: return "\033[1;31mTrap Triggered: Load Address Misaligned\033[0m";
                `STORE_ADDRESS_MISALIGNED: return "\033[1;31mTrap Triggered: Store Address Misaligned\033[0m";
                `ECALL_FROM_USER_MODE: return "\033[1;31mTrap Triggered: Environment Call From User Mode\033[0m";
                `ECALL_FROM_MACHINE_MODE: return "\033[1;31mTrap Triggered: Environment Call From Machine Mode\033[0m";
                default: return "";
            endcase
        end
    endfunction

endmodule
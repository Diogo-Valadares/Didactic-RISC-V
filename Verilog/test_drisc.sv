module test_drisc;
    parameter RAM_DATA = "load_store.mem";
    parameter ADDR_WIDTH = 12;
    parameter PROGRAM_SIZE = 512;

    parameter CLOCK_UPDATE_TIME = 1;
    parameter INSTRUCTION_TIME = 6;
    parameter INSTRUCTION_COUNT = 10000;
    parameter SIMULATION_TIME = INSTRUCTION_COUNT * INSTRUCTION_TIME;

    parameter DISPLAY_TOGGLE = 1;//simple=1 complex=0

    reg clock;
    reg reset;
    wire [31:0] data_bus;
    wire [31:0] data_bus_drisc;
    wire data_bus_out_enable;
    wire [1:0] data_size;
    wire write_address;
    wire write;
    wire read;
    wire [6:0] opcode_debug;
    wire [31:0] address_bus;

    assign data_bus = data_bus_out_enable ? data_bus_drisc : 32'hz;

    drisc drisc_processor (
        .clock(clock),
        .reset(reset),
        .data_bus_in(data_bus),
        .data_bus_out(data_bus_drisc),
        .data_bus_out_enable(data_bus_out_enable),
        .address_bus(address_bus),
        .data_size(data_size),
        .write_address(write_address),
        .write(write),
        .read(read),
        .opcode_debug(opcode_debug)
    );

    ram #(
        .MEM_INIT_FILE(RAM_DATA),
        .ADDR_WIDTH(ADDR_WIDTH),
        .PROGRAM_SIZE(PROGRAM_SIZE)
    ) ram_inst (
        .clock(clock),
        .reset(reset),
        .write(write),
        .write_address(write_address),
        .read(read),
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
        $display("Clock cicle duration = %0d, Instruction duration = %0d, Simulation max duration = %0d", CLOCK_UPDATE_TIME * 2, INSTRUCTION_TIME, SIMULATION_TIME); 
        $display("        |            |      | addr             addr            addr  |            |     Instruction    "); 
        $display("  Time  | Instruction|  PC  | [ AA ]:Reg A    [ BB ]Reg B     [ CC ] |  Immediate |   Code   Argument  "); 
        forever #INSTRUCTION_TIME begin
            if (DISPLAY_TOGGLE) begin
                $display("%0s%0d\t|  %h  | %d | [%s]:%h [%s]:%h [%s] |%d | %s %0s", 
                    ($time % (2*INSTRUCTION_TIME)) < INSTRUCTION_TIME/4 ? "\033[0m" : "\033[1;30m",
                    $time,
                    drisc_processor.operation_controller_0.current_instruction, 
                    drisc_processor.pc_current_out[11:2], 
                    decode_register(drisc_processor.registers_addresses[9:5]),
                    drisc_processor.a_bus,
                    decode_register(drisc_processor.registers_addresses[14:10]),
                    drisc_processor.b_bus,
                    decode_register(drisc_processor.registers_addresses[4:0]),
                    $signed(drisc_processor.immediate),
                    decode_opcode(opcode_debug),
                    decode_op_function(drisc_processor.op_function,drisc_processor.funct_3, opcode_debug)
                );
            end
        end
    end
    // Complex Debugging display
    initial begin
        #1;
        forever #CLOCK_UPDATE_TIME begin
            if (!DISPLAY_TOGGLE) begin
                if(drisc_processor.phase == 3'b001 & clock == 1) begin
                    $display("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
                end
                $display("%0sTime %0d | Phi %b clk %b| PC:Addr In %h, Next %h Curr %h| Instruction : Next %h | Bus A: %h (R[%d]), Bus B: %h (R[%d]), Bus C: %h (R[%d]), imm %h| IO bus: %h, Ram Addr %h %h, W_A/W/R %b%b%b | Opcode: %0s | cnzv: %b %b %b", 
                    clock == 1? "\033[0m" : "\033[1;30m",
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
                    data_bus,
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
    // Infinite loop and illegal instruction detection
    initial begin
        #(INSTRUCTION_TIME*4);
        forever #(INSTRUCTION_TIME) begin
            if (drisc_processor.pc_current_out == drisc_processor.pc_next_out) begin
                $display("\33[1;31mInfinite loop detected, exiting simulation");
                $display("\33[0m");
                dump_registers();
                dump_ram();
                $finish;
            end else if (decode_opcode(opcode_debug) == "UNKNOWN") begin
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
        // Initialize signals
        reset = 1;
        #20;
        reset = 0; 
        #SIMULATION_TIME;

        $display("\33[0m");
        dump_registers();
        dump_ram();
        $finish;
    end

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

    task dump_ram;
        integer i, j, inc;
        bit print_zero = 1;        

        //inicialize test memory
        logic [7:0] mem [0:(1 << ADDR_WIDTH)-1];
        for (int i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            mem[i] = 8'h00;
        end
        $readmemh(RAM_DATA, mem, 0, PROGRAM_SIZE-1);

        begin
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
endmodule
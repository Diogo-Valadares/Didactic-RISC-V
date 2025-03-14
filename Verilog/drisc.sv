`include "phase_generator.sv"
`include "program_counter.sv"
`include "input_buffer.sv"
`include "operation_controller.sv"
`include "register_file.sv"
`include "alu.sv"

module drisc(
    input clock,
    input reset,
    input [31:0] data_bus_in,
    output [31:0] data_bus_out,
    output [31:0] address_bus,
    output [1:0] data_size,
    output write,
    output read,
    output [31:0] current_instruction
);

    wire [2:1] phase;
    
//internal busses
    wire [31:0]a_bus;
    wire [31:0]b_bus;
    wire [31:0]c_bus = 
        data_io_read ? data_io_out_c :
        load_upper_immediate ? immediate :
        pc_read_next ? pc_next_out :
        alu_out;

//outputs to c bus
    wire [31:0] pc_next_out;
    wire [31:0] alu_out;
    wire [31:0] shifter_out;
    wire [31:0] data_io_out_c;
    
//program counter
    wire [31:0] pc_current_out;
    wire [1:0] data_offset;
    
//controller wires
    wire [31:0] immediate;
    wire [2:0] data_type;
    wire load_upper_immediate;
    wire [14:0] registers_addresses;
    wire register_file_write;
    wire [3:0] cnzv;
    wire [4:0] op_function;
    wire alu_read;
    wire alu_use_pc;
    wire use_immediate;
    wire shifter_read;
    wire pc_relative;
    wire pc_read_next;
    wire pc_jump;
    wire pc_use_offset;
    wire forward_address;
    wire data_io_write;
    wire data_io_read;

//components
    phase_generator phase_generator_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase)
    );

    program_counter program_counter_0 (
        .reset(reset),
        .clock(clock),
        .write(phase[2]),
        .jump(pc_jump),
        .pc_relative(pc_relative),
        .use_offset(pc_use_offset),
        .forward_address(forward_address),
        .immediate(immediate),
        .address_in(a_bus),
        .data_offset(data_offset),
        .next(pc_next_out),
        .current(pc_current_out),
        .address_bus(address_bus)
    );

    assign data_bus_out = b_bus;

    input_buffer input_buffer_0 (
        .clock(clock),
        .write(data_io_write),
        .data_type(data_type),
        .data_offset(data_offset),
        .io_in(data_bus_in),
        .cpu_out(data_io_out_c)
    );

    operation_controller operation_controller_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .data_in(data_bus_in),
        .immediate(immediate),
        .current_instruction(current_instruction),
        .load_upper_immediate(load_upper_immediate),
        .registers_addresses(registers_addresses),
        .register_file_write(register_file_write),
        .cnzv(cnzv),
        .op_function(op_function),
        .alu_use_pc(alu_use_pc),
        .use_immediate(use_immediate),
        .pc_relative(pc_relative),
        .pc_read_next(pc_read_next),
        .pc_jump(pc_jump),
        .pc_use_offset(pc_use_offset),
        .forward_address(forward_address),
        .data_io_write(data_io_write),
        .data_io_read(data_io_read),
        .data_type(data_type),
        .pad_read(read),
        .pad_write(write),
        .pad_data_size(data_size)
    );

    register_file register_file_0 (
        .clock(clock),
        .reset(reset),
        .write(register_file_write),
        .a_address(registers_addresses[9:5]),
        .b_address(registers_addresses[14:10]),
        .c_address(registers_addresses[4:0]),
        .c_in(c_bus),
        .a_out(a_bus),
        .b_out(b_bus)
    );

    alu alu_0 (
        .use_pc(alu_use_pc),
        .a(a_bus),
        .program_counter(pc_current_out),
        .use_immediate(use_immediate),
        .b(b_bus),
        .immediate(immediate),
        .operation(op_function),
        .result(alu_out),
        .cnzv(cnzv)
    );
endmodule
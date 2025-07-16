`include "phase_generator.sv"
`include "program_counter.sv"
`include "input_buffer.sv"
`include "operation_controller.sv"
`include "register_file.sv"
`include "alu.sv"
`include "csr_controller.sv"
`timescale 1s/1s

module drisc(
    input clock,
    input reset,
    input [31:0] data_bus_in,
    input external_interrupt,
    input timer_interrupt,
    input software_interrupt,
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
        input_buffer_read ? input_buffer_out :
        load_upper_immediate ? immediate :
        pc_read_next ? pc_next_out :
        read_csr ? csr_out :
        alu_out;

//outputs to c bus
    wire [31:0] pc_next_out;
    wire [31:0] alu_out;
    wire [31:0] shifter_out;
    wire [31:0] input_buffer_out;
    
//program counter
    wire [31:0] pc_calculated_address;
    wire [31:0] pc_current_out;
    wire [1:0] data_offset;
    
//controller wires
    //immediate
    wire [31:0] immediate;
    wire load_upper_immediate;
    //register file
    wire [14:0] registers_addresses;
    wire register_file_write;
    //alu
    wire [3:0] cnzv;
    wire [4:0] op_function;
    wire alu_read;
    wire alu_use_pc;
    wire use_immediate;
    //pc
    wire pc_relative;
    wire pc_read_next;
    wire pc_jump;
    wire pc_use_offset;
    wire forward_address;
    //data io
    wire input_buffer_write;
    wire input_buffer_read;
    wire [2:0] data_type;
    //csr controller
    wire [9:0] current_decoded_instruction;

//csr controller
    wire exception;
    wire system_load;
    //for csr read/write instructions
    wire read_csr;
    wire [31:0] csr_out;
    //pc counter - provides a way to jump to trap handler and to mreturn.
    wire system_jump;
    wire [31:0] system_address_target;

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
        .system_jump(system_jump),
        .system_load(system_load),
        .system_address_target(system_address_target),
        .data_offset(data_offset),
        .calculated_address(pc_calculated_address),
        .next(pc_next_out),
        .current(pc_current_out),
        .address_bus(address_bus)
    );

    assign data_bus_out = b_bus;

    input_buffer input_buffer_0 (
        .clock(clock),
        .write(input_buffer_write),
        .data_type(data_type),
        .data_offset(data_offset),
        .io_in(data_bus_in),
        .cpu_out(input_buffer_out)
    );

    operation_controller operation_controller_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .data_in(data_bus_in),
        .immediate(immediate),
        .current_instruction(current_instruction),
        .current_decoded_instruction(current_decoded_instruction),
        .exception(exception),
        .system_load(system_load),
        .system_jump(system_jump),
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
        .input_buffer_write(input_buffer_write),
        .input_buffer_read(input_buffer_read),
        .data_type(data_type),
        .pad_read(read),
        .pad_write(write),
        .pad_data_size(data_size)
    );

    csr_controller csr_controller_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .pad_external_interrupt(external_interrupt),
        .pad_timer_interrupt(timer_interrupt),
        .pad_software_interrupt(software_interrupt),
        .current_decoded_instruction(current_decoded_instruction),
        .current_instruction(current_instruction),
        .a_bus(a_bus),
        .current_pc(pc_current_out),
        .calculated_address(pc_calculated_address),
        .pc_jump(pc_jump),
        .read_csr(read_csr),
        .c_bus(csr_out),
        .exception(exception),
        .system_load(system_load),
        .system_jump(system_jump),
        .system_address_target(system_address_target)
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
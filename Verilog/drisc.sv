`include "phase_generator.sv"
`include "program_counter.sv"
`include "input_buffer.sv"
`include "operation_controller.sv"
`include "register_file.sv"
`include "alu.sv"
`include "csr_controller.sv"
`timescale 1s/1s

module drisc #(
    parameter GENERATE_CSR_CONTROLLER = 1
) (
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
    output read
);

    wire [2:1] phase;

//internal busses
    wire signed [31:0] immediate;
    wire signed [31:0] a_bus;
    wire signed [31:0] b_bus;
    wire signed [31:0] c_bus =
        input_buffer_read ? input_buffer_out :
        load_upper_immediate ? immediate :
        pc_read_next ? pc_next_out :
        read_csr ? csr_out :
        alu_out;

//outputs to c bus
    wire [31:0] pc_next_out;
    wire [31:0] alu_out;
    wire [31:0] input_buffer_out;

//program counter
    wire unsigned [31:0] pc_calculated_address;
    wire unsigned [31:0] pc_current_out;
    wire unsigned [1:0] data_offset;

//controller wires
    wire [31:0] next_instruction;
    //immediate
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
    wire pc_use_offset;
    wire forward_address;
    //data io
    wire input_buffer_write;
    wire input_buffer_read;
    wire [2:0] data_type;
    //csr controller
    wire [9:0] next_decoded_instruction;
    wire [31:0] current_instruction;
    wire store;
    wire load;
    wire jump;

//csr controller
    //signals for the operation controller
    wire exception;
    wire next_system_load;
    //for csr read/write instructions
    wire read_csr;
    wire signed [31:0] csr_out;
    //pc counter - provides a way to jump to trap handler and to mreturn.
    wire system_load;
    wire system_jump;
    wire unsigned [31:0] system_address_target;

//components
    phase_generator phase_generator (
        .clock(clock),
        .reset(reset),
        .phase(phase)
    );

    program_counter program_counter (
        .reset(reset),
        .clock(clock),
        .write(phase[2]),
        .jump(jump),
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

    input_buffer input_buffer (
        .clock(clock),
        .write(input_buffer_write),
        .data_type(data_type),
        .data_offset(data_offset),
        .io_in(data_bus_in),
        .cpu_out(input_buffer_out)
    );

    operation_controller operation_controller (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        //IO interface
        .pad_read(read),
        .pad_write(write),
        .pad_data_size(data_size),
        .data_in(data_bus_in),
        //csr controller interface
        .next_instruction(next_instruction),
        .current_instruction(current_instruction),
        .next_decoded_instruction(next_decoded_instruction),
        .load(load),
        .store(store),
        .exception(exception),
        .next_system_load(next_system_load),
        .system_jump(system_jump),
        //register file
        .register_file_write(register_file_write),
        .registers_addresses(registers_addresses),
        //immediate
        .load_upper_immediate(load_upper_immediate),
        .immediate(immediate),
        //alu
        .op_function(op_function),
        .alu_use_pc(alu_use_pc),
        .use_immediate(use_immediate),
        .cnzv(cnzv),
        //pc
        .jump(jump),
        .pc_relative(pc_relative),
        .pc_read_next(pc_read_next),
        .pc_use_offset(pc_use_offset),
        .forward_address(forward_address),
        //input buffer
        .input_buffer_write(input_buffer_write),
        .input_buffer_read(input_buffer_read),
        .data_type(data_type)
    );
    generate
        if (GENERATE_CSR_CONTROLLER) begin : csr
            csr_controller csr_controller (
                .clock(clock),
                .reset(reset),
                .phase(phase),
                //pads
                .pad_external_interrupt(external_interrupt),
                .pad_timer_interrupt(timer_interrupt),
                .pad_software_interrupt(software_interrupt),
                //csr controller interface
                .next_decoded_instruction(next_decoded_instruction),
                .next_instruction(next_instruction),
                .current_instruction(current_instruction),
                .load(load),
                .store(store),
                .jump(jump),
                .exception(exception),
                .next_system_load(next_system_load),
                //pc counter interface
                .current_pc(pc_current_out),
                .calculated_address(pc_calculated_address),
                .system_address_target(system_address_target),
                .system_load(system_load),
                .system_jump(system_jump),
                //csr read/write interface
                .read_csr(read_csr),
                .a_bus(a_bus),
                .c_bus(csr_out)
            );
        end else begin : no_csr
            assign csr_out = 0;
            assign exception = 0;
            assign system_load = 0;
            assign next_system_load = 0;
            assign system_jump = 0;
            assign system_address_target = 0;
            assign read_csr = 0;
        end
    endgenerate


    register_file register_file (
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

    alu alu (
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
module drisc(
    input clock,
    input reset,
    inout [31:0] io_bus,
    output [31:0] address_bus,
    output [1:0]data_size,
    output write_address,
    output write,
    output read,
    output [6:0] opcode_debug
);

    wire [3:1] phase;

    wire [31:0] data_io_out_io;
    assign io_bus = data_io_read_io ? data_io_out_io : 32'bz ;

    //internal busses
    wire [31:0]a_bus;
    wire [31:0]b_bus;
    wire [31:0]c_bus = 
        data_io_load ? data_io_out_c :
        load_upper_immediate ? immediate :
        shifter_read ? alu_out :
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
    wire [31:0] pc_address_in;
    
    //controller wires
    wire [31:0] immediate;
    wire [2:0] funct_3;
    wire load_upper_immediate;
    wire [14:0] registers_addresses;
    wire register_file_write;
    wire [3:0] cnzv;
    wire [4:0] op_function;
    wire alu_read;
    wire alu_use_pc;
    wire use_immediate;
    wire shifter_read;
    wire address_alu_use_pc;
    wire pc_read_next;
    wire pc_jump;
    wire pc_use_offset;
    wire pc_addr_in_to_AD;
    wire data_io_write_io;
    wire data_io_read_io;
    wire data_io_load;

    // Instantiate the phase_generator module
    phase_generator phase_generator_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase)
    );

    // Instantiate the program_counter module
    program_counter program_counter_0 (
        .reset(reset),
        .clock(clock),
        .write(phase[3]),
        .jump(pc_jump),
        .use_offset(pc_use_offset),
        .address_in_to_AD(pc_addr_in_to_AD),
        .address_in(pc_address_in),
        .data_offset(data_offset),
        .next(pc_next_out),
        .current(pc_current_out),
        .AD_Bus(address_bus)
    );

    // Instantiate the data io module
    data_io data_io_0 (
        .clock(clock),
        .store(phase[1]),
        .load(data_io_write_io),
        .data_type(funct_3),
        .data_offset(data_offset),
        .cpu_in(b_bus),
        .io_in(io_bus),
        .cpu_out(data_io_out_c),
        .io_out(data_io_out_io)
    );

    // Instantiate the operation_controller module
    operation_controller operation_controller_0 (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .data_in(io_bus),
        .immediate(immediate),
        .opcode(opcode_debug),
        .funct_3(funct_3),
        .load_upper_immediate(load_upper_immediate),
        .registers_addresses(registers_addresses),
        .register_file_write(register_file_write),
        .cnzv(cnzv),
        .op_function(op_function),
        .alu_read(alu_read),
        .alu_use_pc(alu_use_pc),
        .use_immediate(use_immediate),
        .shifter_read(shifter_read),
        .address_alu_use_pc(address_alu_use_pc),
        .pc_read_next(pc_read_next),
        .pc_jump(pc_jump),
        .pc_use_offset(pc_use_offset),
        .pc_addr_in_to_AD(pc_addr_in_to_AD),
        .data_io_write_io(data_io_write_io),
        .data_io_read_io(data_io_read_io),
        .data_io_load(data_io_load),
        .pad_write_address(write_address),
        .pad_read(read),
        .pad_write(write),
        .pad_data_size(data_size)
    );

    // Instantiate the register_file module
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

    // Instantiate the alu module
    alu alu_0 (
        .clock(clock),
        .write(phase[1]),
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

    // Instantiate the address_alu module
    address_alu address_alu_0 (
        .clock(clock),
        .write(phase[1]),
        .use_pc(address_alu_use_pc),
        .a(a_bus),
        .program_counter(pc_current_out),
        .immediate(immediate),
        .result(pc_address_in)
    );
endmodule
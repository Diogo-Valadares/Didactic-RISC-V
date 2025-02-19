module test_operation_controller;

    reg clock;
    reg reset;
    reg [3:1] phase;
    reg [31:0] data_in;
    reg [3:0] cnzv;
    wire [31:0] immediate;
    wire [6:0] opcode;
    wire [2:0] funct_3;
    wire load_upper_immediate;
    wire [14:0] registers_addresses;
    wire register_file_write;
    wire [5:0] op_function;
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
    wire pad_write_address;
    wire pad_read;
    wire pad_write;
    wire pad_data_size;

    // Instantiate the operation_controller module
    operation_controller uut (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .data_in(data_in),
        .immediate(immediate),
        .opcode(opcode),
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
        .pad_write_address(pad_write_address),
        .pad_read(pad_read),
        .pad_write(pad_write),
        .pad_data_size(pad_data_size)
    );
    // Monitor output signals
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
    // Generate clock signal
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Clock period of 10 units
    end

    initial begin
        // Initialize signals
        reset = 0;
        phase = 3'b001;
        data_in = 32'hFFFFFFFF;
        cnzv = 4'b0000;

        // Apply reset
        #10 reset = 1;
        #10 reset = 0;

        // Cycle through phases and test different opcodes
        // Load instruction
        data_in = 32'h00000303;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Store instruction
        data_in = 32'h0f002323;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Immediate operation instruction
        data_in = 32'hff001313;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Operation instruction
        data_in = 32'h0f003333;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Load upper immediate instruction
        data_in = 32'hffff3737;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Branch instruction (no branch)
        data_in = 32'h00006363; cnzv = 4'b0000;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Branch instruction (branch)
        data_in = 32'h00006363; cnzv = 4'b1111;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Empty ADDI instruction after branch
        data_in = 32'h00000013;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Jump and link register instruction
        data_in = 32'h00006767;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Empty ADDI instruction after JALR
        data_in = 32'h00000013;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Jump and link instruction
        data_in = 32'h00006F6F;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // Empty ADDI instruction after JAL
        data_in = 32'h00000013;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;

        // System instruction
        data_in = 32'h00007373;
        #10 phase = 3'b010; #10 phase = 3'b100; #10 phase = 3'b001;
        // Finish simulation
        #50 $finish;
    end

    // Intermediate nets for complex expressions
      // Intermediate wire for monitor string
    reg [4095*8:0] monitor_string;
    always @(*) begin
        monitor_string = "";
        if (register_file_write) monitor_string = {monitor_string, "register_file_write | "};
        if (alu_read) monitor_string = {monitor_string, "alu_read | "};
        if (alu_use_pc) monitor_string = {monitor_string, "alu_use_pc | "};
        if (use_immediate) monitor_string = {monitor_string, "use_immediate | "};
        if (shifter_read) monitor_string = {monitor_string, "shifter_read | "};
        if (address_alu_use_pc) monitor_string = {monitor_string, "address_alu_use_pc | "};
        if (pc_read_next) monitor_string = {monitor_string, "pc_read_next | "};
        if (pc_jump) monitor_string = {monitor_string, "pc_jump | "};
        if (pc_use_offset) monitor_string = {monitor_string, "pc_use_offset | "};
        if (pc_addr_in_to_AD) monitor_string = {monitor_string, "pc_addr_in_to_AD | "};
        if (data_io_write_io) monitor_string = {monitor_string, "data_io_write_io | "};
        if (data_io_read_io) monitor_string = {monitor_string, "data_io_read_io | "};
        if (data_io_load) monitor_string = {monitor_string, "data_io_load | "};
        if (pad_write_address) monitor_string = {monitor_string, "pad_write_address | "};
        if (pad_read) monitor_string = {monitor_string, "pad_read | "};
        if (pad_write) monitor_string = {monitor_string, "pad_write | "};
        if (pad_data_size) monitor_string = {monitor_string, "pad_data_size | "};
    end

    wire [63:0] opcode_string =  decode_opcode(opcode);


    initial begin
        $monitor("Time: %0t | data_in: %h | immediate: %h | cnzv: %b | reg_addrs: %h | opcode: %s | phase: %b | %0s",
              $time, data_in, immediate, cnzv, registers_addresses,  opcode_string, phase, monitor_string);
    end

endmodule

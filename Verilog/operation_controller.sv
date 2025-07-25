`timescale 1s/1s
module operation_controller(
    input clock,
    input reset,
    input [2:1] phase,
    input [31:0] data_in,
    output reg [31:0] immediate,
/////CSR Controller
    output [31:0] next_instruction,
    output reg [31:0] current_instruction,
    output [9:0] next_decoded_instruction,
    output reg store,
    output reg load,
    output jump,

    input exception,
    input system_jump,
    input next_system_load,
/////Miscellaneous/////
    output reg load_upper_immediate,
/////Register File/////
    output [14:0] registers_addresses,
    output register_file_write,
/////Alu and Shifter/////
    input [3:0] cnzv,
    output reg [4:0] op_function,
    output reg alu_use_pc,
    output reg use_immediate,
/////Program Counter/////
    output pc_read_next,
    output reg pc_relative,
    output pc_use_offset,
    output forward_address,
/////Data IO/////
    output reg [2:0] data_type,
    output input_buffer_write,
    output input_buffer_read,
/////Output Interface/////
    output pad_read,
    output pad_write,
    output [1:0]pad_data_size
);

// instruction decoder
    reg [31:0] next_instruction_reg;
    assign next_instruction = flush ? 32'h00000013 : next_instruction_reg ;

    wire next_immediate = next_instruction[6:0] == 7'h13;
    wire next_load = next_instruction[6:0] == 7'h03 | next_system_load;
    wire next_add_upper_immediate_pc = next_instruction[6:0] == 7'h17;
    wire next_store = next_instruction[6:0] == 7'h23;
    wire next_operation = next_instruction[6:0] == 7'h33 | next_immediate;
    wire next_load_upper_immediate = next_instruction[6:0] == 7'h37;
    wire next_branch = next_instruction[6:0] == 7'h63;
    wire next_jump_and_link_register = next_instruction[6:0] == 7'h67;
    wire next_jump_and_link = next_instruction[6:0] == 7'h6f;
    wire next_system = next_instruction[6:0] == 7'h73;

    assign next_decoded_instruction = {
        next_system, next_jump_and_link, next_jump_and_link_register, next_branch, next_load_upper_immediate,
        next_operation, next_store, next_add_upper_immediate_pc, next_immediate, next_load
    };

// register file addresses
    assign registers_addresses = {
        current_instruction[24:15], last_load & phase[1] ? last_c_address : current_instruction[11:7]
    };
    assign register_file_write = phase[2] & write_c & !exception | phase[1] & last_load;

// instructions function number
    wire [6:0] next_funct_7 = next_instruction[31:25];
    wire [2:0] next_funct_3 = next_instruction[14:12];

    wire valid_store = store & !exception;
    wire valid_load = load & !exception;

///Registers
    reg [4:0] last_c_address;

    reg write_c;
    reg unconditional_jump;
    reg branch;
    reg last_load;

//********************************************************************************************************************//
// Program Counter
    assign pc_read_next = phase[2] & unconditional_jump;

    wire decoded_cnzv =
        current_instruction[14:12] == 3'h0 ? cnzv[2] :
        current_instruction[14:12] == 3'h1 ? ~cnzv[2] :
        current_instruction[14:12] == 3'h4 ? (cnzv[1] ^ cnzv[3]) :
        current_instruction[14:12] == 3'h5 ? ~(cnzv[1] ^ cnzv[3]) :
        current_instruction[14:12] == 3'h6 ? cnzv[0] :
        current_instruction[14:12] == 3'h7 ? ~cnzv[0] : 1'b0;

    assign jump = unconditional_jump | (branch & decoded_cnzv);

    wire flush = jump | system_jump;

    assign pc_use_offset = valid_store;

    assign forward_address = phase[2] & (valid_load | valid_store) ;

// Input/Output and interface Pads
    assign input_buffer_write = phase[2] & valid_load;
    assign input_buffer_read = phase[1] & last_load;

    assign pad_read = phase[1] | input_buffer_write;
    assign pad_write = phase[2] & valid_store;
    assign pad_data_size = {current_instruction[13], current_instruction[13] | current_instruction[12]};
//********************************************************************************************************************//
// registers update
    always @(posedge clock) begin
        if (reset) begin
            next_instruction_reg <= 32'h00000013;
            current_instruction <= 32'h00000013;

            unconditional_jump <= 0;
            pc_relative <= 0;
            branch <= 0;

            use_immediate <= 0;
            op_function <= 5'b0;

            alu_use_pc <= 0;
            load_upper_immediate <= 0;

            store <= 0;
            load <= 0;

            write_c <= 0;

            immediate <= 32'b0;

            last_load <= 0;
            last_c_address <= 5'b0;
            data_type <= 3'b0;
        end
        else if (phase[1]) begin
            next_instruction_reg <= data_in;
        end
        else if (phase[2]) begin
            current_instruction <= next_instruction;

            unconditional_jump <= next_jump_and_link | next_jump_and_link_register;
            pc_relative <= next_branch | next_jump_and_link;
            branch <= next_branch;

            use_immediate <= next_add_upper_immediate_pc | next_immediate;
            op_function <= next_operation ? {next_funct_7[5], next_funct_7[1], next_funct_3} : 5'h10;

            alu_use_pc <= next_add_upper_immediate_pc;
            load_upper_immediate <= next_load_upper_immediate;

            store <= next_store;
            load <= next_load;

            write_c <= (next_system | next_jump_and_link_register | next_jump_and_link |
                next_operation | next_add_upper_immediate_pc | next_load_upper_immediate);

            immediate <=
                next_add_upper_immediate_pc | next_load_upper_immediate ? {next_instruction[31:12], 12'b0} :
                next_jump_and_link ? {{12{next_instruction[31]}}, next_instruction[19:12], next_instruction[20], next_instruction[30:21], 1'b0} :
                next_branch ? {{20{next_instruction[31]}}, next_instruction[7], next_instruction[30:25], next_instruction[11:8], 1'b0} :
                next_store ? {{20{next_instruction[31]}}, next_instruction[31:25], next_instruction[11:7]} :
                {{20{next_instruction[31]}}, next_instruction[31:20]};

            last_load <= valid_load;
            last_c_address <= current_instruction[11:7];
            data_type <= current_instruction[14:12];
        end
    end
endmodule

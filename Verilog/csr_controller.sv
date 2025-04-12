`include "csr_defines.sv"
`timescale 1s/1s

module csr_controller(
    input clock,
    input reset,
    input [2:1] phase,

    //interface with internal busses
    input pad_external_interrupt,
    input pad_timer_interrupt,
    input pad_software_interrupt,

    //used so we don't have to decode the instruction again
    //its ordered by the opcode ascending
    input [9:0] current_decoded_instruction,
    input [31:0] current_instruction,

    input [31:0] a_bus,
    input [31:0] current_pc,

    input [31:0] calculated_address,//TODO find a better name
    input pc_jump,

    output system_load,
    output read_csr,
    output reg [31:0] c_bus,
    output system_jump,
    output logic [31:0] system_address_target

);
    wire load = current_decoded_instruction[0];
    wire store = current_decoded_instruction[3];
    wire branch = current_decoded_instruction[6];
    wire jump_and_link_register = current_decoded_instruction[7];
    wire jump_and_link = current_decoded_instruction[8];
    wire system = current_decoded_instruction[9];

    wire illegal_instruction = ~|current_decoded_instruction || 
            (system && ((funct_3[1:0] != 2'h0 && illegal_csr) ||
                        (funct_3 == 3'h0 && illegal_system)));

    
    wire write_read_csr = system && funct_3[1:0] != 2'h0;
    assign read_csr = write_read_csr && !illegal_csr;

    logic illegal_system;
    logic illegal_csr;
    logic misaligned_data = (|calculated_address[1:0] & current_instruction[13]) |  //offset != 0 & data_size == word
                            (&calculated_address[1:0] & |current_instruction[13:12]);//offset == 3 & data_size >= half

    always @ * begin
        case(funct_12)
            `M_VENDOR_ID, `M_ARCH_ID, `M_IMP_ID, `M_HART_ID, `M_STATUS, `M_ISA,
            `M_T_VEC, `M_STATUS_H, `M_SCRATCH, `M_E_PC, `M_CAUSE, `M_T_VAL, `CYCLE,
            `TIME, `INSTRET, `CYCLE_H, `TIME_H, `INSTRET_H, `M_I_E, `M_I_P: begin
                if(!funct_12[8] | privilege) illegal_csr = 0;
                else illegal_csr = 1;
            end
            default: illegal_csr = 1;
        endcase
        if(funct_3 == 3'h0) begin
            case(funct_12)
                `ECALL, `EBREAK, `MRET, `WFI: illegal_system = 0;
                default: illegal_system = 1;
            endcase
        end
        else illegal_system = 0;
    end

    wire [2:0]funct_3 = current_instruction[14:12];
    wire [11:0]funct_12 = current_instruction[31:20];

    reg privilege = 1'b1;// 1 for machine mode, 0 for user mode

    wire [11:0] csr_address = funct_12;
    wire [31:0] csr_input = funct_3[2] ? {27'h0, current_instruction[19:15]} : a_bus;

// Machine Instruction Set Register(misa)
    reg [31:0] misa_reg = `MISA_E | `MISA_I | `MISA_M | `MISA_U | `MISA_32BIT_MXL;
    //the last part copies the I extension bit into the E extension bit 
    wire [31:0] misa_masked_input = csr_input & `MISA_MASK | {27'b0, csr_input[8], 4'b0};

// Machine status register (mstatus_reg) and Machine status register high (mstatush_reg)
    wire [31:0] mstatus_reg = {19'h0, {2{previous_privilege}}, 3'h0, previous_interrupt_enabled, 3'h0, interrupt_enabled, 3'h0};    
    wire [31:0] mstatush_reg = 32'h0;

    reg interrupt_enabled = 0;//mie
    reg previous_interrupt_enabled = 0;//mpie
    reg previous_privilege = 0;//mpp //implemented as 1 bit since surpevisor mode is not implemented

// Machine Trap-Vector Base-Address Register (mtvec)
    reg [29:0] mtvec_reg = `M_T_VEC_BASE;
    reg [1:0] mtvec_mode = `M_T_VEC_VECTORED;

// Machine Interrupt-Pending and Interrupt-Enable Registers
    wire [31:0] mip_reg = {20'h0, external_interrupt_pendent, 3'h0, timer_interrupt_pendent, 3'h0, software_interrupt_pendent, 3'h0};

    wire software_interrupt_pendent = pad_software_interrupt;
    wire timer_interrupt_pendent = pad_timer_interrupt;
    wire external_interrupt_pendent = pad_external_interrupt;

    wire [31:0] mie_reg = {20'h0, external_interrupt_enabled, 3'h0, timer_interrupt_enabled, 3'h0, software_interrupt_enabled, 3'h0};

    reg software_interrupt_enabled = 0;
    reg timer_interrupt_enabled = 0;
    reg external_interrupt_enabled = 0;

// Machine Scratch
    reg [31:0] mscratch_reg = 32'h0;

// Machine exception program counter
    reg [29:0] mepc_reg = 30'h0;

// Machine cause  //implemented values are with interrupts 3,7,11; without interrupts 0,2,3,4,6,8,11. if PMP is implemented add 1,5,7
    reg [4:0] mcause_reg = 5'h0;
    reg mcause_interrupt = 0;

// Machine Trap Value
    reg [31:0] mtval_reg = 32'h0;

    logic interrupt = 0;
    logic exception = 0;
    logic [31:0] trap_value;
    logic [5:0] trap_cause;

// machine cycle and instructions retired
    reg [63:0] mcycle = 64'h0;
    reg [63:0] minstret = 64'h0;

//System instructions and exceptions
    assign system_jump = phase[2] & (exception | interrupt | (system & funct_3 == 0 & funct_12 == `MRET));
    assign system_load = write_read_csr && (funct_12 == `TIME || funct_12 == `TIME_H);
    //exception and trap calculations.
    always @ * begin
        interrupt = 0;
        exception = 0;
        trap_cause = 6'h0;
        trap_value = 32'h0;        
        system_address_target = system_load ? (funct_12 == `TIME ? 32'h81000000 : 32'h81000004) : {mepc_reg, 2'h0};

        if(interrupt_enabled || privilege == `USER_MODE) begin
            if (external_interrupt_pendent && external_interrupt_enabled) begin                  
                interrupt = 1;
                trap_cause = `MACHINE_EXTERNAL_INTERRUPT;
                trap_value = 32'h0;
            end
            else if(software_interrupt_pendent && software_interrupt_enabled) begin
                interrupt = 1;
                trap_cause = `MACHINE_SOFTWARE_INTERRUPT;
                trap_value = 32'h0;
            end
            else if(timer_interrupt_pendent && timer_interrupt_enabled) begin
                interrupt = 1;
                trap_cause = `MACHINE_TIMER_INTERRUPT;
                trap_value = 32'h0;
            end
        end  

        if(interrupt) system_address_target = {mtvec_reg[29:0] + (mtvec_reg[0] == 0 ? 29'b0 : {25'b0, trap_cause[4:0]}), 2'h0};
        else if(illegal_instruction) begin
            exception = 1;
            trap_cause = `ILLEGAL_INSTRUCTION;
            trap_value = current_instruction;
        end
        else if(calculated_address[1:0] != 2'b0 && (jump_and_link || jump_and_link_register || (branch && pc_jump))) begin
            exception = 1;
            trap_cause = `INSTRUCTION_ADDRESS_MISALIGNED;
            trap_value = calculated_address;
        end
        else if (system && funct_3 == 0) begin
            case(funct_12)
                `MRET: begin                    
                    system_address_target = {mepc_reg, 2'h0};
                end
                `EBREAK: begin
                    exception = 1;
                    trap_cause = `BREAKPOINT;
                    trap_value = 32'h0;
                end
                `ECALL: begin
                    exception = 1; 
                    trap_cause = privilege ? `ECALL_FROM_MACHINE_MODE: `ECALL_FROM_USER_MODE;
                    trap_value = 32'h0;
                end
                default: begin end
            endcase
        end
        else if(misaligned_data && load) begin
            exception = 1;
            trap_cause = `LOAD_ADDRESS_MISALIGNED;
            trap_value = calculated_address;
        end
        else if(misaligned_data && store)  begin
            exception = 1;
            trap_cause = `STORE_ADDRESS_MISALIGNED;
            trap_value = calculated_address;
        end
        
        if(exception) system_address_target = {mtvec_reg[29:0], 2'h0};
    end
    
    //exceptions, interrupts and instructions execution
    always @(posedge clock) begin
        if (reset) begin
            c_bus <= 32'h0;
            misa_reg <= `MISA_MASK;
            {mtvec_reg,mtvec_mode} <= 32'h80000001;
            mscratch_reg <= 32'h0;
            mepc_reg <= 30'h0;
            mcause_reg <= 5'h0;
            mcause_interrupt <= 0;
            mtval_reg <= 32'h0;
            //mie
            software_interrupt_enabled <= 0;
            timer_interrupt_enabled <= 0;
            external_interrupt_enabled <= 0;
            //mstatus_reg
            interrupt_enabled <= 0;
            previous_interrupt_enabled <= 0;
            previous_privilege <= 0;
            //time
            mcycle <= 64'h0;
            minstret <= 64'h0;
        end
        else if(phase[2]) begin 
            if((interrupt | exception )) begin
                previous_interrupt_enabled <= interrupt_enabled;
                interrupt_enabled <= 0;
                previous_privilege <= privilege;
                privilege <= `MACHINE_MODE;
                mepc_reg <= current_pc[31:2];
                {mcause_interrupt, mcause_reg} <= trap_cause;
                mtval_reg <= trap_value;
            end
            else if (system && funct_12 == `MRET && funct_3 == 0) begin
                interrupt_enabled <= previous_interrupt_enabled;
                privilege <= previous_privilege;
                previous_privilege <= 0;
                previous_interrupt_enabled <= 1;
            end
            else if(write_read_csr && !illegal_csr) begin
                case (csr_address)
                //Machine Mode CSRs                  
                    //Machine trap setup
                    `M_ISA: begin
                        misa_reg <= calculate_csr(misa_reg, misa_masked_input);
                    end
                    `M_I_E: begin
                        {software_interrupt_enabled, timer_interrupt_enabled, external_interrupt_enabled} 
                            <= calculate_csr({software_interrupt_enabled, timer_interrupt_enabled, external_interrupt_enabled}, 
                                {csr_input[3],csr_input[7],csr_input[11]});
                    end
                    `M_T_VEC: begin 
                        {mtvec_reg, mtvec_mode} <= calculate_csr({mtvec_reg, mtvec_mode}, csr_input);
                    end
                    //machine trap handling
                    `M_STATUS: begin
                        {previous_privilege, previous_interrupt_enabled, interrupt_enabled}
                            <= calculate_csr({previous_privilege, previous_interrupt_enabled, interrupt_enabled},
                                {csr_input[12], csr_input[7], csr_input[3]}
                            );
                    end
                    `M_SCRATCH: begin
                        mscratch_reg <= calculate_csr(mscratch_reg, csr_input);
                    end
                    `M_E_PC: begin
                        {mepc_reg} <= calculate_csr({mepc_reg}, csr_input[31:2]);
                    end
                    `M_CAUSE: begin
                        {mcause_interrupt, mcause_reg} <= calculate_csr({mcause_interrupt, mcause_reg}, {csr_input[31], csr_input[4:0]});
                    end
                    `M_T_VAL: begin
                        mtval_reg <= calculate_csr(mtval_reg, csr_input);
                    end            
                    default: begin end
                endcase
            end

            if (!exception) begin
                minstret <= minstret + 1;
            end
        end       
        else if(phase[1] && write_read_csr && !illegal_csr) begin
            case (csr_address)
            //Machine Mode CSRs 
                //Machine information registers
                `M_VENDOR_ID: c_bus <= 32'hA_F00_1D;//A Foo ID
                `M_ARCH_ID: c_bus <= 32'h0;//no architecture specified
                `M_IMP_ID: c_bus <= 32'h4;//version 4
                `M_HART_ID: c_bus <= 32'h0;//hart(processor core) id 0                
                //Machine trap setup
                `M_STATUS: c_bus <= mstatus_reg;
                `M_ISA: c_bus <= misa_reg;
                `M_I_E: c_bus <= mie_reg;
                `M_T_VEC: c_bus <= {mtvec_reg, mtvec_mode};
                `M_STATUS_H: c_bus <= mstatush_reg;                
                //machine trap handling
                `M_SCRATCH:c_bus <= mscratch_reg;
                `M_E_PC:c_bus <= {mepc_reg, 2'h0};
                `M_CAUSE: c_bus <= {mcause_interrupt, 26'h0, mcause_reg};
                `M_T_VAL: c_bus <= mtval_reg;
                `M_I_P: c_bus <= mip_reg;
            //Zicntr Extension for Base Counters and Timers
                `CYCLE: c_bus <= mcycle[31:0];//cycle low
                `TIME: c_bus <= 32'b0;//time low //its implemented as a load instruction so cbus doesn't need to be set
                `INSTRET: c_bus <= minstret[31:0];//instructions retired low
                `CYCLE_H: c_bus <= mcycle[63:32];//cycle high
                `TIME_H: c_bus <= 32'b0;//time high
                `INSTRET_H: c_bus <= minstret[63:32];//instructions retired high
           
                default: begin end
            endcase        
        end

        if(!reset) begin
            mcycle <= mcycle + 1;
        end
    end
    
    function logic[31:0] calculate_csr(input[31:0] register, input[31:0] data);
        case (funct_3[1:0])
            2'h1: begin//write
                calculate_csr = data;
            end
            2'h2: begin//set
                calculate_csr = register | data;
            end
            2'h3: begin//clear
                calculate_csr = register & ~data;
            end
            default:;//do nothing
        endcase
    endfunction
endmodule
`include "csr_controller.sv"
`timescale 1s/1s
module tb_csr_controller();
    reg clock;
    reg [2:1] phase;
    reg reset;
    reg pad_external_interrupt;
    reg pad_timer_interrupt;
    reg pad_software_interrupt;
    reg [31:0] a_bus;
    reg [31:0] current_pc;
    wire [31:0] system_jump_target;
    reg [31:0] calculated_address;
    reg pc_jump;
    reg [1:0] data_offset;
    wire [31:0] c_bus;
    reg [31:0] current_instruction;
    logic [9:0] current_decoded_instruction;
    wire load_time;
    wire load_time_h;
    wire read_csr;
    wire system_jump;

    logic [63:0] time_f;
    initial begin        
        forever #1 time_f = $time;
    end

    csr_controller dut (.*);

    // Clock generation
    initial begin
        clock = 0;
        forever #1 clock = ~clock;
    end

    // Phase generation
    initial begin
        phase = 2'b01;
        forever begin
            @(posedge clock);
            phase <= (phase == 2'b01) ? 2'b10 : 2'b01;
        end
    end

    // Test sequence
    initial begin
        $dumpfile("tb_csr_controller.vcd");
        $dumpvars(0, tb_csr_controller);
        
        initialize();
        test_reset_values();
        test_csr_operations();
        test_trap_handling();
        test_privilege_modes();
        $display("All tests completed successfully");
        $finish;
    end

    task initialize();
        reset = 0;
        pad_external_interrupt = 0;
        pad_timer_interrupt = 0;
        pad_software_interrupt = 0;
        a_bus = 0;
        current_pc = 0;
        calculated_address = 0;
        pc_jump = 0;
        data_offset = 0;
        current_instruction = 0;
        current_decoded_instruction = 1;
        #10;
    endtask

    task test_reset_values();
        $display("Testing reset values...");
        reset = 1;
        @(posedge clock);
        reset = 0;
        
        // Verify all CSRs after reset
        assert_csr(`M_VENDOR_ID, 32'hA_F00_1D);       // Vendor ID
        assert_csr(`M_ARCH_ID, 32'h0);                // Architecture ID
        assert_csr(`M_IMP_ID, 32'h3);                 // Implementation ID
        assert_csr(`M_HART_ID, 32'h0);                // Hart ID
        assert_csr(`M_STATUS, 32'h0);                 // Machine Status
        assert_csr(`M_ISA, `MISA_MASK);               // ISA Extensions
        assert_csr(`M_I_E, 32'h0);            // Interrupt Enable
        assert_csr(`M_T_VEC, {`M_T_VEC_BASE, `M_T_VEC_VECTORED});  // Trap Vector
        assert_csr(`M_STATUS_H, 32'h0);               // Status High
        assert_csr(`M_SCRATCH, 32'h0);                // Scratch Register
        assert_csr(`M_E_PC, 32'h0);                   // Exception PC
        assert_csr(`M_CAUSE, 32'h0);                  // Trap Cause
        assert_csr(`M_T_VAL, 32'h0);                  // Trap Value
        assert_csr(`M_I_P, 32'h0);                    // Interrupt Pending
        assert_csr(`CYCLE, 32'h00000040);             // Cycle Counter
        assert_csr(`CYCLE, 32'h00000044);             // Cycle Counter
        assert_csr(`TIME, 32'h0);                     // Time Counter
        assert_csr(`INSTRET, 32'h00000026);           // Instruction Retired Counter
        assert_csr(`INSTRET, 32'h00000028);           // Instruction Retired Counter
        $display("\033[1;32mAll reset values verified successfully\033[0m");
    endtask

    task test_csr_operations();
        $display("\nTesting CSR operations...");
        
        // 1. Test MSCRATCH (RW)
        write_csr(`M_SCRATCH, 32'hDEADBEEF);
        assert_csr(`M_SCRATCH, 32'hDEADBEEF);
        
        // 2. Test MTVEC (RW)
        write_csr(`M_T_VEC, {30'h12345678, 2'b11});
        assert_csr(`M_T_VEC, {30'h12345678, 2'b11});

        // 3. Test MEPC (RW)
        write_csr(`M_E_PC, 32'h89ABCDEF);
        assert_csr(`M_E_PC, 32'h89ABCDEC);

        // 4. Test MCAUSE (RW)
        write_csr(`M_CAUSE, 32'hFFFFFFFF);
        assert_csr(`M_CAUSE, 32'h8000001F);

        // 5. Test MTVAL (RW)
        write_csr(`M_T_VAL, 32'hBAD1DEA);
        assert_csr(`M_T_VAL, 32'hBAD1DEA);

        // 6. Test MIE (RW)
        write_csr(`M_I_E, 32'h0000_0FFF);  // Try to set all interrupt enables
        assert_csr(`M_I_E, 32'h0000_0888); // Only bits 11,7,3 are writable

        // 7. Test MISA (RW with mask)
        write_csr(`M_ISA, 32'hFFFF_FFFF);  // Attempt full write
        assert_csr(`M_ISA, (`MISA_MASK | 32'h0000_0010));  // Expect mask + E bit

        $display("\033[1;32mAll CSR operations verified successfully\033[0m");
    endtask

    task test_trap_handling();
        $display("\nTesting trap priorities and handling...");
        
        // Enable global interrupts and all interrupt types
        write_csr(`M_STATUS, 32'h8);          // Set MIE in mstatus
        write_csr(`M_I_E, 32'h0000_0FFF);     // Attempt to enable all interrupts
        write_csr(`M_T_VEC, {30'h10000000, 2'b11});  // Set up vector table

        // Test 1: Interrupt priority (External > Software > Timer)
        $display("Testing interrupt priorities...");
        force_interrupts(3'b111);
        check_next_trap(`MACHINE_EXTERNAL_INTERRUPT);       
        force_interrupts(3'b010); // Set timer interrupt
        check_next_trap(`MACHINE_TIMER_INTERRUPT);            
        force_interrupts(3'b110); // Set software interrupt
        check_next_trap(`MACHINE_SOFTWARE_INTERRUPT);      
        release_interrupts();        

        // Test 2: Interrupts take priority over exceptions
        $display("\nTesting interrupt vs exception priority...");
        trigger_illegal_instruction();
        force_interrupts(3'b001); // Set external interrupt
        check_next_trap(`MACHINE_EXTERNAL_INTERRUPT);
        check_next_trap(`ILLEGAL_INSTRUCTION);
        release_interrupts();

        // Test 3: Exception priorities                
        current_decoded_instruction = 10'b0000000000;//Invalid instruction
        calculated_address = 32'h00000003;  // Misaligned target

        $display("\nTesting exception priorities...");
        check_next_trap(`ILLEGAL_INSTRUCTION);
        current_decoded_instruction = 10'b0010000000;//pc_jump
        check_next_trap(`INSTRUCTION_ADDRESS_MISALIGNED);
        calculated_address = 32'h00000000; //valid address              
        current_decoded_instruction = 10'b1000000000;//system    
        current_instruction = {`EBREAK, 5'b0, 3'b000, 5'b0, 7'h73}; // ebreak instruction
        check_next_trap(`BREAKPOINT);                         
        current_instruction = {`ECALL, 5'b0, 3'b000, 5'b0, 7'h73}; // ecall instruction
        check_next_trap(`ECALL_FROM_MACHINE_MODE);

        // Test 4: Store/load misalignment priority
        $display("\nTesting memory access exceptions...");
        trigger_store_misalignment();
        check_next_trap(`STORE_ADDRESS_MISALIGNED);        
        trigger_load_misalignment();
        check_next_trap(`LOAD_ADDRESS_MISALIGNED);

        $display("\033[1;32mAll trap priorities verified successfully\033[0m");
    endtask

    task test_privilege_modes();
        $display("\nTesting privilege modes...");
        resetToUserMode();
        // Test 1: User mode
        if(dut.privilege !== `USER_MODE) begin
            $display("\033[1;31mPrivilege mode not set to USER_MODE after reset\033[0m");
        end
        else begin
            $display("\033[1;32mPrivilege mode set to USER_MODE after reset\033[0m");
        end
        
        // test 2: trying to access to machine csrs
        assert_csr(`M_VENDOR_ID, 32'h00000000);       // Vendor ID

        resetToUserMode();
        setup_csr_read(`M_VENDOR_ID);
        #1
        if(read_csr) begin
            $display("\033[1;31mUser mode can access to machine csrs\033[0m");
        end
        else begin
            $display("\033[1;32mUser mode can't access to machine csrs\033[0m");
        end
        
        setup_csr_write(`M_SCRATCH, 32'hDEADBEEF);
        wait_phase_edge(2'b10);
        if (c_bus !== 32'b0) begin
            $display("[%0d]\033[1;31mCSR %h mismatch, changed when shouldn't: Actual: %h != Expected: %h\033[0m", 
                $time,  `M_SCRATCH,, c_bus, 32'b0);
        end
        else begin
            $display("\033[1;32mCSR %h check passed, didn't write in user mode: Received: %h\033[0m", `M_SCRATCH, c_bus);
        end

    endtask

    task resetToUserMode();
        initialize();
        @(posedge clock);
        reset = 1;
        @(posedge clock);
        reset = 0;
        execute_mret();
        #1;
    endtask


    task check_next_trap(input [5:0] cause);
        wait_phase_edge(2'b10);
        wait_phase_edge(2'b01);   
        // Check trap cause first
        if ({dut.mcause_interrupt, dut.mcause_reg} !== cause) begin
            $display("[%0d]\033[1;31mTrap priority failed: Expected %s(%h) got %s(%h)\033[0m", $time,
                  cause[5] ? "interrupt" : "exception", cause[4:0],
                  dut.mcause_interrupt ? "interrupt" : "exception", dut.mcause_reg);
        end
        else begin
            $display("\033[1;32mTrap cause %h verified successfully\033[0m", cause);
        end
        // Check privilege mode
        if (dut.privilege !== `MACHINE_MODE) begin
            $display("\033[1;31mPrivilege mode not set to MACHINE_MODE\033[0m");
        end
        else begin
            $display("\033[1;32mPrivilege mode set to MACHINE_MODE\033[0m");
        end
        
        // Return from trap using MRET
        execute_mret();
        
        // Verify privilege mode restoration
        if (dut.privilege !== `MACHINE_MODE) begin
            $display("\033[1;31mMRET failed to restore privilege mode\033[0m");
        end
        else begin
            $display("\033[1;32mPrivilege mode restored successfully\033[0m");
        end
        
        // Additional verification
        $display("[INFO] Mstatus final value after trap handle = %h\n", dut.mstatus_reg);
    endtask
    
    // Helper tasks
    
    // Core assertion task with strict phase synchronization
    task assert_csr(input [11:0] addr, input [31:0] expected);
        // Start at phase 2 clock edge
        wait_phase_edge(2'b10);
        setup_csr_read(addr);
        
        // Wait for phase 1 update
        wait_phase_edge(2'b10);
        if (c_bus !== expected) begin
            $display("[%0d]\033[1;31mCSR %h mismatch: Actual: %h != Expected: %h\033[0m", 
                $time,  addr, c_bus, expected);
        end
        else begin
            $display("\033[1;32mCSR %h check passed: Received: %h\033[0m", addr, c_bus);
        end
    endtask

    task write_csr(input [11:0] addr, input [31:0] data);
        // Start at phase 2 clock edge
        wait_phase_edge(2'b10);
        setup_csr_write(addr, data);
        
        // Wait for phase 1 -> phase 2 transition
        wait_phase_edge(2'b10);
    endtask

    task setup_csr_read(input [11:0] addr);
        current_instruction = {addr, 5'b0, 3'b010, 5'b0, 7'h73};
        current_decoded_instruction = 10'b1000000000;
        a_bus = 0;
    endtask

    task setup_csr_write(input [11:0] addr, input [31:0] data);
        current_instruction = {addr, 5'b0, 3'b001, 5'b0, 7'h73};
        current_decoded_instruction = 10'b1000000000;
        a_bus = data;
    endtask

    task wait_phase_edge(input [2:1] desired_phase);
        if(phase === desired_phase) begin
            @(posedge clock);
            @(posedge clock);
        end
        else @(posedge clock);
    endtask

    task wait_phase_cycle(input [2:1] start_phase, input int cycles);
        wait_phase_edge(start_phase);
        repeat (cycles) @(posedge clock);
    endtask
    
    task trigger_illegal_instruction();
        current_instruction = 32'h00000000; // Invalid opcode
        current_decoded_instruction = 10'b0000000000;
        @(posedge clock);
    endtask

    task trigger_store_misalignment();
        calculated_address = 32'h00000001;
        current_decoded_instruction = 10'b0000001000; // Store instruction
        @(posedge clock);
    endtask

    task trigger_load_misalignment();
        calculated_address = 32'h00000001;
        current_decoded_instruction = 10'b0000000001; // Load instruction
        @(posedge clock);
    endtask

    task execute_mret();
        wait_phase_edge(2'b10); 
        release_interrupts();
        wait_phase_edge(2'b10); 
        current_instruction = {`MRET, 5'b0, 3'b000, 5'b0, 7'h73};
        current_decoded_instruction = 10'b1000000000;
        
        wait_phase_edge(2'b10);
    endtask
    
    task force_interrupts(input [2:0] int_mask);
        pad_software_interrupt= int_mask[2];
        pad_timer_interrupt = int_mask[1];
        pad_external_interrupt = int_mask[0];  // External interrupt
    endtask

    task release_interrupts();
        pad_software_interrupt = 0;
        pad_timer_interrupt = 0;
        pad_external_interrupt = 0;
    endtask


endmodule
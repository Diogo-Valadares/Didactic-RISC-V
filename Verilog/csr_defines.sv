`define ECALL 12'h001
`define EBREAK 12'h000
`define MRET 12'h302
`define WFI 12'h105

//`define F_FLAGS 12'h001
//`define F_R_M 12'h002
//`define F_CSR 12'h003
`define M_VENDOR_ID 12'hF11
`define M_ARCH_ID 12'hF12
`define M_IMP_ID 12'hF13
`define M_HART_ID 12'hF14
`define M_STATUS 12'h300
`define M_ISA 12'h301
`define M_I_E 12'h304
`define M_T_VEC 12'h305
`define M_STATUS_H 12'h310
`define M_SCRATCH 12'h340
`define M_E_PC 12'h341
`define M_CAUSE 12'h342
`define M_T_VAL 12'h343
`define M_I_P 12'h344
`define CYCLE 12'hC00
`define TIME 12'hC01
`define INSTRET 12'hC02
`define CYCLE_H 12'hC80
`define TIME_H 12'hC81
`define INSTRET_H 12'hC82

`define USER_MODE 1'b0
`define MACHINE_MODE 1'b1

`define MACHINE_SOFTWARE_INTERRUPT 6'h23
`define MACHINE_TIMER_INTERRUPT 6'h27
`define MACHINE_EXTERNAL_INTERRUPT 6'h2b

`define INSTRUCTION_ADDRESS_MISALIGNED 6'h0
`define ILLEGAL_INSTRUCTION 6'h2
`define BREAKPOINT 6'h3
`define LOAD_ADDRESS_MISALIGNED 6'h4
`define STORE_ADDRESS_MISALIGNED 6'h6
`define ECALL_FROM_USER_MODE 6'h8
`define ECALL_FROM_MACHINE_MODE 6'hb

`define MISA_E 32'b10000
//`define MISA_F 32'b100000
`define MISA_I 32'b100000000
`define MISA_M 32'b1000000000000
`define MISA_U 32'b100000000000000000000
`define MISA_32BIT_MXL 32'h40000000
`define MISA_MASK 32'h40101110

`define F_OFF 2'b00
`define F_INITIAL 2'b01
`define F_DIRTY 2'b10
`define F_CLEAN 2'b11

`define M_T_VEC_BASE 30'h20000000
`define M_T_VEC_VECTORED 2'b01
`define M_T_VEC_DIRECT 2'b00

//interrupt handling
//                  Traps  
//                /       \  
//         Exceptions    Interrupts  
//       (Synchronous)  (Asynchronous)
//        /    |    \       /    \  
//    Faults Traps Aborts  Timer  External  
// (fixable)(forced)(unfixable)
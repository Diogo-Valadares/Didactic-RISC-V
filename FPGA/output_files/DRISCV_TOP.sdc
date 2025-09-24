# Clock constraints
create_clock -name CLOCK_50 -period 20.000 [get_ports CLOCK_50]

# 1 MHz clock on clk_div.c0
create_generated_clock -name clk_1_MHz -source [get_ports {CLOCK_50}] -divide_by 50 [get_nets {clk_div|altpll_component|auto_generated|pll1~OBSERVABLE_VCO_OUT}]


# Clock uncertainty
set_clock_uncertainty -to CLOCK_50 -setup 0.500
set_clock_uncertainty -to CLOCK_50 -hold 0.200
set_clock_uncertainty -to [get_clocks clk_1_MHz] -setup 0.500 
set_clock_uncertainty -to [get_clocks clk_1_MHz] -hold  0.200 


# Input delays (excluding clock)
set_input_delay -clock CLOCK_50 -max 5.000 [get_ports {UART_RXD PS2_CLK PS2_DAT IRDA_RXD KEY[*] SDRAM_DQ[*] I2C_SDA SDA}]
set_input_delay -clock CLOCK_50 -min 1.000 [get_ports {UART_RXD PS2_CLK PS2_DAT IRDA_RXD KEY[*] SDRAM_DQ[*] I2C_SDA SDA}]

# Output delays (grouped by timing requirements)
# General outputs
set_output_delay -clock CLOCK_50 -max 5.000 [get_ports {LEDG[*] SEG[*] DIG[*] BEEP UART_TXD SCL I2C_SCL VGA_* LCD_*}]
set_output_delay -clock CLOCK_50 -min 1.000 [get_ports {LEDG[*] SEG[*] DIG[*] BEEP UART_TXD SCL I2C_SCL VGA_* LCD_*}]

# SDRAM control signals (tighter constraints)
set_output_delay -clock CLOCK_50 -max 6.500 [get_ports {SDRAM_A[*] SDRAM_BS0 SDRAM_BS1 SDRAM_LDQM SDRAM_UDQM SDRAM_CKE SDRAM_CS SDRAM_RAS SDRAM_CAS SDRAM_WE}]
set_output_delay -clock CLOCK_50 -min -1.500 [get_ports {SDRAM_A[*] SDRAM_BS0 SDRAM_BS1 SDRAM_LDQM SDRAM_UDQM SDRAM_CKE SDRAM_CS SDRAM_RAS SDRAM_CAS SDRAM_WE}]

# SDRAM data output
set_output_delay -clock CLOCK_50 -max 6.500 [get_ports SDRAM_DQ[*]]
set_output_delay -clock CLOCK_50 -min -1.500 [get_ports SDRAM_DQ[*]]

# SDRAM clock output (special handling)
set_output_delay -clock CLOCK_50 -max 8.000 [get_ports SDRAM_CLK]
set_output_delay -clock CLOCK_50 -min -2.000 [get_ports SDRAM_CLK]

# False paths
set_false_path -from [get_ports {UART_RXD PS2_CLK PS2_DAT IRDA_RXD KEY[*]}]
set_false_path -to [get_ports {LEDG[*] SEG[*] DIG[*] BEEP UART_TXD SCL I2C_SCL VGA_* LCD_*}]

# Multicycle paths for SDRAM controller (using hierarchical paths)
set_multicycle_path -setup 4 -to [get_registers {sdram_interface:*|state_reg*}]
set_multicycle_path -hold 3 -to [get_registers {sdram_interface:*|state_reg*}]

# Critical path constraints
set_max_delay -from [get_clocks CLOCK_50] -to [get_registers {sdram_interface:*|state_reg*}] 15.000

# Don’t try to time-analyze the JTAG test-clock
set_false_path -to [get_ports altera_reserved_tdo]
set_false_path -to [get_clocks altera_reserved_tck]
set_false_path -from [get_ports altera_reserved_tdi]
set_false_path -from [get_ports altera_reserved_tms]
set_false_path -from [get_ports altera_reserved_tdo]


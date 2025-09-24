module DRISCV_TOP(
    input          CLOCK_50,	 
	 input          IRDA_RXD,
    input   [4:0]  KEY,
    output  [3:0]  LEDG,
    output  [7:0]  SEG,
    output  [3:0]  DIG,
    output         BEEP
 //   output         UART_TXD,
 //   input          UART_RXD,
 //   output         SCL,
 //   inout          SDA,
 //   output         I2C_SCL,
 //   inout          I2C_SDA,
 //   input          PS2_CLK,
 //   input          PS2_DAT,

 //   output         VGA_HS,
 //   output         VGA_VS,
 //   output         VGA_B,
 //   output         VGA_G,
 //   output         VGA_R,
 //   output         LCD_RS,
 //   output         LCD_RW,
 //   output         LCD_EN,
 //   output  [7:0]  LCD_DATA,
 //   inout  [15:0] SDRAM_DQ,
 //   output  [11:0] SDRAM_A,
 //   output         SDRAM_BS0,
 //   output         SDRAM_BS1,
 //   output         SDRAM_LDQM,
 //   output         SDRAM_UDQM,
 //   output         SDRAM_CKE,
 //   output         SDRAM_CLK,
 //   output         SDRAM_CS,
 //   output         SDRAM_RAS,
 //   output         SDRAM_CAS,
 //   output         SDRAM_WE
);

    parameter ADDR_WIDTH = 12;	 
    parameter CSR_ENABLED = 1;
    parameter CLOCK_FACTOR = 42000;
	 
    (* keep *) wire [31:0] data_bus = write ? data_bus_drisc :
                      read_ram ? ram_data_out :
							 read_timer ? timer_bus:
                      32'h0;
							 
	 (* keep *) wire [31:0] address_bus;
    wire external_interrupt = 0;
    wire timer_interrupt;
    wire software_interrupt;
    wire [31:0] data_bus_drisc, ram_data_out, timer_bus;
							 
    wire [1:0] data_size;
    wire write;
    wire read;
	 reg clock;

	 wire [31:0] current_instruction;


	wire clock2 = CLOCK_50;
	wire hex_display_clock;
   clock_divider clk_div(
		.inclk0(CLOCK_50),
		.c0(hex_display_clock),  //50MHz/42000
		.c1(),     //50MHz/21000
		.c2(clock) //25MHz Clock
	);

	 
//Byte to Word memory interface
	wire[29:0] word_address = address_bus[31:2];	
	logic [3:0] byte_enable;
	
	always @(*) begin
		case (data_size)
        2'b00: byte_enable = 4'b0001 << address_bus[1:0]; // Byte
        2'b01: byte_enable = 4'b0011 << address_bus[1:0]; // Halfword
        2'b11, 2'b10: byte_enable = 4'b1111; // Word
        default: byte_enable = 4'b0000;
		endcase
	end
	
	 wire is_timer_address = (address_bus >= 32'h81000000 && address_bus < 32'h81000010);
    wire read_timer = read && is_timer_address;
    wire write_timer = write && is_timer_address;
	 assign timer_bus = write_timer ? data_bus : 32'hz;
//IO devices
/*	 real_time_clock timer_inst (
        .clock(clock2),
        .reset(reset),
        .read(read_timer),
        .write(write_timer),
        .address(address_bus[3:2]),
        .data(timer_bus),
        .timer_interrupt(timer_interrupt)
    );*/
//Memory	 	 
    wire is_ram_address = (address_bus < 32'h00fffffc);
    wire write_ram = write && is_ram_address;
    wire read_ram = read && is_ram_address;	 

	ram_custom ram_inst (
    .address(word_address[ADDR_WIDTH-3:0]),
    .byteena(byte_enable),
    .clock(clock2),                       
    .data(data_bus << (8 * address_bus[1:0])),                        
    .wren(write_ram),                        
    .q(ram_data_out)                            
	);
	 
//The processor
    drisc #(
        .GENERATE_CSR_CONTROLLER(CSR_ENABLED)
    ) drisc_processor (
        .clock(clock),
        .reset(~KEY[3]),
        .data_bus_in(data_bus),
        .external_interrupt(external_interrupt),
        .timer_interrupt(timer_interrupt),
        .software_interrupt(software_interrupt),
        .data_bus_out(data_bus_drisc),
        .address_bus(address_bus),
        .data_size(data_size),
        .write(write),
        .read(read),
		  .current_instruction(current_instruction)
    );


	wire write_display = write && address_bus == 32'h1100010;

	hex_display_controller disp0 (
		 .clk       (clock),
		 .refresh_clk(hex_display_clock),
		 .write     (write_display),
		 .data_in   (data_bus),
		 .seg       (SEG),
		 .digit_sel (DIG)
	);
	
    // Debug outputs

    assign LEDG = ~{write, read, clock, IRDA_RXD};	 
    assign BEEP = 1'b0;
    
endmodule
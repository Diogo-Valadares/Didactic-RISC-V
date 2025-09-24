module hex_display_controller(
	 input  wire        clk,//
	 input  wire        refresh_clk,//
    input  wire [31:0] data_in,    // data bus input
	 input  wire 		  write,
    output reg  [7:0]  seg,        // {dot, g, f, e, d, c, b, a}
    output reg  [3:0]  digit_sel   // active-low digit enables
);

		
	 wire [31:0] data;
    reg  [1:0] digit_idx;

    // Cycle digit index at REFRESH_DIV → time-multiplex 4 digits
    always @(posedge refresh_clk) begin
        digit_idx  <= digit_idx + 1;
    end

    wire [7:0] current_char = data >> (digit_idx * 8); 

	 always @(posedge clk) if(write) data <= data_in;
	 
    always @(*) begin
        seg = ~ascii_to_7seg(current_char);
        digit_sel = ~(4'b1000 >> digit_idx);
    end
	 
	 function [7:0] ascii_to_7seg;
	
		 input [7:0] val;
		 begin
			  case(val)
					// Control characters (0x00-0x1F)
					8'h00: ascii_to_7seg = 8'b00000000; // NULL
					8'h01: ascii_to_7seg = 8'b00000000; // SOH
					8'h02: ascii_to_7seg = 8'b00000000; // STX
					8'h03: ascii_to_7seg = 8'b00000000; // ETX
					8'h04: ascii_to_7seg = 8'b00000000; // EOT
					8'h05: ascii_to_7seg = 8'b00000000; // ENQ
					8'h06: ascii_to_7seg = 8'b00000000; // ACK
					8'h07: ascii_to_7seg = 8'b00000000; // BEL
					8'h08: ascii_to_7seg = 8'b00000000; // BS
					8'h09: ascii_to_7seg = 8'b00000000; // TAB
					8'h0A: ascii_to_7seg = 8'b00000000; // LF
					8'h0B: ascii_to_7seg = 8'b00000000; // VT
					8'h0C: ascii_to_7seg = 8'b00000000; // FF
					8'h0D: ascii_to_7seg = 8'b00000000; // CR
					8'h0E: ascii_to_7seg = 8'b00000000; // SO
					8'h0F: ascii_to_7seg = 8'b00000000; // SI
					8'h10: ascii_to_7seg = 8'b00000000; // DLE
					8'h11: ascii_to_7seg = 8'b00000000; // DC1
					8'h12: ascii_to_7seg = 8'b00000000; // DC2
					8'h13: ascii_to_7seg = 8'b00000000; // DC3
					8'h14: ascii_to_7seg = 8'b00000000; // DC4
					8'h15: ascii_to_7seg = 8'b00000000; // NAK
					8'h16: ascii_to_7seg = 8'b00000000; // SYN
					8'h17: ascii_to_7seg = 8'b00000000; // ETB
					8'h18: ascii_to_7seg = 8'b00000000; // CAN
					8'h19: ascii_to_7seg = 8'b00000000; // EM
					8'h1A: ascii_to_7seg = 8'b00000000; // SUB
					8'h1B: ascii_to_7seg = 8'b00000000; // ESC
					8'h1C: ascii_to_7seg = 8'b00000000; // FS
					8'h1D: ascii_to_7seg = 8'b00000000; // GS
					8'h1E: ascii_to_7seg = 8'b00000000; // RS
					8'h1F: ascii_to_7seg = 8'b00000000; // US
					
					// Standard ASCII (0x20-0x7E)
					8'h20: ascii_to_7seg = 8'b00000000; // Space
					8'h21: ascii_to_7seg = 8'b10000110; // !
					8'h22: ascii_to_7seg = 8'b00100010; // "
					8'h23: ascii_to_7seg = 8'b01100110; // #
					8'h24: ascii_to_7seg = 8'b01101101; // $
					8'h25: ascii_to_7seg = 8'b01001001; // %
					8'h26: ascii_to_7seg = 8'b01111111; // &
					8'h27: ascii_to_7seg = 8'b00000010; // '
					8'h28,8'h5b,8'h7b: ascii_to_7seg = 8'b00111001; // ( [ {
					8'h29,8'h5D,8'h7D: ascii_to_7seg = 8'b00001111; // ) ] }
					8'h2A: ascii_to_7seg = 8'b01100011; // *
					8'h2B: ascii_to_7seg = 8'b01000000; // +
					8'h2C,8'h2E: ascii_to_7seg = 8'b10000000; // , .
					8'h2D: ascii_to_7seg = 8'b01000000; // -
					8'h2F: ascii_to_7seg = 8'b01010010; // /
					8'h30: ascii_to_7seg = 8'b00111111; // 0
					8'h31: ascii_to_7seg = 8'b00000110; // 1
					8'h32: ascii_to_7seg = 8'b01011011; // 2
					8'h33: ascii_to_7seg = 8'b01001111; // 3
					8'h34: ascii_to_7seg = 8'b01100110; // 4
					8'h35: ascii_to_7seg = 8'b01101101; // 5
					8'h36: ascii_to_7seg = 8'b01111101; // 6
					8'h37: ascii_to_7seg = 8'b00000111; // 7
					8'h38,8'h42: ascii_to_7seg = 8'b01111111; // 8 B
					8'h39: ascii_to_7seg = 8'b01101111; // 9
					8'h3A,8'h3B: ascii_to_7seg = 8'b10000010; // : ;
					8'h3C: ascii_to_7seg = 8'b01100000; // <
					8'h3D: ascii_to_7seg = 8'b01001000; // =
					8'h3E: ascii_to_7seg = 8'b01000010; // >
					8'h3F: ascii_to_7seg = 8'b11010011; // ?
					8'h40: ascii_to_7seg = 8'b01011111; // @
					8'h41: ascii_to_7seg = 8'b01110111; // A
					8'h43: ascii_to_7seg = 8'b00111001; // C
					8'h44: ascii_to_7seg = 8'b01011110; // D
					8'h45: ascii_to_7seg = 8'b01111001; // E
					8'h46: ascii_to_7seg = 8'b01110001; // F
					8'h47: ascii_to_7seg = 8'b00111101; // G
					8'h48: ascii_to_7seg = 8'b01110110; // H
					8'h49: ascii_to_7seg = 8'b00000110; // I
					8'h4A: ascii_to_7seg = 8'b00011110; // J
					8'h4B: ascii_to_7seg = 8'b01110110; // K (same as H)
					8'h4C: ascii_to_7seg = 8'b00111000; // L
					8'h4D: ascii_to_7seg = 8'b00010101; // M
					8'h4E: ascii_to_7seg = 8'b01010100; // N
					8'h4F: ascii_to_7seg = 8'b00111111; // O (same as 0)
					8'h50: ascii_to_7seg = 8'b01110011; // P
					8'h51: ascii_to_7seg = 8'b01100111; // Q
					8'h52: ascii_to_7seg = 8'b01010000; // R
					8'h53: ascii_to_7seg = 8'b01101101; // S (same as 5)
					8'h54: ascii_to_7seg = 8'b01111000; // T
					8'h55: ascii_to_7seg = 8'b00111110; // U
					8'h56: ascii_to_7seg = 8'b00011100; // V
					8'h57: ascii_to_7seg = 8'b00101010; // W
					8'h58: ascii_to_7seg = 8'b01110110; // X (same as H)
					8'h59: ascii_to_7seg = 8'b01101110; // Y
					8'h5A: ascii_to_7seg = 8'b01011011; // Z (same as 2)
					8'h5C: ascii_to_7seg = 8'b00110001; // backslash
					8'h5E: ascii_to_7seg = 8'b01100011; // ^
					8'h5F: ascii_to_7seg = 8'b00001000; // _
					8'h60: ascii_to_7seg = 8'b00000010; // `
					8'h61: ascii_to_7seg = 8'b01110111; // a (same as A)
					8'h62: ascii_to_7seg = 8'b01111100; // b
					8'h63: ascii_to_7seg = 8'b01011000; // c
					8'h64: ascii_to_7seg = 8'b01011110; // d (same as D)
					8'h65: ascii_to_7seg = 8'b01111001; // e (same as E)
					8'h66: ascii_to_7seg = 8'b01110001; // f (same as F)
					8'h67: ascii_to_7seg = 8'b01101111; // g
					8'h68: ascii_to_7seg = 8'b01110100; // h
					8'h69: ascii_to_7seg = 8'b00000100; // i
					8'h6A: ascii_to_7seg = 8'b00001110; // j
					8'h6B: ascii_to_7seg = 8'b01110110; // k (same as H)
					8'h6C: ascii_to_7seg = 8'b00110000; // l
					8'h6D: ascii_to_7seg = 8'b00010100; // m
					8'h6E: ascii_to_7seg = 8'b01010100; // n (same as N)
					8'h6F: ascii_to_7seg = 8'b01011100; // o
					8'h70: ascii_to_7seg = 8'b01110011; // p (same as P)
					8'h71: ascii_to_7seg = 8'b01100111; // q (same as Q)
					8'h72: ascii_to_7seg = 8'b01010000; // r (same as R)
					8'h73: ascii_to_7seg = 8'b01101101; // s (same as S)
					8'h74: ascii_to_7seg = 8'b01111000; // t (same as T)
					8'h75: ascii_to_7seg = 8'b00011100; // u
					8'h76: ascii_to_7seg = 8'b00011100; // v (same as V)
					8'h77: ascii_to_7seg = 8'b00101010; // w (same as W)
					8'h78: ascii_to_7seg = 8'b01110110; // x (same as X)
					8'h79: ascii_to_7seg = 8'b01101110; // y (same as Y)
					8'h7A: ascii_to_7seg = 8'b01011011; // z (same as Z)
					8'h7B: ascii_to_7seg = 8'b00111001; // { (same as ()
					8'h7C: ascii_to_7seg = 8'b00000110; // |
					8'h7D: ascii_to_7seg = 8'b00001111; // } (same as ))
					8'h7E: ascii_to_7seg = 8'b01000000; // ~
					8'h7F: ascii_to_7seg = 8'b00000000; // DEL
					
					// Extended ASCII (0x80-0xFF)
					8'h80: ascii_to_7seg = 8'b11000000; // Ç (C with cedilla)
					8'h81: ascii_to_7seg = 8'b11111001; // ü (u with diaeresis)
					8'h82: ascii_to_7seg = 8'b10100100; // é (e with acute)
					8'h83: ascii_to_7seg = 8'b10110000; // â (a with circumflex)
					8'h84: ascii_to_7seg = 8'b10011001; // ä (a with diaeresis)
					8'h85: ascii_to_7seg = 8'b10001010; // à (a with grave)
					8'h86: ascii_to_7seg = 8'b10000110; // å (a with ring)
					8'h87: ascii_to_7seg = 8'b11001110; // ç (c with cedilla)
					8'h88: ascii_to_7seg = 8'b10100000; // ê (e with circumflex)
					8'h89: ascii_to_7seg = 8'b10010010; // ë (e with diaeresis)
					8'h8A: ascii_to_7seg = 8'b10001000; // è (e with grave)
					8'h8B: ascii_to_7seg = 8'b10010100; // ï (i with diaeresis)
					8'h8C: ascii_to_7seg = 8'b11000110; // î (i with circumflex)
					8'h8D: ascii_to_7seg = 8'b11010000; // ì (i with grave)
					8'h8E: ascii_to_7seg = 8'b10101011; // Ä (A with diaeresis)
					8'h8F: ascii_to_7seg = 8'b10011100; // Å (A with ring)
					8'h90: ascii_to_7seg = 8'b10001110; // É (E with acute)
					8'h91: ascii_to_7seg = 8'b11111000; // æ (ae)
					8'h92: ascii_to_7seg = 8'b11111101; // Æ (AE)
					8'h93: ascii_to_7seg = 8'b10011100; // ô (o with circumflex)
					8'h94: ascii_to_7seg = 8'b10010000; // ö (o with diaeresis)
					8'h95: ascii_to_7seg = 8'b11000000; // ò (o with grave)
					8'h96: ascii_to_7seg = 8'b11110000; // û (u with circumflex)
					8'h97: ascii_to_7seg = 8'b11000000; // ù (u with grave)
					8'h98: ascii_to_7seg = 8'b10001001; // ÿ (y with diaeresis)
					8'h99: ascii_to_7seg = 8'b01101110; // Ö (O with diaeresis)
					8'h9A: ascii_to_7seg = 8'b01111001; // Ü (U with diaeresis)
					8'h9B: ascii_to_7seg = 8'b11000110; // ¢ (cent)
					8'h9C: ascii_to_7seg = 8'b10100011; // £ (pound)
					8'h9D: ascii_to_7seg = 8'b10010001; // ¥ (yen)
					8'h9E: ascii_to_7seg = 8'b01011100; // ₧ (peseta)
					8'h9F: ascii_to_7seg = 8'b01110011; // ƒ (function)
					8'hA0: ascii_to_7seg = 8'b00000000; // (non-breaking space)
					8'hA1: ascii_to_7seg = 8'b10000110; // ¡ (inverted !)
					8'hA2: ascii_to_7seg = 8'b01011110; // ¢ (cent) - alternative
					8'hA3: ascii_to_7seg = 8'b10100011; // £ (pound)
					8'hA4: ascii_to_7seg = 8'b10010001; // ¤ (currency)
					8'hA5: ascii_to_7seg = 8'b10010001; // ¥ (yen)
					8'hA6: ascii_to_7seg = 8'b00000110; // ¦ (broken vertical bar)
					8'hA7: ascii_to_7seg = 8'b01001111; // § (section)
					8'hA8: ascii_to_7seg = 8'b00100010; // ¨ (diaeresis)
					8'hA9: ascii_to_7seg = 8'b01110111; // © (copyright)
					8'hAA: ascii_to_7seg = 8'b00011110; // ª (feminine ordinal)
					8'hAB: ascii_to_7seg = 8'b01100000; // « (left pointing guillemet)
					8'hAC: ascii_to_7seg = 8'b01000000; // ¬ (not sign)
					8'hAD: ascii_to_7seg = 8'b10000000; // ­ (soft hyphen)
					8'hAE: ascii_to_7seg = 8'b01110111; // ® (registered)
					8'hAF: ascii_to_7seg = 8'b01000000; // ¯ (macron)
					8'hB0: ascii_to_7seg = 8'b01100011; // ° (degree)
					8'hB1: ascii_to_7seg = 8'b01000000; // ± (plus-minus)
					8'hB2: ascii_to_7seg = 8'b01011011; // ² (superscript 2)
					8'hB3: ascii_to_7seg = 8'b01001111; // ³ (superscript 3)
					8'hB4: ascii_to_7seg = 8'b00000010; // ´ (acute accent)
					8'hB5: ascii_to_7seg = 8'b01111100; // µ (micro)
					8'hB6: ascii_to_7seg = 8'b01011110; // ¶ (pilcrow)
					8'hB7: ascii_to_7seg = 8'b10000000; // · (middle dot)
					8'hB8: ascii_to_7seg = 8'b00000010; // ¸ (cedilla)
					8'hB9: ascii_to_7seg = 8'b00000110; // ¹ (superscript 1)
					8'hBA: ascii_to_7seg = 8'b00011110; // º (masculine ordinal)
					8'hBB: ascii_to_7seg = 8'b01000010; // » (right pointing guillemet)
					8'hBC: ascii_to_7seg = 8'b01100110; // ¼ (1/4)
					8'hBD: ascii_to_7seg = 8'b01101101; // ½ (1/2)
					8'hBE: ascii_to_7seg = 8'b01111101; // ¾ (3/4)
					8'hBF: ascii_to_7seg = 8'b11010011; // ¿ (inverted ?)
					
					// Uppercase extended
					8'hC0: ascii_to_7seg = 8'b01110111; // À (A with grave)
					8'hC1: ascii_to_7seg = 8'b01110111; // Á (A with acute)
					8'hC2: ascii_to_7seg = 8'b01110111; // Â (A with circumflex)
					8'hC3: ascii_to_7seg = 8'b01110111; // Ã (A with tilde)
					8'hC4: ascii_to_7seg = 8'b01110111; // Ä (A with diaeresis)
					8'hC5: ascii_to_7seg = 8'b01110111; // Å (A with ring)
					8'hC6: ascii_to_7seg = 8'b11111101; // Æ (AE)
					8'hC7: ascii_to_7seg = 8'b00111001; // Ç (C with cedilla)
					8'hC8: ascii_to_7seg = 8'b01111001; // È (E with grave)
					8'hC9: ascii_to_7seg = 8'b01111001; // É (E with acute)
					8'hCA: ascii_to_7seg = 8'b01111001; // Ê (E with circumflex)
					8'hCB: ascii_to_7seg = 8'b01111001; // Ë (E with diaeresis)
					8'hCC: ascii_to_7seg = 8'b00000110; // Ì (I with grave)
					8'hCD: ascii_to_7seg = 8'b00000110; // Í (I with acute)
					8'hCE: ascii_to_7seg = 8'b00000110; // Î (I with circumflex)
					8'hCF: ascii_to_7seg = 8'b00000110; // Ï (I with diaeresis)
					8'hD0: ascii_to_7seg = 8'b01111110; // Ð (Eth)
					8'hD1: ascii_to_7seg = 8'b01010100; // Ñ (N with tilde)
					8'hD2: ascii_to_7seg = 8'b00111111; // Ò (O with grave)
					8'hD3: ascii_to_7seg = 8'b00111111; // Ó (O with acute)
					8'hD4: ascii_to_7seg = 8'b00111111; // Ô (O with circumflex)
					8'hD5: ascii_to_7seg = 8'b00111111; // Õ (O with tilde)
					8'hD6: ascii_to_7seg = 8'b00111111; // Ö (O with diaeresis)
					8'hD7: ascii_to_7seg = 8'b01000000; // × (multiplication)
					8'hD8: ascii_to_7seg = 8'b00111111; // Ø (O with stroke)
					8'hD9: ascii_to_7seg = 8'b00111110; // Ù (U with grave)
					8'hDA: ascii_to_7seg = 8'b00111110; // Ú (U with acute)
					8'hDB: ascii_to_7seg = 8'b00111110; // Û (U with circumflex)
					8'hDC: ascii_to_7seg = 8'b00111110; // Ü (U with diaeresis)
					8'hDD: ascii_to_7seg = 8'b01101110; // Ý (Y with acute)
					8'hDE: ascii_to_7seg = 8'b01110010; // Þ (Thorn)
					8'hDF: ascii_to_7seg = 8'b01111101; // ß (sharp s)
					
					// Lowercase extended
					8'hE0: ascii_to_7seg = 8'b01110111; // à (a with grave)
					8'hE1: ascii_to_7seg = 8'b01110111; // á (a with acute)
					8'hE2: ascii_to_7seg = 8'b01110111; // â (a with circumflex)
					8'hE3: ascii_to_7seg = 8'b01110111; // ã (a with tilde)
					8'hE4: ascii_to_7seg = 8'b01110111; // ä (a with diaeresis)
					8'hE5: ascii_to_7seg = 8'b01110111; // å (a with ring)
					8'hE6: ascii_to_7seg = 8'b11111001; // æ (ae)
					8'hE7: ascii_to_7seg = 8'b01011000; // ç (c with cedilla)
					8'hE8: ascii_to_7seg = 8'b01111001; // è (e with grave)
					8'hE9: ascii_to_7seg = 8'b01111001; // é (e with acute)
					8'hEA: ascii_to_7seg = 8'b01111001; // ê (e with circumflex)
					8'hEB: ascii_to_7seg = 8'b01111001; // ë (e with diaeresis)
					8'hEC: ascii_to_7seg = 8'b00000100; // ì (i with grave)
					8'hED: ascii_to_7seg = 8'b00000100; // í (i with acute)
					8'hEE: ascii_to_7seg = 8'b00000100; // î (i with circumflex)
					8'hEF: ascii_to_7seg = 8'b00000100; // ï (i with diaeresis)
					8'hF0: ascii_to_7seg = 8'b01111101; // ð (eth)
					8'hF1: ascii_to_7seg = 8'b01010100; // ñ (n with tilde)
					8'hF2: ascii_to_7seg = 8'b01011100; // ò (o with grave)
					8'hF3: ascii_to_7seg = 8'b01011100; // ó (o with acute)
					8'hF4: ascii_to_7seg = 8'b01011100; // ô (o with circumflex)
					8'hF5: ascii_to_7seg = 8'b01011100; // õ (o with tilde)
					8'hF6: ascii_to_7seg = 8'b01011100; // ö (o with diaeresis)
					8'hF7: ascii_to_7seg = 8'b01000000; // ÷ (division)
					8'hF8: ascii_to_7seg = 8'b01011100; // ø (o with stroke)
					8'hF9: ascii_to_7seg = 8'b00011100; // ù (u with grave)
					8'hFA: ascii_to_7seg = 8'b00011100; // ú (u with acute)
					8'hFB: ascii_to_7seg = 8'b00011100; // û (u with circumflex)
					8'hFC: ascii_to_7seg = 8'b00011100; // ü (u with diaeresis)
					8'hFD: ascii_to_7seg = 8'b01101110; // ý (y with acute)
					8'hFE: ascii_to_7seg = 8'b01110010; // þ (thorn)
					8'hFF: ascii_to_7seg = 8'b00011100; // ÿ (y with diaeresis)
					
					default: ascii_to_7seg = 8'b00000000; // Default to blank
			  endcase
		 end
	 endfunction
	 
    //--- 7-segment lookup (abcdefg, active-high) ---
    function [6:0] hex_to_7seg;
	 
        input [3:0] h;
        case (h)
            4'h0: hex_to_7seg = 7'b0111111;
            4'h1: hex_to_7seg = 7'b0000110;
            4'h2: hex_to_7seg = 7'b1011011;
            4'h3: hex_to_7seg = 7'b1001111;
            4'h4: hex_to_7seg = 7'b1100110;
            4'h5: hex_to_7seg = 7'b1101101;
            4'h6: hex_to_7seg = 7'b1111101;
            4'h7: hex_to_7seg = 7'b0000111;
            4'h8: hex_to_7seg = 7'b1111111;
            4'h9: hex_to_7seg = 7'b1101111;
            4'hA: hex_to_7seg = 7'b1110111;
            4'hB: hex_to_7seg = 7'b1111100;
            4'hC: hex_to_7seg = 7'b0111001;
            4'hD: hex_to_7seg = 7'b1011110;
            4'hE: hex_to_7seg = 7'b1111001;
            4'hF: hex_to_7seg = 7'b1110001;
            default: hex_to_7seg = 7'b0000000;
        endcase
    endfunction
endmodule
// This VGA renderer is currently configured to display 800x640@65Hz, given a 32.4MHz pixel clock
// These specs are, I think, good to drive the 5" display from Adafruit @ http://www.adafruit.com/products/2110

// Current DAC resistors are:  220+22, 510+22, 1K+68, 1.5K+680, 3.5K+560+100, 6.8K+1.5K+220, 15K+2.2K, 33K+1K+180
// These values require VCCIO bank setting of 3.3V LVTTL; be sure to change the I/O standard for these pins!

// Pin configuration is currently:
// HSYNC - E9 - GPIO_023 - GPIO-0 pin 28 connects to VGA pin 13
// VSYNC - F8 - GPIO_021 - GPIO-0 pin 26 connects to VGA pin 14
// GND - GPIO-0 pin 30 connects to VGA pins 5, 6, 7, 8, and 10.
// RED 0..7  (3.3V LVTTL)
//		D3, C3, A3, B4, B5, A2, B3, A4
//    GPIO_00, GPIO_01, GPIO_03, GPIO_05, GPIO_07, GPIO_02, GPIO_04, GPIO_06
//    GPIO-0 pins 2, 4, 6, 8, 10, 5, 7, 9
// GREEN 0..7  (3.3V LVTTL)
//		D5, A6, D6, C6, E6, B7, A7, C8
//    GPIO_09, GPIO_011, GPIO_013, GPIO_015, GPIO_017, GPIO_012, GPIO_014, GPIO_016
//    GPIO-0 pins 14, 16, 18, 20, 22, 17, 19, 21
// BLUE 0..7  (3.3V LVTTL)
//		D9, E10, B11, D11, B12, C11, A12, D12
//    GPIO_025, GPIO_027, GPIO_029, GPIO_031, GPIO_033, GPIO_028, GPIO_030, GPIO_032
//    GPIO-0 pins 32, 34, 36, 38, 40, 35, 37, 39
//

module vga_renderer
	#(parameter WIDTH = 800,          // Visible horizontal pixels
	            H_FRONT_PORCH = 32,   // hsync timing
					H_SYNC = 120,          // ..
					H_BACK_PORCH = 32,    // ..
					HEIGHT = 480,         // Visible vertical pixels
					V_FRONT_PORCH = 8,   // vsync timing
					V_SYNC = 5,           // ..
					V_BACK_PORCH = 13)    // ..
	(
	 // vga_clk needs to match your monitor and timing specifications
	 input vga_clk,
	 
	 // active low reset
	 input reset_n,
	 
	 // 8 bit color digital inputs
	 input [7:0] red,
	 input [7:0] green,
	 input [7:0] blue,
	 
	 // 8 bit color digital outputs
	 output [7:0] vga_red,
	 output [7:0] vga_green,
	 output [7:0] vga_blue,
	 
	 // vga sync signals
	 output vga_hsync,
	 output vga_vsync,
	 
	 // framebuffer signal - fb_vblank goes high when vsync starts and should be used to setup the frame buffer for the next render pass
	 // and the next pixel should be available every vga_clk when not in blanking (hblank or vblank)
	 // so you have (PIXELS_PER_LINE*(V_BACK_PORCH+V_SYNC+V_FRONT_PORCH)) vga clock cycles to prepare your framebuffer for reading
	 output fb_hblank,
	 output fb_vblank
	);
	
	localparam PIXELS_PER_LINE = WIDTH + H_BACK_PORCH + H_SYNC + H_FRONT_PORCH;
	localparam LINES_PER_FRAME = HEIGHT + V_BACK_PORCH + V_SYNC + V_FRONT_PORCH;
	
	localparam XBITS = $clog2(PIXELS_PER_LINE);
	localparam YBITS = $clog2(LINES_PER_FRAME);
	
	reg [XBITS-1:0] x_pos;
	wire x_max = (x_pos == (PIXELS_PER_LINE - 1));
	
	reg [YBITS-1:0] y_pos;
	wire y_max = (y_pos == (LINES_PER_FRAME - 1));
	
	reg hsync;
	assign vga_hsync = ~hsync;
	
	reg vsync;
	assign vga_vsync = ~vsync;
	
	assign fb_vblank = (y_pos >= HEIGHT);
	assign fb_hblank = (x_pos >= WIDTH);
	
	always @ (posedge vga_clk or negedge reset_n) begin
		if(~reset_n) begin
			x_pos <= 0;
			y_pos <= 0;
			hsync <= 1'b0;
			vsync <= 1'b0;
		end else begin
			if(x_max) begin
				x_pos <= 0;
				if(y_max) begin
					y_pos <= 0;
				end else begin
					y_pos <= y_pos + 1;
				end
			end else begin
				x_pos <= x_pos + 1;
			end
			
			if(x_pos == ((WIDTH + H_FRONT_PORCH) - 1)) hsync <= 1'b1;
			else if(x_pos == ((WIDTH + H_FRONT_PORCH + H_SYNC) - 1)) hsync <= 1'b0;
			
			if(y_pos == ((HEIGHT + V_FRONT_PORCH) - 1)) vsync <= 1'b1;
			else if(y_pos == ((HEIGHT + V_FRONT_PORCH + V_SYNC) - 1)) vsync <= 1'b0;
		end
	end

	assign vga_red = (x_pos < WIDTH && y_pos < HEIGHT) ? red : 8'b0;
	assign vga_green = (x_pos < WIDTH && y_pos < HEIGHT) ? green : 8'b0;
	assign vga_blue = (x_pos < WIDTH && y_pos < HEIGHT) ? blue : 8'b0;
	
endmodule
	 
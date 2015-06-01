
module framebuffer
	(input reset_n,
	 input vga_clk,

	 input next_n,
	 
	 input fb_hblank,
	 input fb_vblank,
	 
	 output reg [7:0] red,
	 output reg [7:0] green,
	 output reg [7:0] blue
	);
	
	reg wait_for_posedge;
	
	reg [7:0] blue_shift;
	
	always @(posedge vga_clk or negedge reset_n or posedge fb_vblank) begin
		if(~reset_n || fb_vblank) begin
			red <= 8'b0000_0000;
			green <= 8'b0000_0000;
			blue <= 8'b0000_0000;
			blue_shift <= 8'b0000_0000;
			wait_for_posedge <= 0;
		end else begin
			if(fb_hblank && ~wait_for_posedge) begin
				// red updates every scanline
				red <= red + 1;
				
				// green resets on scanline
				green <= 8'b0;
				
				// blue resets but at a new value on the scanline
				blue <= blue_shift;
				blue_shift <= blue_shift + 1;
				
				wait_for_posedge <= 1;
			end else if(~fb_hblank && wait_for_posedge) begin
				wait_for_posedge <= 0;
			end
			if(~fb_hblank && ~fb_vblank) begin
				// blue and green step per pixel
				green <= green + 1;
				blue <= blue + 1;
			end
		end
	end
	
	//assign red = (red_counter == 0) ? 8'b0000_0001 : 8'b0;
	//assign green = (green_counter == 0) ? 8'b0000_0001 : 8'b0;
	//assign blue = (blue_counter == 0) ? 8'b0000_0001 : 8'b0;
	//assign red = 8'b0000_0000;
	//assign green = 8'b1;
	//assign blue = 8'b0;
	//assign blue = 8'b0000_0000;
	
endmodule
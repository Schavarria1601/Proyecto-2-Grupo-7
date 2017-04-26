`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2017 14:12:49
// Design Name: 
// Module Name: Top_VGA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Top_VGA(
    input wire clk, rst, RING_on,
    input wire [3:0]sig_band_cursor,
    output wire v_sync, h_sync,
    output wire[11:0] rgb,
    input [7:0] Dir,
    input [7:0] Dato
    );
	 

wire [9:0] pixel_x; 
wire [9:0] pixel_y;
wire video_on; 
wire pixel_tick;
reg  [11:0] rgb_reg;
wire [11:0] rgb_next;
wire [3:0] Unis;
wire [3:0] Decs;


//Instanciacion de funciones principales
Divisor_Frec divisor(
       .clk(clk),
       .reset(reset),
       .SCLKclk(SCLKclk)
       );
       
       wire clk_in;
       assign clk_in = SCLKclk;
       
VGA_Sync Sincronizador(
		.clk_in(clk_in), 
		.reset(reset), 
		.hsync(h_sync), 
		.vsync(v_sync), 
		.video_on(video_on), 
        .p_tick(pixel_tick),		
		.pixel_x(pixel_x), 
		.pixel_y(pixel_y)
		);

      
wire [11:0] rgb_text;
	
Generador_texto Generador_texto(
    .clk(clk), 
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y), 
	.sig_band_cursor(sig_band_cursor),
	.Dir(Dir),
	.Uni(Unis),
	.Dec(Decs),
	.RING_on(RING_on),
	.rgb_text(rgb_text)
    );
    
    RGB_MUX Mux_color(
        .video_on(video_on),
        .rgb_text(rgb_text),
        .RGB(rgb_next)
        );        
	 
    BCD_converter(
    .binary(Dato),
    .Diez(Decs),
    .Uno(Unis)
            );
            
	
   always @(negedge clk)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   
   assign rgb = rgb_reg;
	 
endmodule 
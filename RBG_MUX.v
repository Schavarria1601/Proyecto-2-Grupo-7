`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2017 10:14:49
// Design Name: Daniela Solis
// Module Name: RBG_MUX
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


module RGB_MUX(

//////  INPUTS  ///////
    input video_on, // me activa la pantalla
	input [11:0] rgb_text,
	
////// OUTPUTS  //////
	output reg [11:0] RGB
	);
	
	always @*
	begin
	if (video_on)
		RGB=rgb_text;
	else
		RGB=12'h000; /// si no esta activado, me imprime la pantalla en negro
	end
endmodule
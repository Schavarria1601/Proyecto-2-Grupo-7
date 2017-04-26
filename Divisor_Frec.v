`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2017 09:16:19
// Design Name: Daniela Solís
// Module Name: Divisor_Frec
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


module Divisor_Frec(
       clk,
	   reset,
	   SCLKclk
       );
       
       input wire clk, reset;
	   output reg SCLKclk;
	   
	   
       reg cuenta_sclk;  
       always @(posedge clk)   
	   begin
	      if(reset) begin
		  cuenta_sclk<=1'd0;  
		  SCLKclk <=1'd0; 
		  end  else
		              begin	
		  if(cuenta_sclk == 1'd0)// el numero se calcula dividiendo el clock de la nexys y el clock que se desea, -1, dividido entre 2, debe ser entero
						     		 
				begin 
				cuenta_sclk<= 2'd00; 
				SCLKclk <= ~SCLKclk;
				end else
				cuenta_sclk <= cuenta_sclk + 1'b1;
		          end
	      end

endmodule
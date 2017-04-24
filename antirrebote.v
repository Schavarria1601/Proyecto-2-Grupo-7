`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2017 20:08:15
// Design Name: 
// Module Name: antirrebote
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

module antirrebote (
    input wire entra,
    input wire CLK,
    input wire reset,
    output wire salida
);

reg ff01;
reg ff02;
reg ff03;
reg ff04;
reg ff05;

always @(posedge CLK, posedge reset) 
	begin
	if (reset) begin
		ff01<=1'b0;
		ff02<=1'b0;
		ff03<=1'b0;
		ff04<=1'b0;
		ff05<=1'b0;
		    end 
        else begin
		ff01<=entra;
		ff02<=ff01;
		ff03<=ff02;
		ff04<=ff03;
		ff05<=ff04;
	        end
	        
	end

assign salida = ff01 && ff02 && ff03 && ff04 && ff05 && ~entra;


endmodule

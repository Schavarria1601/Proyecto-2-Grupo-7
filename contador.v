`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2017 11:13:58 AM
// Design Name: 
// Module Name: contador
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
module contador(
    input clk,
    input reset,
    output reg [8:0] contador
    );   
    always @(posedge clk)
    begin
        if (reset)
            contador <= 9'd0;
        else 
        begin
            contador <= contador + 9'd1;
        end
    end      
endmodule
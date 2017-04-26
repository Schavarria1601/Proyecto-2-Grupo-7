`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2017 06:52:05 AM
// Design Name: 
// Module Name: Mux_Ini
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


module Mux_Ini(
    Dir_Ini,
    Dir_Normal,
    Dir_Out,
    En_Dir
    
    );
 parameter largo =8;
 input [largo-1:0]Dir_Ini;
 input [largo-1:0] Dir_Normal;
 output [largo-1:0] Dir_Out;
 input En_Dir;
 
assign Dir_Out = En_Dir ? Dir_Normal: Dir_Ini;
                        
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2017 01:42:32 PM
// Design Name: 
// Module Name: Muxi_Cs
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


module Muxi_Cs(
    Cs_escritura,
    Cs_lectura,
    En_Cs,
    Cs_Out
    
    );
 parameter largo =8;
 input Cs_lectura;
 input Cs_escritura;
 output Cs_Out;
 input En_Cs;
 
assign Cs_Out = En_Cs ? Cs_escritura: Cs_lectura;
                        
endmodule

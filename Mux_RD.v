`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2017 01:30:58 PM
// Design Name: 
// Module Name: Mux_RD
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


module Mux_RD(
    RD_escritura,
    RD_lectura,
    En_RD,
    RD_Out
    
    );
 parameter largo =8;
 input RD_lectura;
 input RD_escritura;
 output RD_Out;
 input En_RD;
 
assign RD_Out = En_RD ? RD_escritura: RD_lectura;
                        
endmodule

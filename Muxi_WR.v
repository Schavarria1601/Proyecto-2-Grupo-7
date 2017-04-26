`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2017 01:45:24 PM
// Design Name: 
// Module Name: Muxi_WR
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


module Muxi_WR(
    WR_escritura,
    WR_lectura,
    En_WR,
    WR_Out
    
    );
 parameter largo =8;
 input WR_lectura;
 input WR_escritura;
 output WR_Out;
 input En_WR;
 
assign WR_Out = En_WR ? WR_escritura: WR_lectura;

endmodule

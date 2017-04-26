`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2017 07:05:46 AM
// Design Name: 
// Module Name: AD_Mux
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


module AD_Mux(
    AD_escritura,
    AD_lectura,
    En_AD,
    AD_Out
    
    );
 parameter largo =8;
 input AD_lectura;
 input AD_escritura;
 output AD_Out;
 input En_AD;
 
assign AD_Out = En_AD ? AD_escritura: AD_lectura;
                        
endmodule


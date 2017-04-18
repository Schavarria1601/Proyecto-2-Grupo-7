`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2017 05:42:42 AM
// Design Name: 
// Module Name: bus_de_datos
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
module bus_de_datos(
    clk,
    leer_dato,
    escribir_dato,  //  sera igual a "Data" de la FSM READ and WRITE
    A_D,
    address,
    dato_escribir,
    dato_leer,
    salida_bidireccional);
    
    parameter bus = 8;
    input wire clk,leer_dato;
    input wire escribir_dato, A_D;
    input wire [bus-1:0] address, dato_escribir;
    output reg [bus-1:0] dato_leer;
    inout wire [bus-1:0] salida_bidireccional;
    wire [bus-1:0] dato_o_direccion; // dato o direccion segun la señal de seleccion
    
    assign dato_o_direccion = A_D ? dato_escribir : address; //  si AD esta en alto, entonces es dato, sino, es una direccion
    assign salida_bidireccional = escribir_dato ? dato_o_direccion : 8'hzz; //  si escribir_dato esta en alto, entonces se coloca dato_o_direccion, sino, se pone en alta impedancia
    
    always @(posedge clk)
        if (leer_dato) 
            dato_leer <= salida_bidireccional;  //  dato_leer es igual al dato de entrada del RTC
        else
            dato_leer <= dato_leer; //  dato_leer es el dato que se lee del RTC
            
endmodule
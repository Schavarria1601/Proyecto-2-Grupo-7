`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2017 10:49:03 AM
// Design Name: 
// Module Name: Main_Top_Module
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


module Main_Top_Module(
    clk,
    rst,
    Aumentar,
    Disminuir,
    Der,
    Izq,
    SW0,
    SW1,
    SW2,
    RGB,
    Vsync,
    Hsync,
    AD0_AD7,
    AD, CS, WR, RD
    );
 parameter lar=8;
 input clk;
 input rst;
 input SW0;
 input SW1;
 input SW2;
 input Aumentar;
 input Disminuir;
 input Der;
 input Izq;
 output [11:0]RGB;
 output Vsync;
 output Hsync;
 inout wire [lar-1:0]AD0_AD7;
 output AD, CS, WR, RD;
 wire [lar-1:0]Dir;
 wire [lar-1:0]Dato_Ini;
 wire [lar-1:0]Dir_Ini;
 wire [lar-1:0]Dato;
 wire [lar-1:0]DLeido;
 wire [lar-1:0]DEscrito;
 wire HS_W;
 wire HS_R;
 wire HS_Ini;
 wire cable_Data;
 wire cable_Dataw;
 wire cable_Datar;
 wire Enable;
 wire AD_Escri;
 wire AD_Lectura;
 wire RD_Escri;
 wire RD_Lectura;
 wire WR_Escri;
 wire WR_Lectura;
 wire CS_Escri;
 wire CS_Lectura;
 wire [3:0]loca;
MainFSM  Insta1(

    .clk(clk),
    .rst(rst),
    .Direccion_Out(Dir),
    .Dato_In(DLeido),
    .Dato_Out(Dato),
    .Dato_Out2(DEscrito),
    .Subir(Aumentar),
    .Bajar(Disminuir),
    .Izq(Izq),
    .Der(Der),
    //EN_Programar_Fecha,
    //EN_Programar_Hora,
    //EN_Programar_Timer,
    //.Stop_Timer(),
    .Handshake_Ini_RTC(HS_Ini),
    .Handshake_Lectura(HS_R),
    .Handshake_Escritura(HS_W),
    .Enable_AD(Enable),
    .locali_cursor(loca),
    .SW0(SW0),
    .SW1(SW1),
    .SW2(SW2)
    
    );

bus_de_datos Insta2(
    .clk(clk),
    .rst(rst),
    //.leer_dato(),
    .escribir_dato(cable_Data),  //  sera igual a "Data" de la FSM READ and WRITE
    .A_D(AD),
     .Dir_Ini(Dir_Ini),
     .Dato_Ini(Dato_Ini),
    .Dir(Dir),
    .Dato(Dato),
    .Dato1(DEscrito),
    .Dato_Out(DLeido),
    .salida_bidireccional(AD0_AD7));
    
escritura_escritura Insta3(
        .clk(clk), 
        .reset(rst),
        .Dir(Dir),
        .Dato(Dato),
        //.salida_contador(),
        .AD_reg(AD_Escri), 
        .CS_reg(CS_Escri), 
        .WR_reg(WR_Escri), 
        .RD_reg(RD_Escri), 
        .Data_regw(cable_Dataw), 
        .end_flag(HS_W)
        );
     assign cable_Data = Enable ? cable_Datar : cable_Dataw;
     
     escritura_lectura Insta4(
            .clk(clk),
            .reset(rst),
            .Dir(Dir),
            .Dato(Dato),
            .AD_reg(AD_Lectura),
            .CS_reg(CS_Lectura), 
            .WR_reg(WR_Lectura), 
            .RD_reg(RD_Lectura), 
            .Data_regr(cable_Datar), 
            .end_flag(HS_R)
            //.salida_contador()
            );
            
        initialisation Insta5(
          .clk(clk), 
          .reset(rst),
          .Dir(Dir),
          .Dato(Dato),
          .end_flag(HS_Ini),
          //.initialisation_bit(Dato), //  Bit de inicialización
          .direccion(Dir_Ini),
          .initialisation_data(Dato_Ini)
                );
                
            AD_Mux Insta6(
             .AD_escritura(AD_Escri),
             .AD_lectura(AD_Lectura),
             .En_AD(Enable),
             .AD_Out(AD)
                    );
        

        Top_VGA Insta7(
                        .clk(clk), 
                        .rst(rst), 
                        .RING_on(),
                        .sig_band_cursor(loca),
                        .v_sync(Vsync), 
                        .h_sync(Hsync),
                        .rgb(RGB),
                        .Dir(Dir),
                        .Dato(Dato)
                        );
         Mux_RD  Insta8(
                        .RD_escritura(RD_Escri),
                        .RD_lectura(RD_Lectura),
                        .En_RD(Enable),
                        .RD_Out(RD)
                        );
                        
         Muxi_Cs  Insta9 (
                       .Cs_escritura(CS_Escri),
                       .Cs_lectura(CS_Lectura),
                       .En_Cs(Enable),
                       .Cs_Out(CS)
                       );
                       
         Muxi_WR  Insta10(
                         .WR_escritura(WR_Escri),
                         .WR_lectura(WR_Lectura),
                         .En_WR(Enable),
                          .WR_Out(WR)
                          );
endmodule

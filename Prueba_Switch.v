`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2017 09:14:44 PM
// Design Name: 
// Module Name: Prueba_Switch
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



module Prueba_Switch(
        clk,
        reset,
        Switch0,
        Left,
        Right,
        Aumentar,
        Disminuir,
        locali_cursor,
        //dia_decena,
        dia,
        mes,
        //mes_decena,
        year,
        //year_decena,
        hora,
        //hora_decena,
        min,
        //min_decena,
        hora_timer,
        //hora_timer_decena,
        min_timer
        //min_timer_decena
        
    );
///entradas
 input clk;
 input reset;
 input Switch0;
 input Left;
 input Right;
 input Aumentar;
 input Disminuir;
 
parameter prmtr = 8;
//Salidas
//output [3:0] dia_decena;
output [prmtr-1:0]dia;
output [prmtr-1:0]mes;
//output [3:0]mes_decena;
output [prmtr-1:0]year;
//output [3:0]year_decena;
output [prmtr-1:0]hora;
//output [3:0]hora_decena;
output [prmtr-1:0]min;
//output [3:0]min_decena;
output [prmtr-1:0]hora_timer;
//output [3:0]hora_timer_decena;
output [prmtr-1:0]min_timer;
//output [3:0]min_timer_decena;
output reg [3:0] locali_cursor;
//reg [3:0] dia_decena_reg;
reg [prmtr-1:0]dia_reg;
reg [prmtr-1:0]mes_reg;
//reg [3:0]mes_decena_reg;
reg [prmtr-1:0]year_reg;
//reg [3:0]year_decena_reg;
reg [prmtr-1:0]hora_reg;
//reg [3:0]hora_decena_reg;
reg [prmtr-1:0]min_reg;
//reg [3:0]min_decena_reg;
reg [prmtr-1:0]hora_timer_reg;
//reg [3:0]hora_timer_decena_reg;
reg [prmtr-1:0]min_timer_reg;
//reg [prmtr-1:0]min_timer_decena_reg;


parameter caso_dia = 3'd0;
parameter caso_mes = 3'd1;
parameter caso_year = 3'd2;
reg [2:0] caso = caso_dia;

always@(posedge clk)
//************************************************************************
if (reset)begin
        locali_cursor = 4'b0;//Para localizar el cursor
        dia_reg <= 8'd0;
        mes_reg <= 8'd0;
        year_reg <=8'd0;
        hora_reg <=8'd0;
        min_reg <=8'd0;
        hora_timer_reg <=8'd0;
        min_timer_reg <=8'd0;
        end
//*************************************************************************
else
   begin
            case (caso)
//***********************CASO DIA******************************************
            caso_dia:begin
                   locali_cursor <= 4'b0;//Para localizar el cursor
//*****************************UBICACION BOTONES LEFT RIGHT*************
                   if (Right)begin
                     caso <=caso_mes;
                   end
                   else begin
                        if (Left) begin
                            caso <= caso_year;
                            end
                        else
                            caso <= caso_dia;
//***************AUMENTO\DISMINUCION DE DIGITOS************************         
                            if(Aumentar) begin
                                //state <= state2;
                                if (dia_reg == 8'd31)begin
                                 dia_reg<= 8'd0;
                                end
                                else begin
                                dia_reg <= dia_reg + 1'b1;
                                end
                            end
                            else begin
                                if(Disminuir)begin
                                    if(dia_reg == 8'd0)begin
                                     dia_reg <= 8'd31;
                                     end
                                    else begin
                                    dia_reg<= dia_reg - 1'b1;
                                    end
                                end
                                else begin
                                dia_reg <= dia_reg;
                                end
                            end
                   end      
            end
//****************************CASO MES**************************************
            caso_mes:begin
                locali_cursor <= 4'd1;//Para localizar el cursor
//*************UBICACION BOTONES LEFT RIGHT********************************
                if(Right)begin
                caso <= caso_year;
                end
                else begin
                    if(Left)begin
                    caso <= caso_dia;
                    end   
                    else begin
                    caso <=caso_mes;
//*********************AUMENTO\DISMINUCION DE DIGITOS********************   
                    if(Aumentar) begin
                        //state <= state2;
                        if (mes_reg == 8'd31)begin
                         mes_reg<= 8'd0;
                        end
                        else begin
                        mes_reg <= mes_reg + 1'b1;
                        end
                    end
                    else begin
                        if(Disminuir)begin
                            if(mes_reg == 8'd0)begin
                             mes_reg <= 8'd31;
                             end
                            else begin
                            mes_reg<= mes_reg - 1'b1;
                            end
                        end
                        else begin
                        mes_reg <= mes_reg;
                        end
                    end
                    end
                end
            end
//****************************CASO YEAR***********************************
            caso_year:begin
            locali_cursor <= 4'd2;//Para localizar el cursor
//************************UBICACION BOTONES LEFT RIGHT*******************
                if(Right)begin
                caso <= caso_dia;
                end
                else begin
                   if(Left)begin
                   caso <=caso_mes;
                   end 
                   else begin
                   caso <= caso_year;
//*********************AUMENTO\DISMINUCION DE DIGITOS*********************
                     if(Aumentar) begin
                                    //state <= state2;
                                    if (year_reg == 8'd31)begin
                                     year_reg<= 8'd0;
                                    end
                                    else begin
                                    year_reg <= year_reg + 1'b1;
                                    end
                                end
                                else begin
                                    if(Disminuir)begin
                                        if(year_reg == 8'd0)begin
                                         year_reg <= 8'd31;
                                         end
                                        else begin
                                        year_reg <= year_reg - 1'b1;
                                        end
                                    end
                                    else begin
                                    year_reg <= year_reg;
                                    end
                                end
                   end
                end
            end
            default: caso <= caso_dia;
            endcase
   end
//***********************************************************************
assign dia = dia_reg;
assign mes = mes_reg;
assign year = year_reg;
assign hora = hora_reg;
assign min = min_reg;
   //reg [3:0]min_decena_reg;
assign hora_timer = hora_timer_reg;
   //reg [3:0]hora_timer_decena_reg;
assign min_timer = min_timer_reg; 

endmodule

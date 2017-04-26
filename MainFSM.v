`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2017 05:30:32 PM
// Design Name: 
// Module Name: MainFSM
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


module MainFSM(

    clk,
    rst,
    Direccion_Out,
    Dato_In,
    Dato_Out,
    Dato_Out2,
    Subir,
    Bajar,
    Izq,
    Der,
    //EN_Programar_Fecha,
    //EN_Programar_Hora,
    //EN_Programar_Timer,
    //Stop_Timer,
    Handshake_Ini_RTC,
    Handshake_Lectura,
    Handshake_Escritura,
    locali_cursor,
    Enable_AD,
    SW0,
    SW1,
    SW2
    
    );
    
//Entradas principales

input clk;
input rst;

//parámetros de buses de datos
parameter pmtr = 8;
parameter HS = 4;


//parámetros de máquina de estado

parameter state0 = 4'd0;
parameter state1 = 4'd1;
parameter state2 = 4'd2;
parameter state3 = 4'd3;
parameter state4 = 4'd4;
parameter state5 = 4'd5;
parameter state6 = 4'd6;
parameter state_default = 4'd7;

reg [3:0] state = state0;



//Señales de control
//output reg EN_Programar_Fecha;
//output reg EN_Programar_Hora;
//output reg EN_Programar_Timer;

// Handshakes de cada módulo


// Entradas de Handshakes
input Handshake_Ini_RTC;
input Handshake_Lectura;
input Handshake_Escritura;
reg Handshake_Pintar_Pantalla;

output reg Enable_AD;

/*  HACER MUX PARA QUE CONTROLE LA SENAL AD DE LAS FSM*/


// Mapeo de memoria     
output reg [pmtr-1:0] Direccion_Out;
input      [pmtr-1:0] Dato_In;
output reg [pmtr-1:0] Dato_Out;
output wire [pmtr-1:0] Dato_Out2;
reg [pmtr-1:0] Dato_Out2reg;    //  Registro signal interna ddel mapeo de memoria


// Botones y sus registros
input SW0;
input SW1;
 //Timer
input SW2;//Programación Timer
//***************PARA BOTONES EXTERNO**************
input Subir;
input Bajar;
input Izq;
input Der;
wire Aumentar;
wire Disminuir;
wire Left;
wire Right;
//input Stop_Timer;

reg [pmtr-1:0] var_dir_lectura;
reg [pmtr-1:0] var_dir_pantalla;
reg [pmtr-1:0] var_dir_escritura;

reg [1:0]DirM ;//Para cambiar direcciones de memoria principal en Lectura
reg [1:0]DirPintar;//Para cambiar direcciones de memoria principal en VGA
reg [1:0]DirEscri ;//Para cambiar direcciones de memoria principal en Escritura
reg [1:0]DirIni;//Para cambiar direcciones de Ini

reg [pmtr-1:0] Direccion_dato;
reg [pmtr-1:0] Direccion_dato_pintar;// Para el case de asignación envío de datos a la VGA

//registros internos
reg [pmtr-1:0]Hora;
reg [pmtr-1:0]Minuto;
reg [pmtr-1:0]Segundo;
reg [pmtr-1:0]Dia;
reg [pmtr-1:0]Mes;
reg [pmtr-1:0] Year;
reg [pmtr-1:0] Hora_Timer;
reg [pmtr-1:0] Minuto_Timer;
reg [pmtr-1:0] Segundo_Timer;
//****************PARAMETROS PARA MAQUINA DE ESTADO FECHA/HORA/TIMER
parameter caso_dia =  3'd0;
parameter caso_mes =  3'd1;
parameter caso_year = 3'd2;
parameter caso_hora =  3'd0;
parameter caso_min =   3'd1;
parameter caso_seg =   3'd2;
parameter caso_htimer =  3'd0;
parameter caso_mtimer =  3'd1;
parameter caso_stimer =  3'd2;
reg [2:0] caso_fecha = caso_dia;
reg [2:0] caso_hour =  caso_hora;
reg [2:0] caso_timer = caso_htimer;
output reg [3:0] locali_cursor;// Para saber la ubicacion del cursor

//***********************INSTANCEACION DE LOS ANTIRREBOTES**************
antirrebote incrementar(
  .entra(Subir),
  .CLK(clk),
  .reset(rst),
  .salida(Aumentar)
);

antirrebote disminuir(
  .entra(Bajar),
  .CLK(clk),
  .reset(rst),
  .salida(Disminuir)
);

antirrebote left (
  .entra(Izq),
  .CLK(clk),
  .reset(rst),
  .salida(Left)
);

antirrebote right(
  .entra(Der),
  .CLK(clk),
  .reset(rst),
  .salida(Right)
);

//***************************************************************************


//***************************************************************************

always@(posedge clk)
      if (rst) begin
//********************************ESTADO DEFAULT*****************************
         Enable_AD<=1'b0;
         var_dir_lectura <= 8'h21;
         var_dir_pantalla <=8'h04;
         DirPintar <=2'd0;
         DirM <=2'd0; 
         DirIni<=2'd0;
         Direccion_dato<=8'd0;
         //EN_Programar_Fecha <= 0;
         //EN_Programar_Hora <= 0;
         //EN_Programar_Timer <= 0;
         Direccion_Out <= 8'hFF;
         Dato_Out <=8'hFF;
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
//**************************INICIALIZACIÓN RTC*******************************
            state0 : begin
               if (Handshake_Ini_RTC)begin  
                 DirIni<=2'd0;
                state <= state1;
		       Direccion_Out <= 8'h00;
               Dato_Out <=8'h00; 
               end              
	           else
	           
               case(DirIni)
               2'd0:begin
		       Direccion_Out <= 8'h00;
               Dato_Out <=8'h01;
               DirIni<=DirIni + 1'b1;
               end
               2'd1:begin
                Direccion_Out <= 8'h0F;
                DirIni<= DirIni + 1'b1;
                end
               2'd2:begin
                Direccion_Out <= 8'h10;
                DirIni<= DirIni + 1'b1;
               end
               endcase
	        end
//*************************LECTURA RTC****************************************
            state1 : begin
            Enable_AD<=1'b0;
               if (Handshake_Lectura)  
                    begin
                            case (Direccion_dato)	
                                   8'h23: begin 
                                   Hora <= Dato_In;//****Falta asignarle cuales bits son
                                   end
                                   8'h22: begin 
                                   Minuto <= Dato_In;//****Falta asignarle cuales bits son
                                   end
                                   8'h21:begin
                                   Segundo <=Dato_In;
                                    end
                                   8'h24:begin
                                   Dia<= Dato_In;
                                    end
                                   8'h25:begin
                                   Mes <= Dato_In;
                                    end
                                   8'h26:begin
                                    Year <= Dato_In;
                                    end
                                   8'h43:begin
                                    Hora_Timer <= Dato_In;
                                    state <= state2;
                                    Handshake_Pintar_Pantalla = 1'b0;
                                    end
                                   8'h42:begin
                                    Minuto_Timer <= Dato_In;
                                    end
                                   8'h41:begin 
                                    Segundo_Timer <= Dato_In;
                                     
                                   end
                                   endcase
                                  
                          DirM<=0;
                     end
	            else
	            begin
	           case (DirM)// proceso de varias direcciones y datos en cada módulo
               2'd0: begin
                    Direccion_Out <= 8'h01;
                    Dato_Out <=8'h00;
                    DirM = DirM+1;
                    end	
               2'd1:begin  
               if (var_dir_lectura == 8'h43)begin
                 var_dir_lectura <=8'h21 ;
                 end
              else begin
                    if(var_dir_lectura==8'h26)begin
                    var_dir_lectura<=8'h41;
                    end
                    else begin
                    var_dir_lectura <= var_dir_lectura + 1'h1;
                    end
                    end
                    Direccion_Out <= 8'h02;
                    Dato_Out <= var_dir_lectura;/// Tengo que definir una variable
                    Direccion_dato <=var_dir_lectura;
                    DirM = DirM+1'b1;
                    end
               2'd2:begin
                    Direccion_Out <= 8'h01;
                    Dato_Out <=8'hff;                    
                    end
               endcase
               
               end
            end   
//*****************************PINTA EN LA PANTALLA ************************************
            state2 : begin
                   if (~Handshake_Pintar_Pantalla) begin
                       DirPintar <= 2'b0;
                       case(DirPintar)
                       2'd0:begin    
                                                          
                       Direccion_Out <= var_dir_pantalla;//Dirección donde empiezan las variables de la VGA
                       Direccion_dato_pintar<= var_dir_pantalla;//Para el case de varibles
                        begin
                         case(Direccion_dato_pintar)
                          8'h05: begin 
                             Dato_Out <= Hora;//****Falta asignarle cuales bits son
                          end
                          8'h06: begin 
                            Dato_Out<= Minuto;//****Falta asignarle cuales bits son
                          end
                          8'h07:begin
                            Dato_Out <= Segundo;
                          end
                          8'h08:begin
                            Dato_Out <=Dia;
                          end
                        
                          8'h09:begin
                            Dato_Out <= Mes;
                          end
                          8'h0A:begin
                            Dato_Out <=Year;
                          end
                          8'h0B:begin
                            Dato_Out <= Hora_Timer;
                          end
                          8'h0C:begin
                            Dato_Out <= Minuto_Timer;
                          end
                          8'h0D:begin 
                            Dato_Out <= Segundo_Timer;
                            Handshake_Pintar_Pantalla = 1'b1;
                            
                          end
                          endcase
                            DirPintar <=  DirPintar + 1'b1;
                          end
                                                       
                          end 
                        2'd1:begin
                            if (var_dir_pantalla== 8'h0D)begin
                                var_dir_pantalla <=var_dir_pantalla;
                            end 
                            else begin
                               var_dir_pantalla <= var_dir_pantalla + 1'h1;  
                            end
                        end
                        2'd2:begin
                            Direccion_Out <= 8'hff;
                            Dato_Out <=8'hff;                    
                        end
                        endcase
                        end                     
                        else
                       if (SW0)
                             state <= state3;
                       else
                              if(SW1)
                                  state <= state4;
                              else
                                   if (SW2)
                                    state <= state5;
                                    else begin 
                                            state <= state1;
                                            var_dir_pantalla <=8'h05;// Inicalizar la variable         
                        end   
                        end
//*********************************PROGRAMACIÓN FECHA*************************************
                state4 : begin
                   if (SW0)begin  
                     case (caso_fecha)
//***********************CASO DIA******************************************
                     caso_dia:begin
                        locali_cursor <= 4'b0;//Para localizar el cursor
       //*****************************UBICACION BOTONES LEFT RIGHT*************
                          if (Right)begin
                            caso_fecha <=caso_mes;
                          end
                          else begin
                               if (Left) begin
                                   caso_fecha <= caso_year;
                                   end
                               else
                                   caso_fecha <= caso_dia;
       //***************AUMENTO\DISMINUCION DE DIGITOS************************         
                                   if(Aumentar) begin
                                       state <= state2;
                                       Handshake_Pintar_Pantalla = 1'b0;
                                       if (Dia == 8'd31)begin
                                        Dia<= 8'd0;
                                       end
                                       else begin
                                       Dia <= Dia + 1'b1;
                                       end
                                   end
                                   else begin
                                       if(Disminuir)begin
                                           state <= state2;
                                           Handshake_Pintar_Pantalla = 1'b0;
                                           if(Dia == 8'd0)begin
                                            Dia <= 8'd31;
                                            end
                                           else begin
                                           Dia <= Dia - 1'b1;
                                           end
                                            end
                                             else begin
                                             Dia <= Dia;
                                             end
                                   end
                          end      
                   end
       //****************************CASO MES**************************************
                   caso_mes:begin
                      locali_cursor <= 4'd1;//Para localizar el cursor
       //*************UBICACION BOTONES LEFT RIGHT********************************
                       if(Right)begin
                       caso_fecha <= caso_year;
                       end
                       else begin
                           if(Left)begin
                           caso_fecha <= caso_dia;
                           end   
                           else begin
                           caso_fecha <=caso_mes;
       //*********************AUMENTO\DISMINUCION DE DIGITOS********************   
                           if(Aumentar) begin
                               state <= state2;            
                               Handshake_Pintar_Pantalla = 1'b0;
                               if (Mes == 8'd31)begin
                                Mes <= 8'd0;
                               end
                               else begin
                               Mes <= Mes + 1'b1;
                               end
                           end
                           else begin
                               if(Disminuir)begin
                                state <= state2;
                                Handshake_Pintar_Pantalla = 1'b0;
                                   if(Mes == 8'd0)begin
                                    Mes <= 8'd31;
                                    end
                                   else begin
                                    Mes <= Mes - 1'b1;
                                   end
                               end
                               else begin
                               Mes <= Mes;
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
                       caso_fecha <= caso_dia;
                       end
                       else begin
                          if(Left)begin
                          caso_fecha <=caso_mes;
                          end 
                          else begin
                          caso_fecha <= caso_year;
       //*********************AUMENTO\DISMINUCION DE DIGITOS*********************
                            if(Aumentar) begin
                                           state <= state2;
                                           Handshake_Pintar_Pantalla = 1'b0;
                                           if (Year == 8'd31)begin
                                            Year <= 8'd0;
                                           end
                                           else begin
                                           Year <= Year + 1'b1;
                                           end
                                       end
                                       else begin
                                           if(Disminuir)begin
                                             state <= state2;
                                               if(Year == 8'd0)begin
                                                Year <= 8'd31;
                                                end
                                               else begin
                                               Year <= Year - 1'b1;
                                               end
                                           end
                                           else begin
                                           Year <= Year;
                                           end
                                       end
                          end
                       end
                   end
                   default: caso_fecha <= caso_dia;
                   endcase
                   end
                   else
                   state <= state6;	
                  //EN_Programar_Fecha <= 1;
                  //EN_Programar_Hora  <= 0;
                  //EN_Programar_Timer <= 0;  		
                end 
//****************************PROGRAMACIÓN HORA ***********************************
                state3 : begin
                   if (SW1) begin
                    case (caso_hour)
//***********************CASO HORA******************************************
                          caso_hora:begin
                          locali_cursor <= 4'd3;//Para localizar el cursor
//*****************************UBICACION BOTONES LEFT RIGHT*********************
                          if (Right)begin
                            caso_hour <=caso_min;
                          end
                          else begin
                               if (Left) begin
                                   caso_hour <= caso_seg;
                                   end
                               else
                                   caso_hour <= caso_hora;
//***************AUMENTO\DISMINUCION DE DIGITOS****************************         
                                   if(Aumentar) begin
                                       state <= state2;
                                       Handshake_Pintar_Pantalla = 1'b0;
                                       if (Hora == 8'd24)begin
                                        Hora <= 8'd0;
                                       end
                                       else begin
                                       Hora <= Hora + 1'b1;
                                       end
                                   end
                                   else begin
                                       if(Disminuir)begin
                                         state <= state2;
                                         Handshake_Pintar_Pantalla = 1'b0;
                                           if(Hora == 8'd0)begin
                                            Hora <= 8'd24;
                                            end
                                           else begin
                                           Hora <= Hora - 1'b1;
                                           end
                                       end
                                       else begin
                                       Hora <= Hora;
                                       end
                                   end
                          end      
                   end
//****************************CASO MINUTO**************************************
                   caso_min:begin
                       locali_cursor <= 4'd4;//Para localizar el cursor
//*************UBICACION BOTONES LEFT RIGHT********************************
                       if(Right)begin
                       caso_hour <= caso_seg;
                       end
                       else begin
                           if(Left)begin
                           caso_hour <= caso_hour;
                           end   
                           else begin
                           caso_hour <= caso_min;
//*********************AUMENTO\DISMINUCION DE DIGITOS********************   
                           if(Aumentar) begin
                               state <= state2;
                               Handshake_Pintar_Pantalla = 1'b0;
                               if (Minuto == 8'd60)begin
                                Minuto <= 8'd0;
                               end
                               else begin
                               Minuto <= Minuto + 1'b1;
                               end
                           end
                           else begin
                               if(Disminuir)begin
                                state <= state2;
                                   if(Minuto== 8'd0)begin
                                    Minuto <= 8'd60;
                                    end
                                   else begin
                                   Minuto <= Minuto - 1'b1;
                                   end
                               end
                               else begin
                               Minuto <= Minuto;
                               end
                           end
                           end
                       end
                   end
//****************************CASO SEGUNDO***********************************
                   caso_seg:begin
                   locali_cursor <= 4'd5;//Para localizar el cursor
//************************UBICACION BOTONES LEFT RIGHT*******************
                       if(Right)begin
                       caso_hour <= caso_hora;
                       end
                       else begin
                          if(Left)begin
                          caso_hour <= caso_min;
                          end 
                          else begin
                          caso_hour <= caso_seg;
//*********************AUMENTO\DISMINUCION DE DIGITOS*********************
                            if(Aumentar) begin
                                           state <= state2;
                                           Handshake_Pintar_Pantalla = 1'b0;
                                           if (Segundo == 8'd60)begin
                                            Segundo <= 8'd0;
                                           end
                                           else begin
                                           Segundo <= Segundo + 1'b1;
                                           end
                                       end
                                       else begin
                                           if(Disminuir)begin
                                           state <= state2;
                                           Handshake_Pintar_Pantalla = 1'b0;
                                               if(Segundo == 8'd0)begin
                                                Segundo <= 8'd60;
                                                end
                                               else begin
                                               Segundo <= Segundo - 1'b1;
                                               end
                                           end
                                           else begin
                                           Segundo <= Segundo;
                                           end
                                       end
                          end
                       end
                   end
                   default: caso_hour <= caso_hora;
                   endcase                 
                   end
                   else
                   state <= state6;	
                  //EN_Programar_Fecha <= 0;
                  //EN_Programar_Hora  <= 1;
                  //EN_Programar_Timer <= 0;                    
                end
//*********************PROGRAMACIÓN TIMER ************************
                 state5 : begin
                  if (SW2)
                    case (caso_timer)
//***********************CASO HORA******************************************
                        caso_htimer:begin
                        locali_cursor <= 4'd6;//Para localizar el cursor
//*****************************UBICACION BOTONES LEFT RIGHT*********************
                        if (Right)begin
                          caso_timer <= caso_mtimer;
                        end
                        else begin
                             if (Left) begin
                                 caso_timer <= caso_stimer;
                                 end
                             else
                                 caso_timer <= caso_htimer;
//***************AUMENTO\DISMINUCION DE DIGITOS****************************         
                                 if(Aumentar) begin
                                     state <= state2;
                                     Handshake_Pintar_Pantalla = 1'b0;
                                     if (Hora_Timer == 8'd24)begin
                                      Hora_Timer <= 8'd0;
                                     end
                                     else begin
                                     Hora_Timer <= Hora_Timer + 1'b1;
                                     end
                                 end
                                 else begin
                                     if(Disminuir)begin
                                       state <= state2;
                                       Handshake_Pintar_Pantalla = 1'b0;
                                         if(Hora_Timer == 8'd0)begin
                                          Hora_Timer <= 8'd24;
                                          end
                                         else begin
                                         Hora_Timer <= Hora_Timer - 1'b1;
                                         end
                                     end
                                     else begin
                                     Hora_Timer <= Hora_Timer;
                                     end
                                 end
                        end      
                 end
//****************************CASO MINUTO**************************************
                 caso_mtimer:begin
                 locali_cursor <= 4'd7;//Para localizar el cursor
//*************UBICACION BOTONES LEFT RIGHT********************************
                     if(Right)begin
                     caso_timer <= caso_stimer;
                     end
                     else begin
                         if(Left)begin
                         caso_timer <= caso_htimer;
                         end   
                         else begin
                         caso_timer <= caso_mtimer;
//*********************AUMENTO\DISMINUCION DE DIGITOS********************   
                         if(Aumentar) begin
                             state <= state2;
                             if (Minuto_Timer == 8'd60)begin
                              Minuto_Timer <= 8'd0;
                             end
                             else begin
                             Minuto_Timer <= Minuto_Timer + 1'b1;
                             end
                         end
                         else begin
                             if(Disminuir)begin
                              Handshake_Pintar_Pantalla = 1'b0;
                              state <= state2;
                                 if(Minuto_Timer== 8'd0)begin
                                  Minuto_Timer <= 8'd60;
                                  end
                                 else begin
                                 Minuto_Timer <= Minuto_Timer - 1'b1;
                                 end
                             end
                             else begin
                             Minuto_Timer <= Minuto_Timer;
                             end
                         end
                         end
                     end
                 end
//****************************CASO SEGUNDO***********************************
                 caso_stimer:begin
                 locali_cursor <= 4'd8;//Para localizar el cursor
//************************UBICACION BOTONES LEFT RIGHT*******************
                     if(Right)begin
                     caso_timer <= caso_htimer;
                     end
                     else begin
                        if(Left)begin
                        caso_timer <= caso_mtimer;
                        end 
                        else begin
                        caso_timer <= caso_stimer;
//*********************AUMENTO\DISMINUCION DE DIGITOS*********************
                          if(Aumentar) begin
                                         state <= state2;
                                         Handshake_Pintar_Pantalla = 1'b0;
                                         if (Segundo_Timer == 8'd60)begin
                                          Segundo_Timer <= 8'd0;
                                         end
                                         else begin
                                         Segundo_Timer <= Segundo_Timer + 1'b1;
                                         end
                                     end
                                     else begin
                                         if(Disminuir)begin
                                         Handshake_Pintar_Pantalla = 1'b0;
                                         state <= state2;
                                             if(Segundo_Timer == 8'd0)begin
                                             Segundo_Timer <= 8'd60;
                                              end
                                             else begin
                                             Segundo_Timer <= Segundo_Timer - 1'b1;
                                             end
                                         end
                                         else begin
                                         Segundo_Timer <= Segundo_Timer;
                                         end
                                     end
                        end
                     end
                 end
                 default: caso_timer <= caso_htimer;
                 endcase                 
                  else
                   state <= state6;
                   	
                // EN_Programar_Fecha <= 0;
                 //EN_Programar_Hora  <= 0;
                 //EN_Programar_Timer <= 1;  
                 
                  
                end 
//****************************ESCRITURA*********************************************************
                 //Dirección 0x04 Dirección Dato Escrito
                 state6 : begin
                 Enable_AD<=1'b1;
                 if (Handshake_Escritura)begin 
                  Direccion_Out <= 8'h01;
                  Dato_Out <=8'hFF;
                  end
                 else 
                  begin
                  DirEscri = 2'b0;
                               case (DirEscri)// proceso de varias direcciones y datos en cada módulo
                               2'd0: begin
                                    Direccion_Out <= 8'h01;
                                    Dato_Out <=8'h01;
                                    DirEscri = DirEscri + 1;
                                    end    
                               2'd1:begin  
                                    if (var_dir_escritura == 8'h43)begin
                                         var_dir_escritura <=8'h21 ;
                                    end
                                    else begin
                                    if(var_dir_lectura==8'h26)begin
                                       var_dir_lectura<=8'h41;
                                    end
                                    else begin
                                    var_dir_lectura <= var_dir_lectura + 1'h1;
                                    end
                                    end
                                                  
                                    Direccion_Out <= 8'h02;
                                    Dato_Out <= var_dir_escritura;/// Tengo que definir una variable
                                    Direccion_dato <=var_dir_escritura;
                                    DirEscri = DirEscri +'b1;
                                    end
                               2'd2:begin
                               case (Direccion_dato)	
                                     8'h23: begin 
                                      Dato_Out2reg<= Hora;//****Falta asignarle cuales bits son
                                      end
                                     8'h22: begin 
                                     Dato_Out2reg <=Minuto;//****Falta asignarle cuales bits son
                                      end
                                     8'h21:begin
                                     Dato_Out2reg <=Segundo;
                                      end
                                     8'h24:begin
                                     Dato_Out2reg <=Dia;
                                      end
                                     8'h25:begin
                                     Dato_Out2reg <=Mes;
                                      end
                                     8'h26:begin
                                     Dato_Out2reg <=Year;
                                      end
                                     8'h43:begin
                                     Dato_Out2reg <=Hora_Timer;
                                     state <= state1;
                                      end
                                      8'h42:begin
                                     Dato_Out2reg <=Minuto_Timer;
                                      end
                                     8'h41:begin 
                                     Dato_Out2reg <=Segundo_Timer;                                                            
                                      end
                                      endcase
                                                                           
                               end
                               2'd3:begin
                                    Direccion_Out <= 8'h01;
                                    Dato_Out <=8'hff;                    
                                    end
                               
                               endcase
                               
                               end
                end 
                state_default: begin
                 //EN_Programar_Fecha <= 0;
                 //EN_Programar_Hora <=  0;
                 //EN_Programar_Timer <= 0;
                 Direccion_Out <= 8'hFF;
                 Dato_Out <=8'hFF;
                end 
                 default: state <= state0;
                         
            endcase
            assign Dato_Out2 = Dato_Out2reg;
endmodule

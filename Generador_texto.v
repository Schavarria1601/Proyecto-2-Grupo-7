`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2017 14:17:41
// Design Name: Daniela Solis
// Module Name: Generador_texto
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


module Generador_texto(

////////// INPUTS //////////
   input wire clk,
   input wire [3:0] sig_band_cursor, // indica la posicion del cursos
   input wire [9:0] pixel_x, pixel_y,   
   input wire  RING_on, // Recibe la señal de si se activo la alarma o no
   /// imputs para la etrada de datos, el valor del dato entra ya dividido
   input [7:0]Dir,
   input [3:0]Uni,
   input [3:0]Dec,
   
//////// OUTPUTS ///////////   
   output reg [11:0] rgb_text
   );

   // signal declaration
   wire [10:0] rom_addr;
   reg [6:0] char_addr;
   reg [3:0] row_addr;
   reg [2:0] bit_addr;
   wire [7:0] font_word;
   wire font_bit;
   
   // instantiate font ROM
   Font_rom font_unit
      (.clk(clk), .addr(rom_addr), .data(font_word));
      

// character  
    reg [6:0] char_addr_FECHA, char_addr_NumFECHA, char_addr_HORA, char_addr_NumHORA, char_addr_ForMili, char_addr_CRONO, char_addr_NumCRONO, char_addr_RING, char_addr_SIMBOLO;
// wires para pixel_x y pixel_y
    wire [3:0] row_addr_FECHA, row_addr_NumFECHA, row_addr_HORA, row_addr_NumHORA, row_addr_ForMili, row_addr_CRONO, row_addr_NumCRONO,row_addr_RING, row_addr_SIMBOLO; //fila (y)
    wire [2:0] bit_addr_FECHA, bit_addr_NumFECHA, bit_addr_HORA, bit_addr_NumHORA, bit_addr_ForMili, bit_addr_CRONO, bit_addr_NumCRONO,  bit_addr_RING, bit_addr_SIMBOLO; //bit (x)
// nombre de los paquetes
    wire FECHA_on, NumFECHA_on, HORA_on, NumHORA_on, ForMili_on, CRONO_on, NumCRONO_on, SIMBOLO_on; //establecera valor booleano como indicador que se pintara palabra FECHA
    reg [6:0] char_addr_FECHA_reg;  
    
///////// INPUTS  divididas en digito 1 y digito 2 //////// 
    reg[3:0] din_rh_dig01, din_rh_dig02, din_rm_dig01, din_rm_dig02, din_rs_dig01, din_rs_dig02;
    reg [3:0] din_ch_dig01, din_ch_dig02, din_cm_dig01, din_cm_dig02, din_cs_dig01, din_cs_dig02;
    reg [3:0] din_year_dig01, din_year_dig02, din_mes_dig01, din_mes_dig02, din_dia_dig01, din_dia_dig02;
    
   
//case para asignar variables
            always@*
              case (Dir)
                         8'h05: begin 
                          din_rh_dig01 <= Uni;
                          din_rh_dig02 <= Dec;
                             
                          end
                          8'h06: begin 
                          din_rm_dig01 <= Uni;
                          din_rm_dig02 <= Dec;
      
                          end
                          8'h07:begin
                          din_rs_dig01 <= Uni;
                          din_rs_dig02 <= Dec;
                           
                          end
                          8'h08:begin
                          din_dia_dig01 <= Uni;
                          din_dia_dig02 <= Dec;
                          
                          end
                        
                          8'h09:begin
                          din_mes_dig01 <= Uni;
                          din_mes_dig02 <= Dec;
                          end
                          8'h0A:begin
                          din_year_dig01 <= Uni;
                          din_year_dig02 <= Dec;
         
                          end
                          8'h0B:begin
                           din_ch_dig01 <= Uni;
                           din_ch_dig02 <= Dec;
                            
                          end
                          8'h0C:begin
                          din_cm_dig01 <= Uni;
                          din_cm_dig02 <= Dec;
                          end
                          8'h0D:begin
                          din_ch_dig01 <= Uni;
                          din_ch_dig02 <= Dec;
                         end
                    endcase
                    
// divisor de clock para generar el clk del parpadeo
                    reg [24:0] cont = 0;
                        wire CLK_parpadeo;
                        
                        always @ (posedge clk) begin
                            if (cont == 25000000) begin
                                cont <= 0;
                            end
                            else begin
                                cont <= cont + 1'b1;
                            end
                        end
                        assign CLK_parpadeo = cont[24];
                    
///// PALABRA FECHA /////
    assign FECHA_on = ((pixel_y[9:5]==1) && (pixel_x[9:4]>=18) && (pixel_x[9:4]<=22)); //Me difine el tamaï¿½o y=2^5 y x=2^5
	assign row_addr_FECHA = pixel_y[4:1]; //me define el tamaï¿½o de la letra
	assign bit_addr_FECHA = pixel_x[3:1]; //me define el tamaï¿½o de la letra	
		
	always @*
      case(pixel_x[6:4])
         4'h2: char_addr_FECHA = 7'h46; // F
		 4'h3: char_addr_FECHA = 7'h45; // E
         4'h4: char_addr_FECHA = 7'h43; // C 
		 4'h5: char_addr_FECHA = 7'h48; // H
		 4'h6: char_addr_FECHA = 7'h41; // A
					
         default: char_addr_FECHA = 7'h20; //espacio en blanco
      endcase
      
     
///// DIGITOS DE FECHA ////
    assign NumFECHA_on = (pixel_y[9:5]<=3) && (pixel_y[9:5]>=2) && (pixel_x[9:6]>=3) && (pixel_x[9:6]<=6); //coordenadas donde se pintara los digitos
    assign row_addr_NumFECHA = pixel_y[5:2]; //tamaï¿½o de la letra 
    assign bit_addr_NumFECHA = pixel_x[4:2]; //tamaï¿½o de la letra
      
      
    always@*
      begin
          case(pixel_x[7:5]) //coordenadas definidas dependiendo de las coordenadas especificadas anteriormente en NumFECHA_on
              3'h6: char_addr_NumFECHA = {3'b011, din_dia_dig02};//0(dec dia)  
              3'h7: char_addr_NumFECHA = {3'b011, din_dia_dig01};//0(uni dia) 
              3'h0: char_addr_NumFECHA = 7'h2f;// /
              3'h1: char_addr_NumFECHA = {3'b011, din_mes_dig02};//0(dec Mes)
              3'h2: char_addr_NumFECHA = {3'b011, din_mes_dig01};//0(uni mes)
              3'h3: char_addr_NumFECHA = 7'h2f;// /
              3'h4: char_addr_NumFECHA = {3'b011, din_year_dig02};//0(uni de millar aï¿½o)
              3'h5: char_addr_NumFECHA = {3'b011, din_year_dig01};//0(Cen aï¿½o)
              default: char_addr_NumFECHA = 7'h00;//Espacio en blanco
          endcase    
      end
    
    
    
////// Palabra HORA ////
      assign HORA_on = ((pixel_y[9:5]==5) && (pixel_x[9:4]>=18) && (pixel_x[9:4]<=21)); //Me difine el tamaï¿½o y=2^5 y x=2^5
      assign row_addr_HORA = pixel_y[4:1]; //pix_y[5:1] //me define el tamaï¿½o de la letra
      assign bit_addr_HORA = pixel_x[3:1]; //pix_x[4:1]//me define el tamaï¿½o de la letra
      
      always @* 
      begin
          case(pixel_x[5:4]) //para este caso cada 2^4 bits se pinta nueva letra
                                //coordenadas definidas dependiendo de las coordenadas especificadas anteriormente en HORA_on
              2'h2: char_addr_HORA = 7'h48; //H
              2'h3: char_addr_HORA = 7'h4f; //O
              2'h0: char_addr_HORA = 7'h52; //R
              2'h1: char_addr_HORA = 7'h41; //A
              default: char_addr_HORA = 7'h00;//Espacio en blanco
              
          endcase
      end
      
////// Digitos HORA ///
    assign NumHORA_on = (pixel_y[9:5]<=7) && (pixel_y[9:5]>=6) && (pixel_x[9:6]>=3) && (pixel_x[9:6]<=6); //coordenadas donde se pintara los digitos
    assign row_addr_NumHORA= pixel_y[5:2]; //tamaï¿½o de la letra 
    assign bit_addr_NumHORA = pixel_x[4:2]; //tamaï¿½o de la letra
   
 always@*
   begin
       case(pixel_x[7:5]) //coordenadas definidas dependiendo de las coordenadas especificadas anteriormente en NumHORA_on
                   3'h6: char_addr_NumHORA = {3'b011, din_rh_dig02}; // 0
                   3'h7: char_addr_NumHORA = {3'b011, din_rh_dig01}; // 0
                   3'h0: char_addr_NumHORA = 7'h2f; // /
                   3'h1: char_addr_NumHORA = {3'b011, din_rm_dig02}; // 0            
                   3'h2: char_addr_NumHORA = {3'b011, din_rm_dig01}; // 0
                   3'h3: char_addr_NumHORA = 7'h2f; // /
                   3'h4: char_addr_NumHORA = {3'b011, din_rs_dig02}; // 0               
                   3'h5: char_addr_NumHORA = {3'b011, din_rs_dig01}; // 0  
          
           default: char_addr_NumHORA = 7'h00;//Espacio en blanco
       endcase    
   end
   
   ////// Palabra CRONOMETRO////
         assign CRONO_on = ((pixel_y[9:5]==9) && (pixel_x[9:4]>=18) && (pixel_x[9:4]<=22)); //Me difine el tamaï¿½o y=2^5 y x=2^5
         assign row_addr_CRONO = pixel_y[4:1]; //pix_y[5:1] //me define el tamaï¿½o de la letra
         assign bit_addr_CRONO = pixel_x[3:1]; //pix_x[4:1]//me define el tamaï¿½o de la letra
         
         always @* 
         begin
             case(pixel_x[6:4]) //para este caso cada 2^4 bits se pinta nueva letra
                                   //coordenadas definidas dependiendo de las coordenadas especificadas anteriormente en HORA_on
                 4'h2: char_addr_CRONO = 7'h54; // T.
                 4'h3: char_addr_CRONO = 7'h49; // I.
                 4'h4: char_addr_CRONO = 7'h4d; // M.                          
                 4'h5: char_addr_CRONO = 7'h45; // E.  
                 4'h6: char_addr_CRONO = 7'h52; // R.
                                                                  
                 default: char_addr_CRONO = 7'h00;//Espacio en blanco
                 
             endcase
         end
         
   ////// Digitos cronometro ///
       assign NumCRONO_on = (pixel_y[9:5]<=11) && (pixel_y[9:5]>=10) && (pixel_x[9:6]>=3) && (pixel_x[9:6]<=6); //coordenadas donde se pintara los digitos
       assign row_addr_NumCRONO= pixel_y[5:2]; //tamaï¿½o de la letra 
       assign bit_addr_NumCRONO = pixel_x[4:2]; //tamaï¿½o de la letra
      
    always@*
      begin
          case(pixel_x[7:5]) //coordenadas definidas dependiendo de las coordenadas especificadas anteriormente en NumHORA_on
                      3'h6: char_addr_NumCRONO = {3'b011, din_ch_dig02};
                      3'h7: char_addr_NumCRONO = {3'b011, din_ch_dig01};
                      3'h0: char_addr_NumCRONO = 7'h2f; // /
                      3'h1: char_addr_NumCRONO = {3'b011, din_cm_dig02};           
                      3'h2: char_addr_NumCRONO = {3'b011, din_cm_dig01};
                      3'h3: char_addr_NumCRONO = 7'h2f; // /
                      3'h4: char_addr_NumCRONO = {3'b011, din_cs_dig02};              
                      3'h5: char_addr_NumCRONO = {3'b011, din_cs_dig01}; 
             
              default: char_addr_NumCRONO = 7'h00;//Espacio en blanco
          endcase    
      end
      
//Palabra RING(tamaï¿½o de fuente 32x64)
      assign RING_on = ((pixel_y[9:5]==12) && (pixel_x[9:4]>=18) && (pixel_x[9:4]<=21));
      assign row_addr_RING = pixel_y[4:1];
      assign bit_addr_RING = pixel_x[3:1];
      
      always@*
      begin
          
          case(pixel_x[5:4])
          2'h2: char_addr_RING = 7'h52;//R
          2'h3: char_addr_RING = 7'h49;//I
          2'h0: char_addr_RING = 7'h4e;//N
          2'h1: char_addr_RING = 7'h47;//G
          endcase
          
      end
      

    assign rom_addr = {char_addr, row_addr};
    assign font_bit = font_word[~bit_addr];

// activacion de los bloques

always @(posedge clk) begin
		
		rgb_text = 12'h000;
		if (FECHA_on) //palabra FECHA
		begin
			char_addr = char_addr_FECHA;
			row_addr = row_addr_FECHA;
			bit_addr = bit_addr_FECHA;
				if (font_bit) begin
					rgb_text = 12'h287; //verde
				end
		end
		
		///////////////////////////////////////////////////////////////////
		
		else if(NumFECHA_on) //Digitos de la fecha
        begin
        char_addr = char_addr_NumFECHA;
        row_addr = row_addr_NumFECHA;
        bit_addr = bit_addr_NumFECHA;
            if (font_bit) begin
                rgb_text = 12'h0C0; //blanco
            end
                      else 
                           if ((font_bit)&&(pixel_y[9:5]<=3) && (pixel_y[9:5]>=2)&&(pixel_x[9:5]>=6)&&(pixel_x[9:5]<8)&&(sig_band_cursor==4'd0)) // se posiciona en DIA 
                               rgb_text= 12'h110;//Hace un cursor Amarillo
                      else
                           if ((font_bit)&&(pixel_y[9:5]<=3) && (pixel_y[9:5]>=2)&&(pixel_x[9:5]>=9)&&(pixel_x[9:5]<11)&&(sig_band_cursor==4'd1))   //se posiciona en MES  
                                rgb_text = 12'h110;//Hace un cursor Amarillo
                      else 
                           if ((font_bit)&&(pixel_y[9:5]<=3) && (pixel_y[9:5]>=2)&&(pixel_x[9:5]>=12)&&(pixel_x[9:5]<14)&&(sig_band_cursor == 4'd2))  //se posiciona en YEAR  
                                rgb_text= 12'h110;//Hace un cursor Amarillo
                      else 
                           if(~font_bit) rgb_text = 12'h001;//Fondo del texto igual al de los recuadros 
       end
       ////////////////////////////////////////////////////////////////////     
        else if (HORA_on)  //Palabra HORA
               begin
                   char_addr = char_addr_HORA;
                   row_addr = row_addr_HORA;
                   bit_addr = bit_addr_HORA;
                       if (font_bit) begin rgb_text = 12'h287;// verde
                       end 
                           
               end
        ////////////////////////////////////////////////////////////////////
        
        else if(NumHORA_on) //Digitos de la hora
                begin
                char_addr = char_addr_NumHORA;
                row_addr = row_addr_NumHORA;
                bit_addr = bit_addr_NumHORA;
                    if (font_bit) begin
                        rgb_text = 12'h0C0; //blanco
                    end
                     else 
                          if ((~font_bit)&&(pixel_y[9:5]<=7) && (pixel_y[9:5]>=6)&&(pixel_x[9:5]>=6)&&(pixel_x[9:5]<8)&&(sig_band_cursor == 4'd3 )) //se posiciona en HORA 
                              rgb_text= 12'h110;//Hace un cursor Amarillo
                     else
                          if ((~font_bit)&&(pixel_y[9:5]<=7) && (pixel_y[9:5]>=6)&&(pixel_x[9:5]>=9)&&(pixel_x[9:5]<11)&&(sig_band_cursor == 4'd4))  //se posiciona en MINUTO  
                               rgb_text = 12'h110;//Hace un cursor Amarillo
                     else 
                          if ((~font_bit)&&(pixel_y[9:5]<=7) && (pixel_y[9:5]>=6)&&(pixel_x[9:5]>=12)&&(pixel_x[9:5]<14)&&(sig_band_cursor ==4'd5))  //se posiciona en SEGUNDO  
                               rgb_text= 12'h110;//Hace un cursor Amarillo
                     else 
                          if(~font_bit) rgb_text = 12'h001;//Fondo del texto igual al de los recuadros
                                
               end
        ////////////////////////////////////////////////////////////////////   
        else if (CRONO_on)  //Palabra CRONOGRAMA
                 begin
                 char_addr = char_addr_CRONO;
                 row_addr = row_addr_CRONO;
                 bit_addr = bit_addr_CRONO;
                     if (font_bit) begin
                         rgb_text = 12'h287; //verde
                     end
                     
                 end
       ////////////////////////////////////////////////////////////////////
                      
         else if(NumCRONO_on) //Digitos deL CRONOMETRO
                  begin
                  char_addr = char_addr_NumCRONO;
                  row_addr = row_addr_NumCRONO;
                  bit_addr = bit_addr_NumCRONO;
                      if (font_bit) begin
                          rgb_text = 12'h0C0; //blanco
                      end
                       else 
                            if ((~font_bit)&&(pixel_y[9:5]<=11) && (pixel_y[9:5]>=10)&&(pixel_x[9:5]>=6)&&(pixel_x[9:5]<8)&&(sig_band_cursor == 4'd6)) //se posiciona en HORA 
                                rgb_text= 12'h110;//Hace un cursor Amarillo
                       else
                            if ((~font_bit)&&(pixel_y[9:5]<11) && (pixel_y[9:5]>=10)&&(pixel_x[9:5]>=9)&&(pixel_x[9:5]<11)&&(sig_band_cursor == 4'd7))   //se posiciona en MINUTO  
                                 rgb_text = 12'h110;//Hace un cursor Amarillo
                       else 
                            if ((~font_bit)&&(pixel_y[9:5]<=11) && (pixel_y[9:5]>=10)&&(pixel_x[9:5]>=12)&&(pixel_x[9:5]<14)&&(sig_band_cursor == 4'd8))  //se posiciona en SEGUNDO  
                                 rgb_text= 12'h110;//Hace un cursor Amarillo
                       else 
                            if(~font_bit) rgb_text = 12'h001;//Fondo del texto igual al de los recuadros               
                   end
                   
       else if (RING_on)
                     begin
                     char_addr = char_addr_RING;
                     row_addr = row_addr_RING;
                     bit_addr = bit_addr_RING;
                     if(font_bit) begin
                     if (RING_on==1 && CLK_parpadeo==1)
                         rgb_text = 12'hF11; //Rojo
                     else rgb_text = 12'h000;   
                     end else
                     if (~font_bit) rgb_text = 12'h000;
                     end    
        else begin
            rgb_text = 12'h000; //negro
        end
  
    end

endmodule
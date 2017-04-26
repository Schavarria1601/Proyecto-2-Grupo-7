`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 14:17:34
// Design Name: Daniela Solis
// Module Name: VGA_Sync
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



module VGA_Sync(

//////  INPUTS  //////
    input wire clk_in, reset, 
    
//////  OUTPUTS  //////
    output wire hsync, vsync, video_on, p_tick,
    output wire [9:0] pixel_x, pixel_y
   );

//declaracion de constantes, parametros de la pantalla 640x480
   localparam HD = 640; // area horizontal de la pantalla
   localparam HF = 48 ; // h. front (left) borde
   localparam HB = 16 ; // h. back (right) borde
   localparam HR = 96 ; // h. retrace
   localparam VD = 480; // area vertical de la pantalla
   localparam VF = 10;  // v. front (top) borde
   localparam VB = 33;  // v. back (bottom) borde
   localparam VR = 2;   // v. retrace

//mod2_contador
   reg mod2_reg; 
   wire mod2_next; 
   
 //contadores del sincronizador ( estado presente y futuro auxiliares)
   reg [9:0] h_cont_reg, h_cont_next;
   reg [9:0] v_cont_reg, v_cont_next;
 
//salidas del buffer 
   reg v_sync_reg, h_sync_reg;
   wire v_sync_next, h_sync_next;
  
//estado de la señal
   wire h_end, v_end, pixel_tick;

//registros
   always @(posedge clk_in, posedge reset)
      if (reset)
         begin
            mod2_reg <= 1'b0;
            v_cont_reg <= 0;
            h_cont_reg <= 0;
            v_sync_reg <= 1'b0;
            h_sync_reg <= 1'b0;
         end
      else
         begin
            mod2_reg <= mod2_next;
            v_cont_reg <= v_cont_next;
            h_cont_reg <= h_cont_next;
            v_sync_reg <= v_sync_next;
            h_sync_reg <= h_sync_next;
         end

///mod2 circuito generador de frecuencia 25MHz
                      
              assign mod2_next = ~mod2_reg;
              assign pixel_tick = mod2_reg; 

//final de contador horizontal (bit 799)
   assign h_end = (h_cont_reg==(HD+HF+HB+HR-1));

//final de contador vertical (524)
   assign v_end = (v_cont_reg==(VD+VF+VB+VR-1));

//señales de reloj 
//siguiente estado logico de mod_800 contador de sincronizador horizontal

   always @*
      if (pixel_tick)  // este  pulso es de 25 MHz 
         if (h_end)
            h_cont_next = 0;
         else
            h_cont_next = h_cont_reg + 1;
      else
         h_cont_next = h_cont_reg;


//Siguiente estado logico de mod_525 contador de sincronizador vertical
   always @*
      if (pixel_tick & h_end)
         if (v_end)
            v_cont_next = 0;
         else
            v_cont_next = v_cont_reg + 1;
      else
         v_cont_next = v_cont_reg;

// eliminador glitch para vsync y hsync
// 656 y 751 horizontal
   assign h_sync_next = (h_cont_reg>=(HD+HB) &&
                         h_cont_reg<=(HD+HB+HR-1));
//v_h_sync_sig 490-491
   assign v_sync_next = (v_cont_reg>=(VD+VB) &&
                         v_cont_reg<=(VD+VB+VR-1));

// video on/off
   assign video_on = (h_cont_reg<HD) && (v_cont_reg<VD);

//Salidas del sistema sincronizador
   assign hsync = ~h_sync_reg;
   assign vsync = ~v_sync_reg;
   assign pixel_x = h_cont_reg;
   assign pixel_y = v_cont_reg;
   assign p_tick = pixel_tick;

endmodule
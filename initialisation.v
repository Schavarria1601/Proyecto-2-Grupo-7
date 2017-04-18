`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2017 06:14:43 AM
// Design Name: 
// Module Name: initialisation
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
module initialisation(
    clk, reset,
    inicio,
    end_flag,
    initialisation_bit, //  Bit de inicialización
    direccion,
    seconds, minutes, hours, date, month, year,
    clk_and_timer_transfer
    );
    
    parameter bus_bit = 8;
    parameter largo = 9;
    parameter bus = 4;
    input wire clk, reset;
    input wire inicio;
    output reg end_flag;
    output reg [bus_bit-1:0] initialisation_bit;
    output [largo-1:0] direccion;
    
    output reg [bus_bit-1:0] seconds, minutes, hours, date, month, year, clk_and_timer_transfer;
    
    parameter [bus-1:0]   a = 4'b0000,
                          b = 4'b0001,
                          c = 4'b0010,
                          d = 4'b0011,
                          e = 4'b0100,
                          f = 4'b0101,
                          g = 4'b0110,
                          h = 4'b0111,
                          i = 4'b1000;
    reg [bus-1:0] state_reg, state_next;     
    
    wire [largo-1:0] address;                     
    
    //  Instanciación del contador
    contador funcione(
        .contador(address), //  En lugar de ir contando #'s, lo que va a ir contando son direcciones
        .clk(clk),
        .reset(reset));
    
    //  Lógica secuencial de siguiente estado
    always @(posedge clk, posedge reset)
        if (reset)
            state_reg <= a;
        else
            state_reg <= state_next;         
    
    //  Lógica combinacional para los estados e implementación de las señales              
    always @*
        begin
            state_next = state_reg;
            
            //  Inicialización de las señales
            end_flag = 1'b0;
            initialisation_bit = 8'b0;
            seconds = 8'b0; minutes = 8'b0; hours = 8'b0; date = 8'b0; 
            month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
            
            case (state_reg)
                a : begin
                    seconds = 8'b0; minutes = 8'b0; hours = 8'b0; date = 8'b0; 
                    month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (inicio)
                        state_next = b;
                    else
                        state_next = a;
                    end
                        
                b : begin
                    initialisation_bit = 8'b0; seconds = 8'b0; minutes = 8'b0; hours = 8'b0; date = 8'b0; 
                    month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (address == 8'h02) begin
                        state_next = c;
                        initialisation_bit = 8'b00010000; end   //  El bit #5 de inicialización se fija en 1
                    else
                        state_next = b;
                    end
                
                c : begin
                    //  Aquí el bit #5 de inicialización vuelve a 0 para cumplir lo que dice el datasheet
                    initialisation_bit = 8'b0; seconds = 8'b0; minutes = 8'b0; hours = 8'b0; date = 8'b0; 
                    month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (address == 8'h21) begin
                        state_next = d;
                        seconds = 8'b01001001; end  //  Los segundos iniciarán en 49
                    else
                        state_next = c;
                    end
                    
                d : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b0; hours = 8'b0; date = 8'b0; 
                    month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0; 
                    if (address == 8'h22) begin
                        state_next = e;
                        minutes = 8'b00110000; end  //  Los minutos iniciarán en 30
                    else
                        state_next = d;
                    end
                e : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b00110000; hours = 8'b0; date = 8'b0; 
                    month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0; 
                    seconds = 8'b01001001; minutes = 8'b00110000;
                    if (address == 8'h23) begin
                        state_next = f;
                        hours = 8'b00100011; end    //  Las horas iniciarán en 23
                    else
                        state_next = e;
                    end
                    
                f : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b00110000; hours = 8'b00100011; 
                    date = 8'b0; month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (address == 8'h24) begin
                        state_next = g;
                        date = 8'b00010000; end     //  El día será 10 
                    else
                        state_next = f;
                    end
                        
                g : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b00110000; hours = 8'b00100011; 
                    date = 8'b00010000; month = 8'b0; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (address == 8'h25) begin
                        state_next = h;
                        month = 8'b00010010; end    //  El mes será 12 (diciembre)
                    else
                        state_next = g;
                    end
                    
                h : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b00110000; hours = 8'b00100011; 
                    date = 8'b00010000; month = 8'b00010010; year = 8'b0; clk_and_timer_transfer = 8'b0;
                    if (address == 8'h26) begin
                        state_next = i;
                        year = 8'b10010100; end //  El año será 94 (1994)
                    else
                        state_next = h;
                    end
                    
                i : begin
                    initialisation_bit = 8'b0; seconds = 8'b01001001; minutes = 8'b00110000; hours = 8'b00100011; 
                    date = 8'b00010000; month = 8'b00010010; year = 8'b10010100; clk_and_timer_transfer = 8'b0;
                    if (address == 8'hF0) begin
                        state_next = a;
                        end_flag = 1'b1; 
                        clk_and_timer_transfer = 8'b11111111; end   //  Se escribe en la dirección F0 (HEX), la transferencia a la memoria reservada.
                    else
                        state_next = i;
                    end
            endcase
        end  
        assign direccion = address;
endmodule

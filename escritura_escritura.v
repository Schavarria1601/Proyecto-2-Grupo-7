`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2017 11:12:00 AM
// Design Name: 
// Module Name: escritura_escritura
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
module escritura_escritura(
    clk, reset,
    inicio,
    //salida_contador,
    AD_reg, CS_reg, WR_reg, RD_reg, Data_reg, 
    end_flag
    );
        
    input wire clk, reset;
    input wire inicio;
    output wire AD_reg, CS_reg, WR_reg, RD_reg, Data_reg;
    output reg end_flag;
    parameter largo = 9;
    parameter bus = 4;
    //output wire [largo-1:0] salida_contador;
    
    //  Declaración de estados
    parameter [bus-1:0]   a = 4'b0000,
                          b = 4'b0001,
                          c = 4'b0010,
                          d = 4'b0011,
                          e = 4'b0100,
                          f = 4'b0101,
                          g = 4'b0110,
                          h = 4'b0111,
                          i = 4'b1000,
                          j = 4'b1001,
                          k = 4'b1010,
                          l = 4'b1011,
                          m = 4'b1100,
                          n = 4'b1101,
                          o = 4'b1110;
    
    //  Registros internos                
    reg [bus-1:0] state_reg, state_next;
    reg AD, CS, WR, RD, Data;
    
    wire [8:0] contador;
    
    //  Instanciación del contador
    contador funcione(
        .contador(contador),
        .clk(clk),
        .reset(reset));
    
    //  Lógica secuencial del siguiente estado
    always @(posedge clk, posedge reset)
        if (reset)
            state_reg <= b;
        else
            state_reg <= state_next;          
            
    //  Lógica combinacional de los estados e implementación de las señales internas             
    always @*
    begin
        state_next = state_reg;
        
        //  Inicialización de las señales internas
        CS = 1'b1; 
        AD = 1'b1; 
        RD = 1'b1; 
        WR = 1'b1; 
        Data = 1'b0; 
        end_flag = 1'b0;    //  Bandera para indicar la finalización del ciclo de la FSM
        
        case (state_reg)        
            a : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (inicio)
                    state_next = b;
                else
                    state_next = a; 
                end
            b : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 10) begin
                    state_next = c;
                    AD = 0; end
                else
                    state_next = b;
                end
                                        
            c : begin
                AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 20) begin
                    state_next = d;
                    CS = 0; end  
                else 
                    state_next = c;
                end
                        
            d : begin
                CS = 0; AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 30) begin
                    state_next = e;
                    WR = 0; end                                                
                else
                    state_next = d;
                end
                        
            e : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b0; Data = 1'b0; end_flag = 1'b0;
                if (contador == 40) begin
                    state_next = f;
                    Data = 1; end   //  Se escribe la dirección de memoria
                else 
                    state_next = e;
                end
                        
            f : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b0; Data = 1'b1; end_flag = 1'b0;
                if (contador == 90) begin
                    state_next = g;
                    CS = 1; WR = 1; end
                else 
                    state_next = f;
                end
                        
            g : begin
                CS = 1'b1; AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 150) begin
                    state_next = h;
                    AD = 1; end
                else
                    state_next = g;
                end   
                           
            h : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 160) begin
                    state_next = i;
                    Data = 1'b0; end    //  Termina de escribirse la dirección de memoria
                else
                    state_next = h;
                end
                                
            i : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 170) begin
                    state_next = j;
                    CS = 0; end
                else
                    state_next = i;
                end
                        
            j : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 260) begin
                    state_next = k;
                    WR = 0; end
                else   
                    state_next = j;
                end
                
            k : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b0; Data = 1'b0; end_flag = 1'b0;
                if (contador == 280) begin
                    state_next = l;
                    Data = 1; end   //  Se escribe en esa dirección de memoria
                else
                    state_next = k;
                end
            
            l : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b0; Data = 1'b1; end_flag = 1'b0;
                if (contador == 300) begin
                    state_next = m;
                    WR = 1; end
                else
                    state_next = l;
                end
                
            m : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 310) begin
                    state_next = n;
                    CS = 1; end
                else
                    state_next = m;
                end
            
            n : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 350) begin
                    state_next = o;
                    Data = 1'b0; end    //  Termina de escribirse en esa dirección de memoria
                else
                    state_next = n;
                end
                    
            o : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 351) begin
                    state_next = a;
                    end_flag = 1; end   //  La bandera se activa para indicar que ya terminó el ciclo de escritura de la FSM
                else begin
                    state_next = o;
                    end 
                end
        endcase
    end
    assign CS_reg = CS;
    assign RD_reg = RD;
    assign WR_reg = WR;
    assign AD_reg = AD;
    assign Data_reg = Data;
    //assign salida_contador = contador;
endmodule
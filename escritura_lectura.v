`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2017 07:54:28 AM
// Design Name: 
// Module Name: escritura_lectura
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
module escritura_lectura(
    clk, reset,
    inicio,
    AD_reg, CS_reg, WR_reg, RD_reg, Data_reg, 
    end_flag,
    salida_contador
    );
    
    input wire clk, reset;
    input wire inicio;
    output wire AD_reg, CS_reg, WR_reg, RD_reg, Data_reg;   //  Registros de salida
    output reg end_flag;
    parameter largo = 9;
    parameter bus = 4;
    output wire [largo-1:0] salida_contador;    //  Contador de los tiempos del RTC
    
    //  Declaración de estados
    parameter [bus-1:0] a = 4'b0000,
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
                    o = 4'b1110,
                    p = 4'b1111;
    
    //  Registros internos                
    reg [3:0] state_reg, state_next;
    reg CS, AD, RD, WR, Data;
    
    wire [8:0] contador;
    
    //  Instanciación del contador    
    contador funcione2(
        .contador(contador),
        .clk(clk),
        .reset(reset));
    
    //  Lógica secuencial de siguiente estado
    always @(posedge clk, posedge reset)
        if (reset)
            state_reg <= a;
        else
            state_reg <= state_next;         
    
    //  Lógica combinacional para los estados e implementación de las señales que van hacia el RTC              
    always @*
    begin
        state_next = state_reg;
        
        //  Inicialización de las señales
        CS = 1'b1; 
        AD = 1'b1; 
        RD = 1'b1; 
        WR = 1'b1; 
        Data = 1'b0; 
        end_flag = 1'b0;    //  Bandera para indicar que la FSM terminó su ciclo
        
        case (state_reg)        
            a : begin   //  Estado a
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (inicio) //  Si la señal inicio está activa:
                    state_next = b;
                else
                    state_next = a; 
                end
            b : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                
                //  A PARTIR DE ACÁ INICIA EL CONTEO DE LOS TIEMPOS PARA EL CORRECTO PROCESO DE LECTURA
                if (contador == 10) begin   
                    state_next = c;
                    AD = 0; end
                else
                    state_next = b;
                end
                                        
            c : begin
                CS = 1'b1; AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 20) begin
                    state_next = d;
                    CS = 0; end  
                else 
                    state_next = c;
                end
                        
            d : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 30) begin
                    state_next = e;
                    WR = 0; end                                                
                else
                    state_next = d;
                end
                        
            e : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b0; Data = 1'b0; end_flag = 1'b0;
                if (contador == 70) begin
                    state_next = f;
                    Data = 1; end   //  Escribe la dirección en el RTC
                else 
                    state_next = e;
                end
                        
            f : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b0; Data = 1'b1; end_flag = 1'b0;
                if (contador == 100) begin
                    state_next = g;
                    WR = 1; end
                else 
                    state_next = f;
                end
                        
            g : begin
                CS = 1'b0; AD = 1'b0; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 110) begin
                    state_next = h;
                    AD = 1; end
                else
                    state_next = g;
                end   
                           
            h : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 120) begin
                    state_next = i;
                    CS = 1; end
                else
                    state_next = h;
                end
                                
            i : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 140) begin
                    state_next = j;
                    Data = 1'b0; end    //  Termina de escribir la dirección en el RTC
                else
                    state_next = i;
                end
                        
            j : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 200) begin
                    state_next = k;
                    CS = 0; end
                else   
                    state_next = j;
                end
                
            k : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 220) begin
                    state_next = l;
                    RD = 0; end
                else
                    state_next = k;
                end
            
            l : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b0; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 240) begin
                    state_next = m;
                    Data = 1; end   //  Se habilita el dato del RTC
                else
                    state_next = l;
                end
                
            m : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b0; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 280) begin
                    state_next = n;
                    RD = 1; end
                else
                    state_next = m;
                end
            
            n : begin
                CS = 1'b0; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 290) begin
                    state_next = o;
                    CS = 1; end
                else
                    state_next = n;
                end
                    
            o : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b1; end_flag = 1'b0;
                if (contador == 310) begin
                    state_next = p;
                    Data = 1'b0; end    //  Termina de habilitarse el dato del RTC
                else
                    state_next = o;
                end
            
            p : begin
                CS = 1'b1; AD = 1'b1; RD = 1'b1; WR = 1'b1; Data = 1'b0; end_flag = 1'b0;
                if (contador == 311) begin
                    state_next = a;
                    end_flag = 1; end   //  Como la FSM terminó su ciclo, activa esta bandera para decir "ya terminé de leer"
                else begin
                    state_next = p;
                    end 
                end
        endcase
    end
    
    //  Asignación de las señales del RTC a las señales internas de implementación
    assign AD_reg = AD;
    assign CS_reg = CS;
    assign WR_reg = WR;
    assign RD_reg = RD;
    assign Data_reg = Data;
    assign salida_contador = contador;
endmodule
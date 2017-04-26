`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2017 02:28:49 PM
// Design Name: 
// Module Name: timer
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
module timer(
    clk,
	reset,
	inicio,
	salida,
    CS, RD, WR, AD
    );
    
    parameter bus = 8;
    input clk;
    input reset;
    input inicio;
    output reg [bus-1:0] salida;
    output reg CS, RD, WR, AD;
    
    //  Señales internas
    reg [5:0] contador;
    reg [1:0] contadd;
    reg [7:0] direccion;
    reg inicio_reg;

    always @(posedge clk)
    begin
	   if (reset)
	       begin
	           CS<=1'h1;
	           RD<=1'h1;
	           WR<=1'h1;
	           AD<=1'h1;
	           salida<=8'hff;
	           contador<=0;
	           contadd<=0;
	           inicio_reg<=0;	
	           direccion<=8'h0f;
	       end
	   else if (inicio>inicio_reg) inicio_reg<=inicio;
	   else if (inicio_reg==1) 
	       begin
	           if (contador==0)
	           begin
	               case (contadd)
		              2'b00:direccion<=8'h43;
		              2'b01:direccion<=8'h42;
                	  2'b10:direccion<=8'h41; 
		              2'b11:direccion<=8'hf2;
		              default direccion<=8'h43;
	               endcase
	               CS<=1;
	               RD<=1;
	               WR<=1;
	               AD<=1;
	               contador<=contador+1'b1;
	           end
		else if (contador==1)
	       begin
		      AD<=0;
		      contador<=contador+1'b1;
	       end
	    else if(contador==2)
           begin
		      CS<=0;
		      contador<=contador+1'b1;
		   end
	    else if (contador==3)
		   begin
		      WR<=0;
		      contador<=contador+1'b1;
		   end
	    else if (contador==4)
		   begin
    		  salida<=direccion;
		      contador<=contador+1'b1;
		   end
	    else if (contador==9)
		   begin
		      WR<=1;
		      contador<=contador+1'b1;
		   end
	    else if (contador==10)
		   begin
		      CS<=1;
		      contador<=contador+1'b1;
		   end
	    else if (contador==11)
		   begin
		      AD<=1;
		      contador<=contador+1'b1;
		   end
	    else if (contador==13)
		   begin
		      salida<=8'hff;
		      contador<=contador+1'b1;
		   end
	    else if (contador==21)
		   begin
		      CS<=0;
		      contador<=contador+1'b1;
		   end
	    else if (contador==22)
		   begin
		      WR<=0;
              contador<=contador+1'b1;
		   end
    	else if (contador==23)
		    begin
		      case(contadd)
		          2'b00:salida<=8'h00;
		          2'b01:salida<=8'h00;
		          2'b10:salida<=8'h00; 
                  2'b11:salida<=8'hff;
		          default salida<=8'h00;
	          endcase
		   contador<=contador+1'b1;
		   end
	    else if (contador==28)
            begin
              WR<=1;
		      contador<=contador+1'b1;
		    end
	    else if (contador==29)
		    begin
		      CS<=1;
		      contador<=contador+1'b1;
		    end
	    else if (contador==31)
		    begin
		      salida<=8'hff;
		      contador<=contador+1'b1;
		    end
	    else if (contadd==3 && contador==40)
		    begin
		      contadd<=0;
		      contador<=0;
		      inicio_reg<=0;
		    end
	    else if (contador==40)
		    begin
		      contador<=0;
		      contadd<=contadd+1'b1;
		    end
	    else contador<=contador+1'b1;
    end
	else
	   begin
	   salida<=8'hff;
	   CS<=1'h1;
	   RD<=1'h1;
	   WR<=1'h1;
	   AD<=1'h1;
	end
    end
endmodule
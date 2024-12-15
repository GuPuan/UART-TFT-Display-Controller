`timescale 1ns / 1ns

module UART_RAM_TFT_tb(

    );
    
    reg Clk;
    reg Reset_n;
    reg uart_rx;
    wire [15:0]TFT_RGB;
    wire TFT_HS;
    wire TFT_VS;
    wire TFT_BLK;     
    wire TFT_CLK; 
    wire TFT_BL;
        
    
    UART_RAM_TFT    UART_RAM_TFT(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .uart_rx(uart_rx),
        .TFT_RGB(TFT_RGB),  
        .TFT_HS(TFT_HS),    
        .TFT_VS(TFT_VS),    
        .TFT_DE(TFT_BLK),   
        .TFT_CLK(TFT_CLK),
        .TFT_BL(TFT_BL)     
    );
    
    initial Clk = 1;
    always#10 Clk = ~Clk;
    
    initial begin
        Reset_n = 0;
        #201;
        Reset_n = 1;
        
        #20000000;
        $stop;
    end    
    
endmodule

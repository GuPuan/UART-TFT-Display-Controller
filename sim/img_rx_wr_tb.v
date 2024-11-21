`timescale 1ns / 1ps

module img_rx_wr_tb();

    reg Clk;
    reg Reset_n;
    reg [7:0]rx_data;
    reg rx_done;
    wire  ram_wren;
    wire [15:0]ram_wraddr;
    wire [15:0]ram_wrdata;
    
    img_rx_wr img_rx_wr(
        Clk,
        Reset_n,
        rx_data,
        rx_done,
        ram_wren,
        ram_wraddr,
        ram_wrdata
    );

    initial Clk = 1;
    always#10 Clk = ~Clk;
    
    initial begin
        Reset_n = 0;
        rx_data = 0;
        rx_done = 0;
        #201;
        Reset_n = 1;
        #2000;
        rx_data = 255;
        repeat(131072)begin
            rx_done = 1;
            #20;
            rx_done = 0;
            #200;
            rx_data = rx_data -1;
        end
        #20000;
        
        repeat(131072)begin
            rx_done = 1;
            #20;
            rx_done = 0;
            #200;
            rx_data = rx_data -1;
        end
        $stop;
    
    end
    
    


endmodule

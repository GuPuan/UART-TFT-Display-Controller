`timescale 1ns/1ps

module uart_byte_rx_tb;

    parameter CLOCK_FREQ = 50_000_000; 
    parameter BAUD = 115200;           
    parameter CLOCK_PERIOD = 20;      
    parameter BIT_PERIOD = 1_000_000_000 / BAUD; 

    reg Clk;
    reg Reset_n;
    reg uart_rx;

    wire Rx_Done;
    wire [7:0] Rx_Data;
    wire Frame_Error;

    uart_byte_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD(BAUD)
    ) uut (
        .Clk(Clk),
        .Reset_n(Reset_n),
        .uart_rx(uart_rx),
        .Rx_Done(Rx_Done),
        .Rx_Data(Rx_Data),
        .Frame_Error(Frame_Error)
    );

    initial begin
        Clk = 0;
        forever #(CLOCK_PERIOD / 2) Clk = ~Clk;
    end

    initial begin
        Reset_n = 0;
        uart_rx = 1; 

        #(10 * CLOCK_PERIOD);
        Reset_n = 1;

        send_uart_byte(8'b10101010); 
        #(10 * BIT_PERIOD);         

        send_uart_byte(8'b11001100); 
        #(10 * BIT_PERIOD);

//        send_uart_byte_with_error(8'b11110000); 
//        #(10 * BIT_PERIOD);

        send_uart_byte(8'b10111011);
        #(10 * BIT_PERIOD);
        #(100 * CLOCK_PERIOD);
        $stop;
    end

   
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            uart_rx = 0; 
            #(BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_PERIOD);
            end

            uart_rx = 1; 
            #(BIT_PERIOD);
        end
    endtask

    task send_uart_byte_with_error(input [7:0] data);
        integer i;
        begin
            uart_rx = 0;             #(BIT_PERIOD);

            
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_PERIOD);
            end

            uart_rx = 0;
            #(BIT_PERIOD);
        end
    endtask

endmodule
`timescale 1ns / 1ps

module UART_FIFO_TFT_tb();

    reg Clk;
    reg Reset_n;
    reg uart_rx;
    wire [15:0] TFT_RGB;
    wire TFT_HS;
    wire TFT_VS;
    wire TFT_DE;
    wire TFT_CLK;
    wire TFT_BL;
    wire [11:0] hcount_r;
    wire [11:0] vcount_r;

    // Clock generation (50 MHz)
    initial begin
        Clk = 0;
        forever #10 Clk = ~Clk; // 50 MHz clock
    end

    // Reset signal
    initial begin
        Reset_n = 0;
        #100 Reset_n = 1; // Release reset after 100 ns
    end

    // UART RX signal generation
    initial begin
        uart_rx = 1; // UART idle state is high
        #200;

        // Send 16 16-bit data (131072 8-bit data)
        send_uart_16bit_data(16);
    end

    // UART byte transmission task
    task uart_byte(input [7:0] data);
        integer i;
        begin
            uart_rx = 0; // Start bit
            #8680;       // Baud rate: 115200 bps (1/115200 = 8680 ns)

            // Send data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #8680;
            end

            uart_rx = 1; // Stop bit
            #8680;
        end
    endtask

    // Task to send multiple 16-bit data
    task send_uart_16bit_data(input integer num_data);
        integer i;
        reg [15:0] data;
        begin
            for (i = 0; i < num_data; i = i + 1) begin
                data = i[15:0]; // Generate 16-bit data (e.g., 0x0000 to 0xFFFF)              
                uart_byte(data[15:8]); // Send upper 8 bits
                uart_byte(data[7:0]);   // Send lower 8 bits
            end
        end
    endtask

    // Instantiate the DUT (Device Under Test)
    UART_RAM_TFT uut (
        .Clk(Clk),
        .Reset_n(Reset_n),
        .uart_rx(uart_rx),
        .TFT_RGB(TFT_RGB),
        .TFT_HS(TFT_HS),
        .TFT_VS(TFT_VS),
        .TFT_DE(TFT_DE),
        .TFT_CLK(TFT_CLK),
        .TFT_BL(TFT_BL),
        .hcount_r(hcount_r),
        .vcount_r(vcount_r)
    );

endmodule
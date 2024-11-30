`timescale 1ns / 1ps

module UART_RAM_TFT(
    Clk,          // Input clock
    Reset_n,      // Active-low reset signal
    uart_rx,      // UART receive input
    TFT_RGB,      // Output data to TFT (16-bit RGB)
    TFT_HS,       // Horizontal sync signal for TFT
    TFT_VS,       // Vertical sync signal for TFT
    TFT_DE,       // Data enable signal for TFT
    TFT_CLK,      // Pixel clock for TFT
    TFT_BL,       // Backlight enable signal for TFT
    hcount_r,     // Horizontal pixel count (raw)
    vcount_r      // Vertical line count (raw)
);

    input Clk;
    input Reset_n;
    input uart_rx;
    output [15:0] TFT_RGB;
    output TFT_HS;
    output TFT_VS;
    output TFT_DE;
    output TFT_CLK;
    output TFT_BL;
    output [11:0] hcount_r;
    output [11:0] vcount_r;

    // Internal signals
    wire [7:0] rx_data;       // Data received via UART
    wire rx_done;             // UART receive complete signal
    wire ram_wren;            // RAM write enable
    wire [15:0] ram_wraddr;   // RAM write address
    wire [15:0] ram_wrdata;   // Data to write into RAM
    reg [15:0] ram_rdaddr;    // RAM read address
    wire Clk_TFT;             // Clock for TFT controller
    wire Data_req;
    wire [15:0] ram_rddata;   // Data read from RAM
    wire [11:0] hcount, vcount; // Horizontal and vertical counts
    wire ram_data_en;         // Enable signal for RAM data read
    wire [15:0] disp_data;    // Data to display on TFT
    wire locked;              // Clock locked signal
    wire write_done;          // Write completion signal for RAM

    // Clock management using MMCM
    MMCM MMCM(
        .clk_out1(Clk_TFT),     // Output clock for TFT controller
        .reset(!Reset_n),       // Reset signal
        .locked(locked),        // Locked signal to indicate stable clock
        .clk_in1(Clk)           // Input system clock
    );

    // UART byte receiver
    uart_byte_rx uart_byte_rx(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .uart_rx(uart_rx),
        .Rx_Data(rx_data),      // Received byte
        .Rx_Done(rx_done)       // Signal indicating a byte was received
    );

    // Image reception and RAM write controller
    img_rx_wr #( .DATA_COUNT_LIMIT(16'hF)) img_rx_wr (
        .Clk(Clk),
        .Reset_n(Reset_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .ram_wren(ram_wren),        // Write enable signal for RAM
        .ram_wraddr(ram_wraddr),    // RAM write address
        .ram_wrdata(ram_wrdata),    // RAM write data
        .write_done(write_done)     // Write completion signal
    );

    // FIFO for data synchronization
    SyncFIFO #(
        .DATA_WIDTH(16),            // Data width for FIFO
        .ADDR_WIDTH(16)             // Address width for FIFO
    ) SyncFIFO_inst (
        .clk(Clk),                  // Clock signal
        .reset_n(Reset_n),          // Active-low reset
        .wr_en(ram_wren),           // Write enable signal
        .rd_en(ram_data_en),        // Read enable signal
        .data_in(ram_wrdata),       // Data input
        .data_out(ram_rddata),      // Data output
        .full(),                    // Optional: FIFO full flag
        .empty()                    // Optional: FIFO empty flag
    );

    // RAM read address increment logic
    always @(posedge Clk_TFT or negedge Reset_n)
    if (!Reset_n)
        ram_rdaddr <= 0;            // Reset read address
    else if (ram_data_en)
        ram_rdaddr <= ram_rdaddr + 1'd1; // Increment read address when enabled

    // Enable reading from RAM only within active display area
    assign ram_data_en = Data_req && (hcount >= 272 && hcount < 528) &&
                         (vcount >= 112 && vcount < 368);

    // Data to display on TFT
    assign disp_data = ram_data_en ? ram_rddata : 16'h0000;

    // TFT controller
    TFT_CTRL TFT_CTRL(
        .CLK_33M         (Clk_TFT),         // Clock for TFT controller
        .Reset_n         (Reset_n),         // Reset signal
        .Data_in         (disp_data),       // Data to display
        .Data_start      (write_done),      // Signal to start displaying data
        .Data_req        (Data_req),        // Signal requesting data
        .hcount          (hcount),          // Horizontal counter
        .vcount          (vcount),          // Vertical counter
        .TFT_HS          (TFT_HS),          // Horizontal sync signal
        .TFT_VS          (TFT_VS),          // Vertical sync signal
        .TFT_DE          (TFT_DE),          // Data enable signal
        .TFT_CLK         (TFT_CLK),         // Pixel clock
        .TFT_DATA        (TFT_RGB),         // Data to output on TFT
        .TFT_BL          (TFT_BL),          // Backlight enable
        .hcount_r        (hcount_r),        // Raw horizontal counter
        .vcount_r        (vcount_r)         // Raw vertical counter
    );

endmodule
`timescale 1ns / 1ps
`include "disp_parameter_cfg.v" // Include display parameter configuration file

module TFT_CTRL(
    CLK_33M,           // 33 MHz clock input
    Reset_n,           // Active-low reset signal
    Data_in,           // Input pixel data (16-bit)
    Data_start,        // Signal to start data processing
    Data_req,          // Signal requesting new data
    hcount,            // Current horizontal pixel count (valid data range)
    vcount,            // Current vertical line count (valid data range)
    TFT_HS,            // TFT horizontal sync signal
    TFT_VS,            // TFT vertical sync signal
    TFT_DE,            // TFT data enable signal
    TFT_CLK,           // TFT pixel clock
    TFT_DATA,          // TFT output data (16-bit)
    TFT_BL,            // TFT backlight enable
    hcount_r,          // Current raw horizontal count
    vcount_r           // Current raw vertical count
);

    input                   CLK_33M;        // System clock at 33 MHz
    input                   Reset_n;        // Active-low reset
    input           [15:0]  Data_in;        // 16-bit pixel data input
    input                   Data_start;     // Start signal for data processing
    output  reg             Data_req;       // Request for new data
    output      [11:0]      hcount;         // Horizontal data counter (valid range)
    output      [11:0]      vcount;         // Vertical data counter (valid range)
    output  reg             TFT_HS;         // Horizontal sync signal
    output  reg             TFT_VS;         // Vertical sync signal
    output                  TFT_DE;         // Data enable signal
    output                  TFT_CLK;        // Pixel clock (inverted 33 MHz)
    output      [15:0]      TFT_DATA;       // Output pixel data
    output                  TFT_BL;         // Backlight enable (always on)
    output reg  [11:0]      hcount_r;       // Raw horizontal counter
    output reg  [11:0]      vcount_r;       // Raw vertical counter

    // Timing parameters loaded from configuration file
    parameter 
           VGA_HS_end   = `H_Sync_Time - 1,   // Horizontal sync end time
           hdat_begin   = `H_Sync_Time + `H_Back_Porch + `H_Left_Border, // Start of active horizontal data
           hdat_end     = `H_Sync_Time + `H_Back_Porch + `H_Left_Border + `H_Data_Time, // End of active horizontal data
           hpixel_end   = `H_Total_Time - 1,  // Total horizontal pixels per line
           VGA_VS_end   = `V_Sync_Time - 1,   // Vertical sync end time
           vdat_begin   = `V_Sync_Time + `V_Back_Porch + `V_Top_Border, // Start of active vertical data
           vdat_end     = `V_Sync_Time + `V_Back_Porch + `V_Top_Border + `V_Data_Time, // End of active vertical data
           vline_end    = `V_Total_Time - 1;  // Total vertical lines per frame

    // Horizontal counter: Tracks the current pixel position in a line
    always @ (posedge CLK_33M or negedge Reset_n)
        if (!Reset_n)
            hcount_r <= 11'd0; // Reset counter
        else if (hcount_r == hpixel_end)
            hcount_r <= 11'd0; // Reset at the end of a line
        else if (Data_start)
            hcount_r <= hcount_r + 1'd1; // Increment counter if data processing is started

    // Vertical counter: Tracks the current line in a frame
    always @ (posedge CLK_33M or negedge Reset_n)
        if (!Reset_n)
            vcount_r <= 11'd0; // Reset counter
        else if (hcount_r == hpixel_end) begin
            if (vcount_r == vline_end)
                vcount_r <= 11'd0; // Reset at the end of a frame
            else
                vcount_r <= vcount_r + 1'd1; // Increment counter at the end of a line
        end

    // TFT clock: Inverted 33 MHz clock
    assign TFT_CLK = ~CLK_33M;

    // Data request signal: Active during valid horizontal and vertical data periods
    always @ (posedge CLK_33M)
        Data_req <= ((hcount_r >= (hdat_begin - 1)) && (hcount_r < (hdat_end - 1)) && 
                     (vcount_r >= vdat_begin) && (vcount_r < vdat_end)) ? 1'b1 : 1'b0;

    // Horizontal and vertical data counters: Valid data range
    assign hcount = Data_req ? (hcount_r - hdat_begin) : 10'd0;
    assign vcount = Data_req ? (vcount_r - vdat_begin) : vcount;

    // Data enable signal: Active when Data_req is high
    assign TFT_DE = Data_req;

    // Output pixel data: Active pixel data when TFT_DE is high, 0 otherwise
    assign TFT_DATA = (TFT_DE) ? Data_in : 16'h0000;

    // Horizontal sync signal: Active during non-active horizontal period
    always@(posedge CLK_33M)
        TFT_HS <= ((VGA_HS_end <= hcount_r) && (hcount_r < hpixel_end)) ? 1 : 0;

    // Vertical sync signal: Active during non-active vertical period
    always@(posedge CLK_33M)
        TFT_VS <= ((VGA_VS_end < vcount_r) && (vcount_r < vline_end)) ? 1 : 0;

    // Backlight enable signal: Always on
    assign TFT_BL = 1;

endmodule
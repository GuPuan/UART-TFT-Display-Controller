module img_rx_wr #(
    parameter DATA_COUNT_LIMIT = 16'hFFFF // Limit for the number of data words
    )
(
    input               Clk,           // System clock
    input               Reset_n,       // Active-low reset signal
    input       [7:0]   rx_data,       // 8-bit received data
    input               rx_done,       // Signal indicating data reception is complete
    output reg          ram_wren,      // Write enable for RAM
    output reg  [15:0]  ram_wraddr,    // RAM write address
    output      [15:0]  ram_wrdata,    // RAM write data
    output reg write_done              // Signal indicating writing is done
);

    reg [16:0] data_cnt;         // Counter for received data bytes
    reg [15:0] rx_data_tmp;      // Temporary storage for two concatenated bytes of data

    // Increment the data counter on each received byte
    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n) 
            data_cnt <= 0;       // Reset data counter
        else if (rx_done)
            data_cnt <= data_cnt + 1; // Increment counter on reception
    end

    // Concatenate received bytes into a 16-bit word
    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n) 
            rx_data_tmp <= 0;    // Reset temporary data storage
        else if (rx_done)
            rx_data_tmp <= {rx_data_tmp[7:0], rx_data}; // Shift and store new byte
    end

    // Generate RAM write enable signal for every second byte
    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n) 
            ram_wren <= 0;       // Reset RAM write enable signal
        else
            ram_wren <= rx_done && data_cnt[0]; // Enable on odd data count
    end

    // Calculate RAM write address based on half of the data count
    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n) 
            ram_wraddr <= 0;     // Reset RAM write address
        else if (rx_done && data_cnt[0])
            ram_wraddr <= data_cnt[16:1]; // Address = data count / 2
    end

    // Set write_done when the data count reaches the limit
    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n)
            write_done <= 0;     // Reset write completion signal
        else if (data_cnt[16:1] == DATA_COUNT_LIMIT)
            write_done <= 1;     // Set when address limit is reached
    end

    // Assign concatenated data as the RAM write data
    assign ram_wrdata = rx_data_tmp;

endmodule
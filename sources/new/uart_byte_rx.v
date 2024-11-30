module uart_byte_rx(
    input Clk,              // System clock signal
    input Reset_n,          // Active-low reset signal
    input uart_rx,          // UART receive signal
    output reg Rx_Done,     // Output signal indicating data reception is complete
    output reg [7:0] Rx_Data, // Output register to hold received 8-bit data
    output reg Frame_Error  // Output signal indicating a framing error
);

    // Parameters for UART configuration
    parameter CLOCK_FREQ = 50_000_000;  // System clock frequency in Hz
    parameter BAUD = 115200;            // UART baud rate
    parameter MCNT_BAUD = CLOCK_FREQ / BAUD - 1; // Clock cycles per UART baud period

    // Internal registers for state and data management
    reg [7:0] r_Rx_Data;                // Temporary register to store received data bits
    reg [29:0] baud_div_cnt;            // Baud rate clock divider counter
    reg en_baud_cnt;                    // Enable signal for baud rate counter
    reg [3:0] bit_cnt;                  // Counter for the number of bits received
    reg dff0_uart_rx, dff1_uart_rx;     // Flip-flops for UART input synchronization
    reg r_uart_rx;                      // Previous state of UART input

    // Internal wires for edge detection and reception completion
    wire nedge_uart_rx;                 // Negative edge detection signal for UART input
    wire w_Rx_Done;                     // Signal indicating the entire byte has been received

    // Sequential block: Reset and state machine for UART reception
    always @(posedge Clk or negedge Reset_n)
        if (!Reset_n) begin
            // Reset all registers to initial states
            baud_div_cnt <= 0;
            en_baud_cnt <= 0;
            bit_cnt <= 0;
            r_Rx_Data <= 8'd0;
            Rx_Data <= 8'd0;
            Rx_Done <= 0;
            Frame_Error <= 0;
        end else begin
            // Handle baud rate counter
            if (en_baud_cnt) begin
                if (baud_div_cnt == MCNT_BAUD)
                    baud_div_cnt <= 0; // Reset counter when baud rate period is complete
                else
                    baud_div_cnt <= baud_div_cnt + 1; // Increment baud rate counter
            end else begin
                baud_div_cnt <= 0; // Reset counter when disabled
            end

            // Handle bit reception logic
            if (en_baud_cnt && baud_div_cnt == MCNT_BAUD) begin
                if (bit_cnt == 9) 
                    bit_cnt <= 0; // Reset bit counter after full byte and stop bit
                else
                    bit_cnt <= bit_cnt + 1; // Increment bit counter
            end

            // Sample UART data in the middle of each bit period
            if (baud_div_cnt == MCNT_BAUD / 2) begin
                case (bit_cnt)
                    1: r_Rx_Data[0] <= dff1_uart_rx; // LSB
                    2: r_Rx_Data[1] <= dff1_uart_rx;
                    3: r_Rx_Data[2] <= dff1_uart_rx;
                    4: r_Rx_Data[3] <= dff1_uart_rx;
                    5: r_Rx_Data[4] <= dff1_uart_rx;
                    6: r_Rx_Data[5] <= dff1_uart_rx;
                    7: r_Rx_Data[6] <= dff1_uart_rx;
                    8: r_Rx_Data[7] <= dff1_uart_rx; // MSB
                    default: r_Rx_Data <= r_Rx_Data; // Default case
                endcase
            end

            // Handle reception completion
            if (w_Rx_Done) begin
                Rx_Done <= 1; // Signal that reception is complete
                Rx_Data <= r_Rx_Data; // Update output data register
                if (dff1_uart_rx != 1'b1) // Check stop bit for framing error
                    Frame_Error <= 1;
                else
                    Frame_Error <= 0;
            end else begin
                Rx_Done <= 0; // Clear reception complete signal
            end

            // Enable baud counter on negative edge of UART input
            if (nedge_uart_rx)
                en_baud_cnt <= 1;
            else if (bit_cnt == 9 && baud_div_cnt == MCNT_BAUD)
                en_baud_cnt <= 0; // Disable counter after stop bit
        end

    // Synchronize UART input and detect negative edges
    always @(posedge Clk) begin
        dff0_uart_rx <= uart_rx;         // First stage flip-flop
        dff1_uart_rx <= dff0_uart_rx;   // Second stage flip-flop
        r_uart_rx <= dff1_uart_rx;      // Store previous state of synchronized signal
    end

    // Negative edge detection for UART input
    assign nedge_uart_rx = (dff1_uart_rx == 0) && (r_uart_rx == 1);

    // Determine if reception is done (end of stop bit)
    assign w_Rx_Done = (bit_cnt == 9 && baud_div_cnt == MCNT_BAUD / 2);

endmodule
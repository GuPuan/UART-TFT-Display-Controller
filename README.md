# UART to TFT Display with FIFO Buffer and Multi-Resolution Support

## Overview
This system receives image data over a UART interface, stores it in a FIFO buffer, and displays it on a TFT screen. The image data is transferred to the TFT display only after the entire image has been received. The system supports multiple display resolutions and allows specifying the output position of the image on the screen.

## Key Features
- **UART Image Reception**: Receives image data byte-by-byte via UART.
- **FIFO Buffer**: Temporarily stores the received image data until fully received, ensuring smooth display.
- **Multi-Resolution Support**: Supports different TFT resolutions (configurable).
- **Display Positioning**: Allows specifying the output position of the image on the screen.
- **TFT Controller**: Handles horizontal sync (HS), vertical sync (VS), and data enable (DE) signals for the TFT.
- **Clock Generation**: MMCM generates the required clock for the TFT display.

## Components
1. **UART Receiver (`uart_byte_rx`)**: Receives image data byte-by-byte.
2. **FIFO Buffer (`SyncFIFO`)**: Temporarily stores the received image data.
3. **Image Write Controller (`img_rx_wr`)**: Writes the received data to RAM after UART reception.
4. **RAM**: Stores the image data before displaying it on the TFT screen.
5. **TFT Controller (`TFT_CTRL`)**: Manages the TFT display and handles image rendering.
6. **MMCM**: Generates the clock for the TFT display.

## Workflow
1. **Receive Data**: Image data is received over UART and stored in the FIFO buffer.
2. **Write to RAM**: Once all data is received, the `img_rx_wr` module writes the data into RAM.
3. **Display Image**: The `TFT_CTRL` module reads the image data from RAM and displays it on the TFT screen, with the specified resolution and output position.
4. **Multi-Resolution Support**: The system can be configured to support different TFT resolutions (e.g., 480x320, 800x600), and the image can be displayed at a specified screen position.

## Configuration
- **Resolution Support**: The system supports multiple TFT resolutions. Common resolutions (e.g., 480x320, 800x600) can be set by modifying the configuration parameters in the `TFT_CTRL` module.
- **Positioning**: The image can be displayed at a specific position on the screen by configuring the starting pixel coordinates in the `TFT_CTRL` module.

## Inputs/Outputs

### Inputs
- **`Clk`**: System clock input.
- **`Reset_n`**: Active-low reset signal.
- **`uart_rx`**: UART input for receiving image data.

### Outputs
- **`TFT_RGB`**: 16-bit RGB data to be displayed on the TFT.
- **`TFT_HS`**: Horizontal sync signal for the TFT display.
- **`TFT_VS`**: Vertical sync signal for the TFT display.
- **`TFT_DE`**: Data enable signal for the TFT display.
- **`TFT_CLK`**: Pixel clock signal for the TFT display.
- **`TFT_BL`**: Backlight enable signal for the TFT display.
- **`hcount_r`**: Raw horizontal pixel count.
- **`vcount_r`**: Raw vertical pixel count.


## Example Use Case

1. **UART Data Transmission**: Connect a UART source (e.g., a microcontroller) to the `uart_rx` pin and send image data in a predefined format.
2. **Receive Image Data**: The system will receive the image data byte-by-byte and store it in the FIFO buffer.
3. **Image Writing**: After the entire image is received, the `img_rx_wr` module writes the data into RAM.
4. **Image Display**: The `TFT_CTRL` module reads the data from RAM and displays it on the TFT screen. The image can be configured to appear at a specific location and can be scaled according to the resolution.

## Clocking

The system uses an **MMCM** (Mixed-Mode Clock Manager) to generate the necessary clock (`Clk_TFT`) for the TFT display. The input clock (`Clk`) is processed by the MMCM to produce a stable pixel clock for the TFT controller.

## Conclusion

This system provides an efficient way to display image data received over UART on a TFT display. It supports multiple resolutions, flexible positioning, and smooth data handling using a FIFO buffer. The configuration options allow easy adaptation for different display sizes and layouts.




# UART-TFT Display Controller

This project implements a **UART-TFT Display Controller** using Verilog. It facilitates displaying data received over a UART interface on a TFT screen. The design is modular and configurable, supporting various screen resolutions and sizes.

---

## Features

- **UART Receiver**: Captures 8-bit serial data via UART.
- **FIFO Buffer**: Manages and synchronizes data between UART and TFT.
- **TFT Controller**: Drives RGB pixel data and timing signals to the TFT screen.
- **Clock Management**: Generates a stable pixel clock for the TFT controller using MMCM.
- **Configurable Parameters**: Easily adjust timing settings for different TFT displays.

---

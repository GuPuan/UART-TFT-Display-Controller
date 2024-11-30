`timescale 1ns/1ps

module uart_byte_rx_tb;

    // 参数定义
    parameter CLOCK_FREQ = 50_000_000; // 系统时钟频率
    parameter BAUD = 115200;           // 波特率
    parameter CLOCK_PERIOD = 20;      // 时钟周期（50MHz -> 20ns）
    parameter BIT_PERIOD = 1_000_000_000 / BAUD; // 位周期（波特率115200）

    // 输入信号
    reg Clk;
    reg Reset_n;
    reg uart_rx;

    // 输出信号
    wire Rx_Done;
    wire [7:0] Rx_Data;
    wire Frame_Error;

    // 实例化被测模块
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

    // 时钟生成
    initial begin
        Clk = 0;
        forever #(CLOCK_PERIOD / 2) Clk = ~Clk;
    end

    // 初始化和测试输入信号
    initial begin
        // 初始化信号
        Reset_n = 0;
        uart_rx = 1; // 默认高电平（空闲状态）

        // 复位
        #(10 * CLOCK_PERIOD);
        Reset_n = 1;

        // 模拟数据帧传输
        send_uart_byte(8'b10101010); // 发送字节：0xAA (起始位+数据位+停止位)
        #(10 * BIT_PERIOD);         // 间隔一段时间

        send_uart_byte(8'b11001100); // 发送字节：0xCC
        #(10 * BIT_PERIOD);

//        send_uart_byte_with_error(8'b11110000); // 发送字节：0xF0，带停止位错误
//        #(10 * BIT_PERIOD);

        send_uart_byte(8'b10111011);
        #(10 * BIT_PERIOD);
        // 停止仿真
        #(100 * CLOCK_PERIOD);
        $stop;
    end

    // 模拟发送一个字节数据（含起始位和停止位）
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            uart_rx = 0; // 起始位
            #(BIT_PERIOD);

            // 发送数据位（低位在前）
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_PERIOD);
            end

            uart_rx = 1; // 停止位
            #(BIT_PERIOD);
        end
    endtask

    // 模拟发送一个字节数据（带停止位错误）
    task send_uart_byte_with_error(input [7:0] data);
        integer i;
        begin
            uart_rx = 0; // 起始位
            #(BIT_PERIOD);

            // 发送数据位（低位在前）
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_PERIOD);
            end

            uart_rx = 0; // 错误的停止位（应为高电平）
            #(BIT_PERIOD);
        end
    endtask

endmodule
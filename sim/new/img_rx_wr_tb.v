`timescale 1ns / 1ps

module img_rx_wr_tb;

    // Inputs
    reg Clk;
    reg Reset_n;
    reg [7:0] rx_data;
    reg rx_done;

    // Outputs
    wire ram_wren;
    wire [15:0] ram_wraddr;
    wire [15:0] ram_wrdata;
    wire led;

    // Instantiate the Unit Under Test (UUT)
    img_rx_wr uut (
        .Clk(Clk),
        .Reset_n(Reset_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .ram_wren(ram_wren),
        .ram_wraddr(ram_wraddr),
        .ram_wrdata(ram_wrdata),
        .led(led)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #10 Clk = ~Clk; // 100MHz clock, 10ns period
    end

    // Reset and input stimulus
    initial begin
        // Initialize inputs
        Reset_n = 0;
        rx_data = 0;
        rx_done = 0;

        // Reset
        #20;
        Reset_n = 1;

        // Simulate receiving data
        #20;
        send_data(8'hAA); // First byte
        send_data(8'hBB); // Second byte -> Forms 16'hAABB
        #10;

        send_data(8'hCC); // Third byte
        send_data(8'hDD); // Fourth byte -> Forms 16'hCCDD
        #10;

        send_data(8'hEE); // Fifth byte
        send_data(8'hFF); // Sixth byte -> Forms 16'hEEFF
        #10;

        // Simulate data count reaching max
        repeat (65536) begin
            send_data(8'h11);
            send_data(8'h22);
        end

        #50;
        $finish; // End simulation
    end

    // Task to simulate data reception
    task send_data(input [7:0] data);
        begin
            rx_data = data;
            rx_done = 1;
            #10;
            rx_done = 0;
            #10;
        end
    endtask

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | rx_data: %h | ram_wraddr: %h | ram_wrdata: %h | ram_wren: %b | led: %b",
                 $time, rx_data, ram_wraddr, ram_wrdata, ram_wren, led);
    end

endmodule
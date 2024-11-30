`timescale 1ns / 1ps

module SyncFIFO_tb;

    // Parameters
    localparam DATA_WIDTH = 16;
    localparam ADDR_WIDTH = 4; // Use a smaller depth for simulation

    // Signals
    reg clk;
    reg reset_n;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    // Instantiate the DUT (Device Under Test)
    SyncFIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Apply reset
        #20;
        reset_n = 1;

        // Test 1: Write and fill the FIFO
        $display("Starting Test 1: Writing to FIFO");
        repeat ((1 << ADDR_WIDTH)) begin
            @(posedge clk);
            if (!full) begin
                wr_en = 1;
                data_in = data_in + 1;
                $display("Writing data: %d to address : %d", data_in, dut.wr_index);
            end else begin
                wr_en = 0;
            end
        end
        @(posedge clk);
        wr_en = 0;
        $display("Finished Test 1");

        // Test 2: Read from the FIFO
        $display("Starting Test 2: Reading from FIFO");
        repeat ((1 << ADDR_WIDTH)) begin
            @(posedge clk);
            if (!empty) begin
                rd_en = 1;
                $display("Reading data: %d from address : %d", data_out, dut.rd_index);
            end else begin
                rd_en = 0;
            end
        end
        @(posedge clk);
        rd_en = 0;
        $display("Finished Test 2");

        // Test 3: Write and read simultaneously
        $display("Starting Test 3: Simultaneous Write and Read");
        reset_n = 0;
        #20;
        reset_n = 1;
        data_in = 0;
        repeat ((1 << (ADDR_WIDTH - 1))) begin
            @(posedge clk);
            if (!full) begin
                wr_en = 1;
                data_in = data_in + 1;
                $display("Writing data: %d to address : %d", data_in, dut.wr_index);
            end
            if (!empty) begin
                rd_en = 1;
                 $display("Reading data: %d from address : %d", data_out, dut.rd_index);
            end
        end
        @(posedge clk);
        wr_en = 0;
        rd_en = 0;
        $display("Finished Test 3");

        // End simulation
        $stop;
    end

endmodule
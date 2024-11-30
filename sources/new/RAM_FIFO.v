module SyncFIFO #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16 // 256x256 depth implies 8-bit address
)(
    input wire clk,
    input wire reset_n,
    input wire wr_en, // Write enable
    input wire rd_en, // Read enable
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire full,
    output wire empty
);

    // FIFO depth
    localparam FIFO_DEPTH = (1 << ADDR_WIDTH);

    // FIFO memory
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

    // Write and Read Pointers
    reg [ADDR_WIDTH:0] wr_ptr; // Extra bit to detect full condition
    reg [ADDR_WIDTH:0] rd_ptr; // Extra bit to detect empty condition

    // Write and Read Pointers without MSB for indexing
    wire [ADDR_WIDTH-1:0] wr_index = wr_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] rd_index = rd_ptr[ADDR_WIDTH-1:0];

    // Full and Empty logic
    assign full = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                  (wr_index == rd_index);
    assign empty = (wr_ptr == rd_ptr);

    // Write operation
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_index] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_index];
            rd_ptr <= rd_ptr + 1;
        end
    end

endmodule
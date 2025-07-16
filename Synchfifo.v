module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,                      // FIFO depth (number of entries)
    parameter ADDR_WIDTH = $clog2(DEPTH)      // Automatically calculate address width
)(
    input wire clk,
    input wire rst,

    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,

    output reg [DATA_WIDTH-1:0] dout,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr, rd_ptr; // extra bit to differentiate full/empty

    wire [ADDR_WIDTH-1:0] wr_addr = wr_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] rd_addr = rd_ptr[ADDR_WIDTH-1:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            full <= 0;
            empty <= 1;
        end else begin
            // Write operation
            if (wr_en && !full) begin
                mem[wr_addr] <= din;
                wr_ptr <= wr_ptr + 1;
            end

            // Read operation
            if (rd_en && !empty) begin
                dout <= mem[rd_addr];
                rd_ptr <= rd_ptr + 1;
            end

            // Status logic
            full <= ((wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                     (wr_addr == rd_addr));
            empty <= (wr_ptr == rd_ptr);
        end
    end

endmodule



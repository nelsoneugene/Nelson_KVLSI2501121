`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;
    parameter ADDR_WIDTH = $clog2(DEPTH);

    reg clk = 0;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    // Clock generation
    always #5 clk = ~clk;

    // DUT instantiation
    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    integer i;

    initial begin
        $dumpfile("sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        // Reset
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0; #20;

        rst = 0;
        #10;

        // Write 8 values
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            if (!full) begin
                wr_en = 1;
                din = i + 10;
            end
        end
        @(negedge clk);
        wr_en = 0;

        // Wait before reading
        #20;

        // Read 8 values
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            if (!empty) begin
                rd_en = 1;
            end
        end
        @(negedge clk);
        rd_en = 0;

        #20;
        $finish;
    end

endmodule

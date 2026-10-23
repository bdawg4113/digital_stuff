`timescale 1ns/1ps
`include "fifo_top.sv"

module fifo_tb;
    localparam DEPTH = 16, DATA_WIDTH = 8;

    logic                   wclk = 0, rclk = 0;
    logic                   wrst_n = 0, rrst_n = 0;
    logic                   w_en = 0, r_en = 0;
    logic [DATA_WIDTH-1:0]  data_in = 0;
    logic [DATA_WIDTH-1:0]  data_out;
    logic                   full, empty;

    async_fifo #(DEPTH, DATA_WIDTH) dut (.*);

    always #5  wclk = ~wclk;    // 100 MHz
    always #8  rclk = ~rclk;    // 62.5 MHz

    // scoreboard
    logic [DATA_WIDTH-1:0] q [$];
    int errors = 0;

    // write side: a push is accepted when w_en && !full at the clock edge
    always @(posedge wclk)
        if (wrst_n && w_en && !full) q.push_back(data_in);

    // read side: data_out is first-word-fall-through, so check at the accepting edge
    always @(posedge rclk)
        if (rrst_n && r_en && !empty) begin
            logic [DATA_WIDTH-1:0] exp;
            if (q.size() == 0) begin
                $display("%0t ERROR: read from empty scoreboard", $time); errors++;
            end else begin
                exp = q.pop_front();
                if (data_out !== exp) begin
                    $display("%0t ERROR: got %02h expected %02h", $time, data_out, exp); errors++;
                end
            end
        end

    task automatic write_n(int n);
        for (int i = 0; i < n; i++) begin
            @(negedge wclk);
            w_en = 1; data_in = $urandom;
        end
        @(negedge wclk); w_en = 0;
    endtask

    task automatic read_n(int n);
        for (int i = 0; i < n; i++) begin
            @(negedge rclk);
            r_en = 1;
        end
        @(negedge rclk); r_en = 0;
    endtask

    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        #40 wrst_n = 1; rrst_n = 1;
        #50;
        if (!empty) begin $display("ERROR: not empty after reset"); errors++; end

        // 1. overfill: 20 writes into 16 entries, full must assert, extras dropped
        write_n(20);
        #100;
        if (!full) begin $display("ERROR: full not asserted"); errors++; end

        // 2. overdrain: 20 reads from 16 entries, empty must assert
        read_n(20);
        #100;
        if (!empty) begin $display("ERROR: empty not asserted"); errors++; end
        if (q.size() != 0) begin $display("ERROR: scoreboard has %0d leftover", q.size()); errors++; end

        // 3. concurrent traffic
        fork
            write_n(100);
            begin #50; read_n(100); end
        join
        #200;
        read_n(20);
        #200;

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

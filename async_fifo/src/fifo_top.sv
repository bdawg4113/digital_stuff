`include "fifo_mem.sv"
`include "sync_2_ff.sv"
`include "wrptr_handler.sv"
`include "rptr_handler.sv"

module async_fifo #(parameter DEPTH=16, DATA_WIDTH=8)(
    input logic                     wclk, wrst_n, 
    input logic                     rclk, rrst_n, 
    input logic                     w_en, r_en, 
    input logic [DATA_WIDTH-1:0]    data_in,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    full, empty
);

    localparam PTR_WIDTH = $clog2(DEPTH);

    logic [PTR_WIDTH:0]     g_wptr_sync, g_rptr_sync;
    logic [PTR_WIDTH:0]     b_wptr, b_rptr;
    logic [PTR_WIDTH:0]     g_wptr, g_rptr;

    sync_2ff #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync); 
    sync_2ff #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync); 

    wptr_handler #(PTR_WIDTH) wptr_h (wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full);
    rptr_handler #(PTR_WIDTH) rptr_h (rclk, rrst_n, r_en, g_wptr_sync, b_rptr, g_rptr, empty);
    fifo_mem #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifom (wclk, w_en, rclk, r_en, b_wptr, b_rptr, data_in, full, empty, data_out);

endmodule
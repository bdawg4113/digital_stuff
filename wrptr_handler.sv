// Write Pointer Handler
/*
Output of g_rptr_sync is given as an input to the write pointer handler module used to generate the FIFO full condition.
Binary write pointer b_wptr is +1 if it satisfied (w_en & !full) 

This b_wptr value is fed into the fifo_mem module to write data into the FIFO.
*/

module wptr_handler #(parameter PTR_WIDTH = 3)
(
    input logic     wclk, wrst_n, w_en,
    input logic     [PTR_WIDTH:0] g_rptr_sync, 
    output logic    [PTR_WIDTH:0] b_wptr, g_wptr, 
    output logic    full

);

    logic [PTR_WIDTH:0] b_wptr_next;
    logic [PTR_WIDTH:0] g_wptr_next; 

    logic wrap_around; 
    logic wfull; 

    assign b_wptr_next = b_wptr+(w_en & !full);
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next; 

    always_ff @(posedge wclk or negedge wrst_n) begin 
        if (!wrst_n) begin 
            b_wptr <= 0;
            g_wptr <= 0;
        end else begin 
            b_wptr <= b_wptr_next; //incr binary write pointer
            g_wptr <= g_wptr_next; //incr gray write pointer
        end
    end

    always @(posedge wclk or negedge wrst_n) begin 
        if (!wrst_n)    full <= 0;
        else            full <= wfull; 
    end 

    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule 
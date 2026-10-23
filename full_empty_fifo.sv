// Ways to check if a fifo is either full or empty: 

/*
Way 1: 

Convert received gray code pointers to binary and then check for full and empty conditions: 

FIFO FULL Pseudocode: 

g2b_converter g2b_wr(g_rptr_sync, b_rptr_sync); 
wrap_around = b_rptr_sync[PTR_WIDTH] ^ b_wptr[PTR_WIDTH]; 
wfull = wrap_around & (b_wptr[PTR_WDITH-1:0] == b_rptr_sync[PTR_WIDTH-1:0]);

FIFO EMPTY Pseudocode: 

g2b_converter g2b_rd(g_wptr_sync, b_wptr_sync); 
rempty = (b_wptr_sync == b_rptr_next); //literally if write and read are at the same element then its empty
*/

/*
Check for full and empty conditions with gray coded write and reader pointer received.
Aka do everything in gray: 

FIFO FULL: 

wfull = (g_wptr_next == (~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]); // full when lower address bits == the extra MSB differs 

FIFO EMPTY: 

rempty = (g_wptr_sync == g_rptr_next); // when read and write pointers are exactly the same
*/
// Read Pointer Handler 

// wire (.v) --> net, physical connection, can do X but can't hold a value 
// reg (.v) --> variable (storage), procedural blocks, retains a value until next assignment

// logic ---> data type that can be both a procedural block or a net. But it can't be driven many times like a wire.

module rptr_handler #(parameter PTR_WIDTH = 3) (
    input logic                 rclk, rrst_n, r_en, 
    input logic [PTR_WIDTH:0]   g_wptr_sync,
    output logic [PTR_WIDTH:0]  b_rptr, g_rptr, 
    output logic                empty
);

    logic [PTR_WIDTH:0] b_rptr_next;
    logic [PTR_WIDTH:0] g_rptr_next;
    logic rempty;

    assign b_rptr_next = b_rptr + (r_en & !empty); 
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next; 
    assign rempty = (g_wptr_sync == g_rptr_next);

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
        end else begin 
            b_rptr <= b_rptr_next;      // incr binary read pointer
            g_rptr <= g_rptr_next;      // incr gray read pointer
        end
    end 

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)    empty <= 1;
        else            empty <= rempty;
    end
endmodule
// Basic 2 FF sync 

/*
Why do you need a 2 FF sync: 

1. Metastability: 
- If an async input changes inside the setup/hold window of a flop, the flop output can hover at a intermediate voltage value, 
    which is pretty bad because we won't know how long it takes to resolve it to a 0 or 1. 
- If the issue is not resolved, it can propagate a garbage value. 
- Could use the MTBF = Total Operating Time / Number of Failures 
*/

/*
How a 2 FF Sync works: 
1. Flop 1 may propagate the data as metastable, but you allow a full clock period to resolve it before Flop 2 samples it. 
*/

// This module: 

/*
    1. Must hold the input for longer than one dest clock period or else the pulse can be missed 
    2. Source signal must come from source domain (to avoid glitches) 
    3. Can support multi bit async data coming in and multi bit sync data coming out
*/

/*
//  Key Things to Note: 

    1. 2-FF handles metastability in F->S and S->F in either direction. 
    2. S->F risks seeing the same event multiple times 
    3. F->S risks missing the event entirely
*/ 
module sync_2ff #(parameter WIDTH = 3) (
    input logic     clk_dst, 
    input logic     rst_n,      //active low reset 
    input logic  [WIDTH:0]   d_async,    // data is assumed to be async 
    output logic [WIDTH:0]    q_sync      // data output will be in sync 
    ); 

    logic [WIDTH:0] q1; 

    always_ff @(posedge clk_dst or negedge rst_n) begin 
        if (!rst_n) begin 
            q1 <= 0;
            q_sync <= 0;
        end 

        else begin 
            q1 <= d_async;
            q_sync <= q1; 
        end 

        
    end


            

endmodule
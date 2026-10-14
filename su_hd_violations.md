# Setup Time: 
The min amount of time the data input must be stable BEFORE the active clock edge (usually the rising edge) 

Setup equation: T_c2q,max + T_comb,max + T_setup <= T_clk + T_skew 

## How to fix: 
Setup violations happen because the sample rate of the data is too slow. 

1. Lower the clock frequency (if you can change the clock frequency)
2. speed up the data sampling: 
- pipelining 
- reduce comb logic 
- reduce the load 
- use a faster FF 
- reduce buffer usage


# Hold Time: 
The min amount of time the data input must be stable AFTER the active clock edge

Hold equation: T_hold + T_skew <= T_c2q,min + T_comb, min
## How to Fix:
Hold violations happen because the sample rate of the data happened too fast

1. Slow down the data path: 
- Add buffers
- Use higher Vt cells (take longer to charge/discharge) 

2. Reduce skew 


Fix setup first, then hold, since hold buffers could eatup your slack and frequency only helps setup. 

* Key things to note: 
1. Hold fixing costs area and power --> adding buffers increases area and power and can hurt setup on the same path if the slack is tight 
2. Fix hold at the right place 
3. Hold must be fixed in every fast corner you sign off --> its cooked if you don't fix them 
4. Setup and hold are tradeoffs against each other --> delaying the capture clock helps setup but hurts hold and v.v. 
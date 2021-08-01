`timescale 1ns/1ns

module tb_calc;

  reg 	Start, clk, rst_; 
  reg  [1:0]   SIR;
  reg  [3:0]   SA, SB;
  wire [4:0]   resultA;
  wire [3:0]   resultB;

 // Instantiate design example
  calculator Main_module (resultA, resultB, Start, rst_, clk, SIR, SA, SB);

// Describe stimulus waveforms
//initial #500 $finish;	// Stopwatch

initial
begin
rst_ = 0;
Start = 0;
clk = 0;

    SA = 4;  SB = 5;  SIR = 0;
    #10 rst_ = 1; Start = 1;
    #10 Start = 0;
#40
    SIR = 1;
    #10 Start = 1;
    #10 Start = 0;

#40
    SIR = 3;
    #10 Start = 1;
    #10 Start = 0;

#40
     SB = 12; SIR = 2;
    #10 Start = 1;
    #10 Start = 0;

end

  always
     #5  clk = ~clk;

initial
$monitor ("SA = %b SB = %b IR = %b resultA = %b resultB = %b time = %0d", SA, SB, SIR, resultA, resultB, $time); 

endmodule

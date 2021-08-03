
// RTL description of simple calculator
module calculator (LEDG, LEDR, SW, CLOCK_50);

  // Specify ports of the top-level module of the design
  
  input  [17:0] SW;
  input  CLOCK_50;
  
  output [17:0] LEDR;
  output [7:0] LEDG;
 
  wire  B0, Bnot0, ld_A, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B;  // ALU_Sel = 1 if add; 0 if sub;
  wire  [4:0] resultA;
  wire  [3:0] resultB;
  wire  [3:0] SA, SB;
  wire  [1:0] SIR;
  wire  Start, clk, clk1, rst_;
  reg  [25:0] counter;
  
  assign LEDG[6:0] = 7'b0;
  assign LEDR[9:0] = 10'b0;
  assign SIR = SW[1:0];
  assign rst_ = SW[2];
  assign Start = SW[3];
  assign clk1 = CLOCK_50;
  assign clk = counter[25];
  assign LEDR[13:10] = resultA[3:0];
  assign LEDR[17:14] = resultB;
  assign LEDG[7] = resultA[4];
  assign SA = SW[13:10];
  assign SB = SW[17:14];
  
  always @ (posedge clk1)
    counter = counter+1;

  // Instantiate controller and datapath units (Let's place IR in control.)
  Control_calc  Mc (ld_A, AselSA, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B, SIR, B0, Bnot0, Start, rst_, clk);
  Datapath_calc Md (resultA, resultB, B0, Bnot0, SA, SB, ld_A, AselSA, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B, clk);

endmodule

module Control_calc(ld_A, AselSA, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B, SIR, B0, Bnot0, Start, rst_, clk);

   output reg	ld_A, AselSA, ld_B, ld_l, clr_l, shl_A, shr_B;   // if AselSA=1, A <= SA; else A <= ALU
   output reg   ALUsel;
   input	Start, rst_, clk;
   input        B0, Bnot0;        // Bnot0=0 if B=0
   input [1:0]  SIR;

   reg         ld_IR;
   reg [2:0] 	state, next_state;
   reg [1:0]    IR;
   parameter 	S_0 = 3'b000, S_1 = 3'b001, S_2 = 3'b010, S_3 = 3'b011,
                S_4 = 3'b100, S_5 = 3'b101, S_6 = 3'b110;	           // State codes

   always @ (posedge clk, negedge rst_)	
   //  to do : State transitions (edge sensitive)
	if(rst_==0) state<=S_0; else state <= next_state;

 
   always @ (posedge clk)
        if (ld_IR) IR <= SIR;


   
   always @ (state, Start, IR, Bnot0, B0) 	
    begin
   // to do : Code next-state logic directly from ASMD chart
	next_state=S_0;
	case(state)
		S_0: if(Start) next_state=S_1; else next_state=S_0;
		S_1: if(IR==0) next_state=S_2; else if(IR==1) next_state=S_3; else if(IR==2) next_state=S_4; else if(IR==3) next_state=S_5;
		S_2: next_state=S_0; 
		S_3: next_state=S_0; 
		S_5: next_state=S_0;
		S_4: if(Bnot0==1) next_state=S_6; else next_state=S_0; 
		S_6: if(B0==0) next_state=S_6; else next_state=S_0;
		default: next_state=S_0; 
	endcase
   end





   // 
   always @ (state, Start, IR, Bnot0, B0) 
    begin
   // to do :Code output logic directly from ASMD chart
	AselSA = 0;
	ld_A = 0;
	ld_B = 0;
	ld_l = 0;
	clr_l = 0;
	shl_A = 0;
	shr_B = 0;
	
	case(state)
		S_0: if(Start) ld_IR = 1; 
		S_1: if(IR==0) begin AselSA=1; ld_A=1; ld_B=1; clr_l=1; end 
			else if(IR==1) begin AselSA=1; ld_A=1; ld_B=1; clr_l=1; end 
			else if(IR==2) ld_B=1; 
			else if(IR==3) begin AselSA=1; ld_A=1; end
		S_2: begin AselSA=0; ALUsel = 1; ld_A=1; ld_B=1; ld_l=1; end
		S_3: begin AselSA=0; ALUsel = 0; ld_A=1; ld_B=1; ld_l=1; end
		S_5: begin AselSA=0; shl_A=1; end
		S_6: begin if(B0==0) shr_B=1; end
		
	endcase
    end
	
endmodule

module Datapath_calc(resultA, resultB, B0, Bnot0, SA, SB, ld_A, AselSA, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B, clk);

  output wire [4:0] resultA;
  output wire [3:0] resultB;
  output wire B0, Bnot0;

  input  [3:0] SA, SB;
  input	 ld_A, AselSA, ld_B, ld_l, clr_l, ALUsel, shl_A, shr_B, clk;

  reg [4:0] ALUresult;
  reg [3:0] A, B;
  reg       l;

  assign resultA = {l, A};
  assign resultB = B;
  assign B0 = B[0], Bnot0 = B[3] || B[2] || B[1] || B[0];

// Code register transfer operations directly from ASMD chart 
  always @(posedge clk) begin
    if (ld_A) 	if (AselSA) A <= SA; else A <= ALUresult[3:0];
    if (ld_B)   B <= SB;
    if (ld_l) 	l <= ALUresult[4];
    if (clr_l) 	l <= 0;
    if (shl_A)	A <= A << 1;
    if (shr_B) 	B <= B >> 1;
   end

 // ALU
   always @(A, B, ALUsel)
     if (ALUsel) ALUresult = A + B;
     else        ALUresult = A - B;

endmodule

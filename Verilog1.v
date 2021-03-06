module part3 (KEY, SW, HEX5, HEX4, HEX2, HEX0, LEDR);
	input [0:0] KEY;
	input [9:0] SW;
	output [0:6] HEX5, HEX4, HEX2, HEX0;
	output [9:0] LEDR;

	wire Clock, Write;
	wire [4:0] Address;
	wire [3:0] DataIn, DataOut;

	assign Clock = KEY[0];
	assign Write = SW[9];
	assign DataIn = SW[3:0];
	assign Address = SW[8:4];

	reg [3:0] memory_array [31:0];
	reg [4:0] Address_reg;  
 
	// infer RAM module
	always @(posedge Clock)
	begin
		if (Write)
			memory_array[Address] <= DataIn;
		Address_reg <= Address;
   	end
   	assign DataOut = memory_array[Address_reg];
	
 
	// display the data input, data output, and address on the 7-segs
	hex7seg digit0 (DataOut[3:0], HEX0);
	hex7seg digit1 (DataIn[3:0], HEX2);
	hex7seg digit5 ({3'b0, Address[4]}, HEX5);
	hex7seg digit4 (Address[3:0], HEX4);

	assign LEDR[3:0] = DataIn;
	assign LEDR[8:4] = Address;
	assign LEDR[9] = Write;
endmodule

// the B input blanks the display when B = 1
module hex7seg (hex, display);
	input [3:0] hex;
	output [0:6] display;

	reg [0:6] display;

	/*
	 *       0  
	 *      ---  
	 *     |   |
	 *    5|   |1
	 *     | 6 |
	 *      ---  
	 *     |   |
	 *    4|   |2
	 *     |   |
	 *      ---  
	 *       3  
	 */
	always @ (hex)
		case (hex)
			4'h0: display = 7'b0000001;
			4'h1: display = 7'b1001111;
			4'h2: display = 7'b0010010;
			4'h3: display = 7'b0000110;
			4'h4: display = 7'b1001100;
			4'h5: display = 7'b0100100;
			4'h6: display = 7'b0100000;
			4'h7: display = 7'b0001111;
			4'h8: display = 7'b0000000;
			4'h9: display = 7'b0000100;
			4'hA: display = 7'b0001000;
			4'hb: display = 7'b1100000;
			4'hC: display = 7'b0110001;
			4'hd: display = 7'b1000010;
			4'hE: display = 7'b0110000;
			4'hF: display = 7'b0111000;
		endcase
endmodule

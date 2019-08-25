`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2019 07:01:03 AM
// Design Name: 
// Module Name: mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//multiplication module

module mul(
      input clock, reset,
      input[31:0] a,
      input [31:0] b,
      input start,
      input is_signed,

      output [31:0]mul_hi,
      output [31:0]mul_lo,
      output ready
);
    reg [63:0] s;
	reg lsb;
	reg [5:0] bit; 
	reg [31:0] abs_a, abs_b;
	assign ready = !bit;
    assign mul_hi = s[63:32];
    assign mul_lo = s[31:0];
	always @( posedge clock ) begin
		if (reset) begin
			bit = 6'd0;
		end 
		else begin
     			if( ready && start ) begin
				//abs a is the absolute  value 
				abs_a = is_signed ? (a[31] ? -a : a) : a;
				abs_b = is_signed ? (b[31] ? -b : b) : b;
				bit = 32;
        			s = { 32'd0, abs_a };
     			end 
			else if( bit ) begin
				lsb = s[0];
       				s = s >> 1;
        			bit = bit - 1;
				//if lsb was 1 then we add multplicand
        			if(lsb)
					s[63:31] = s[62:31] + abs_b;
				
				//done, set the sign of the output for signed operations
				if(!bit && a[31] ^ b[31] && is_signed)
					s = -s;
			end
     		end
	end
endmodule
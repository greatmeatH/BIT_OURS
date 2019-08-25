`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 02:58:50 AM
// Design Name: 
// Module Name: decode_exe
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
`include "defines.vh"

module decode_exe(
    input clock,
    input reset,
    
    // control signal
    input RegWriteD,
    input MemtoRegD,
    input MemWriteD,
    input [`ALUCONTROL_SIZE]ALUControlD,
    input ALUSrcD,
    input RegDstD,
    input HiWriteD,
    input LoWriteD,
    input HiReadD,
    input LoReadD,
    input HilotoRegD,
    input CP0toRegD,
    
	input ShiftSrcD,	//hjw
	input [1:0]isDivD,
	input [1:0] isMulD,
	//input [`OP_SIZE] opcodeD,
	input [3:0]MemCtrlD,
	
    
    input PCtoRegD,             //  ** added for PC
    
    input FlushE,           // for conflict , to be done
    // input
    input [`DATALENGTH]RD1D,
    input [`DATALENGTH]RD2D,
    input [`R_SIZE]RsD,
    input [`R_SIZE]RtD,
    input [`R_SIZE]RdD,
    
    input [`DATALENGTH]SignImmD,
    
    input [`PCSIZE] PCPlus8D,          // **added for PC
    //input [`PCSIZE] PCD,    //for debug
    
    input StallE,     // added by LH, for data sram 1 T delay
    //input MemReadD,
    input CP0WriteD,  //add for cp0_write
    input CP0ReadD,
    input isInDelaySlotD,
    input [8:0] ExceptTypeD,
    // output
    output reg RegWriteE,
    output reg MemtoRegE,
    output reg MemWriteE,
    output reg[`ALUCONTROL_SIZE] ALUControlE,
    output reg ALUSrcE,
    output reg RegDstE,
	output reg ShiftSrcE,   //hjw
    output reg HiWriteE,
    output reg LoWriteE,
    output reg HiReadE,
    output reg LoReadE,
    output reg HilotoRegE,
    output reg CP0toRegE,
    
    output reg PCtoRegE,
    output reg [`PCSIZE] PCPlus8E,
    //output reg [`PCSIZE] PCE,   //for debug
    
    output reg [`DATALENGTH]RD1E,
    output reg [`DATALENGTH]RD2E,
    output reg [`R_SIZE]RsE,
    output reg [`R_SIZE]RtE,
    output reg [`R_SIZE]RdE,
    
    output reg [`DATALENGTH]SignImmE,
    output reg [1:0] isDivE,
    output reg [1:0] isMulE,
    output reg [3:0]MemCtrlE,
    //output reg MemReadE,
    output reg CP0WriteE,  //add for cpo_write
    //output reg CP0ReadE,
    output reg isInDelaySlotE,
    output reg [8:0] ExceptTypeE
    );
    
    always@(posedge clock)begin
        if(reset == `RESETABLE || (FlushE == 1'b1 && StallE == 1'b0))begin
            RegWriteE <= 1'b0;
            MemtoRegE <= 1'b0;
            MemWriteE <= 1'b0;
            ALUSrcE <= 1'b0;
            RegDstE <= 1'b0;
            ALUControlE <= 3'b000;
			ShiftSrcE <= 'b0;   //hjw
            RD1E <= `ZEROWORD;
            RD2E <= `ZEROWORD;
            SignImmE <= `ZEROWORD;
            RsE <= 5'b00000;
            RtE <= 5'b00000;
            RdE <= 5'b00000;
            HiWriteE <= 1'b0;
            LoWriteE <= 1'b0;
            HiReadE <= 1'b0;
            LoReadE <= 1'b0;
            HilotoRegE <= 1'b0;
            PCtoRegE <= 1'b0;
            PCPlus8E <= `ZEROWORD;
            isDivE <= 2'b00;
            MemCtrlE <= 4'b0000;
            //PCE <= 32'hbfc00000;
            //MemReadE <= 1'b0;
            CP0WriteE <= 1'b0;
//            CP0ReadE <= 1'b0;
            CP0toRegE <= 1'b0;
            isInDelaySlotE <= 1'b0;
            ExceptTypeE <= 9'b000000000;
            isMulE <= 2'b00;
        end
        else if(StallE == 1 )begin
            RegWriteE <= RegWriteE;
            MemtoRegE <= MemtoRegE;
            MemWriteE <= MemWriteE;
            ALUSrcE <= ALUSrcE;
            RegDstE <= RegDstE;
            ALUControlE <= ALUControlE;
			ShiftSrcE <= ShiftSrcE;     //hjw
            RD1E <= RD1E;
            RD2E <= RD2E;
            SignImmE <= SignImmE;
            RsE <= RsE;
            RtE <= RtE;
            RdE <= RdE; 
            HiWriteE <= HiWriteE;
            LoWriteE <= LoWriteE;
            HiReadE <= HiReadE;
            LoReadE <= LoReadE;
            HilotoRegE <= HilotoRegE;
            PCtoRegE <= PCtoRegE;
            PCPlus8E <= PCPlus8E;
            isDivE <= isDivE;
            MemCtrlE <= MemCtrlE;
            //PCE <= PCE;
           // MemReadE <= MemReadE;
            CP0WriteE <= CP0WriteE;
//            CP0ReadE <= CP0ReadE;
            CP0toRegE <= CP0toRegE;
            isInDelaySlotE <= isInDelaySlotE;
            ExceptTypeE <=ExceptTypeE;
            isMulE <= isMulE;
        end else begin
            RegWriteE <= RegWriteD;
            MemtoRegE <= MemtoRegD;
            MemWriteE <= MemWriteD;
            ALUSrcE <= ALUSrcD;
            RegDstE <= RegDstD;
            ALUControlE <= ALUControlD;
			ShiftSrcE <= ShiftSrcD;     //hjw
            RD1E <= RD1D;
            RD2E <= RD2D;
            SignImmE <= SignImmD;
            RsE <= RsD;
            RtE <= RtD;
            RdE <= RdD; 
            HiWriteE <= HiWriteD;
            LoWriteE <= LoWriteD;
            HiReadE <= HiReadD;
            LoReadE <= LoReadD;
            HilotoRegE <= HilotoRegD;
            PCtoRegE <= PCtoRegD;
            PCPlus8E <= PCPlus8D;
            isDivE <= isDivD;
            MemCtrlE <= MemCtrlD;
            //PCE <= PCD;
           //MemReadE <= MemReadD;
           CP0WriteE <= CP0WriteD;
          // CP0ReadE <= CP0ReadD;
           CP0toRegE <= CP0toRegD;
           isInDelaySlotE <= isInDelaySlotD;
           ExceptTypeE <= ExceptTypeD;
           isMulE <= isMulD;
        end
    end
endmodule

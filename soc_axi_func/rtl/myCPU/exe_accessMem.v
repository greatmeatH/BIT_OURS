`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 03:42:26 AM
// Design Name: 
// Module Name: exe_accessMem
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
module exe_accessMem(
    input clock,
    input reset,
    
   
    // control signal
    input RegWriteE,
    input MemtoRegE,
    input MemWriteE,
    input HiWriteE,
    input LoWriteE,
    input HiReadE,
    input LoReadE,
    input HilotoRegE,
    input PCtoRegE,         // ** added for PC
    input CP0toRegE,
    input isDiv,
    input isMul,
    // input
   // input [`DATALENGTH]ALUOutE,
   
   input [`R_SIZE] RdE,
   
    input [`DATALENGTH]WriteDataE,
    input [`R_SIZE] WriteRegE,
    

    input [`DATALENGTH]ALUOutHigh,
    input [`DATALENGTH]ALUOutLow,
    input [`DATALENGTH]DivHigh,
    input [`DATALENGTH]DivLow,
    input [`DATALENGTH]MulHigh,
    input [`DATALENGTH]MulLow,
    
    input [`PCSIZE] PCPlus8E, // ** added for PC
    //input [`PCSIZE] PCE,    //for debug
    
    input [3:0]MemCtrlE,
    //input [`OP_SIZE] opcodeE,
    input FlushM,
    
    input StallM,       // added by LH, for data sram 1 T delay
    //input MemReadE,
    input CP0WriteE, //add for cp0write
    input isInDelaySlotE,
    input [8:0] ExceptTypeE,
    input data_sram_addr_ok,
    input data_sram_data_ok,
    // output 
    output reg RegWriteM,
    output reg MemtoRegM,
    output reg MemWriteM,
    
 //   output reg[`DATALENGTH]ALUOutM,
    output reg[`R_SIZE] RdM,
 
    output reg[`DATALENGTH]WriteDataM,
    output reg[`R_SIZE] WriteRegM,
    
    output reg HiWriteM,
    output reg LoWriteM,
    output reg HiReadM,
    output reg LoReadM,
    output reg HilotoRegM,
    
     
    output reg PCtoRegM,        // ** added for PC
    output reg CP0toRegM,
    
    output reg [`PCSIZE] PCPlus8M,// ** added for PC
    //output reg [`PCSIZE] PCM,   //for debug
    
    
    output reg[`DATALENGTH] HighM,
    output reg[`DATALENGTH] LowM,
    
    output reg [3:0]MemCtrlM,
    //output reg[`OP_SIZE] opcodeM
    //output reg MemReadM,
    (* max_fanout = "40" *)output reg lwflag,
    output reg CP0WriteM,
    output reg isInDelaySlotM,
    output reg [8:0] ExceptTypeM,
    output reg req
    );
    
    
    always @(posedge clock)begin
        if(reset == `RESETABLE || (FlushM == 1'b1 && StallM == 1'b0))begin
            RegWriteM <= 1'b0;
            MemtoRegM <= 1'b0;
            MemWriteM <= 1'b0;
         //   ALUOutM <= `ZEROWORD;
            WriteDataM <= `ZEROWORD;
            WriteRegM <= 5'b00000;
            HiWriteM <= 1'b0;
            LoWriteM <= 1'b0;
            HiReadM <= 1'b0;
            LoReadM <= 1'b0;
            HilotoRegM <= 1'b0;
            HighM <= `ZEROWORD;
            LowM <= `ZEROWORD;
            PCtoRegM <= 1'b0;
            PCPlus8M <= `ZEROWORD;
            MemCtrlM <= 4'b0000;
            //PCM <= 32'hbfc00000;
            //opcodeM <= 6'b000000;
            //MemReadM <= 1'b0;
            lwflag <= 1'b0;
            req <= 1'b0;
            CP0WriteM <= 1'b0;
            CP0toRegM <= 1'b0;
            RdM <= 5'b00000;
            isInDelaySlotM <= 1'b0;
            ExceptTypeM <= 9'b000000000;
        end
        else if(StallM == 1)begin
             RegWriteM <= RegWriteM;
            MemtoRegM <= MemtoRegM;
            MemWriteM <= MemWriteM;
       //     ALUOutM <= ALUOutE;
            WriteDataM <= WriteDataM;
            WriteRegM <= WriteRegM;

            HiWriteM <= HiWriteM;
            LoWriteM <= LoWriteM;
            HiReadM <= HiReadM;
            LoReadM <= LoReadM;
            HilotoRegM <= HilotoRegM;
            HighM <= HighM;
            LowM <= LowM;
            PCtoRegM <= PCtoRegM;
            PCPlus8M <= PCPlus8M;
            MemCtrlM <= MemCtrlM;
            //PCM <= PCM;
            //opcodeM <= opcodeE;
            //MemReadM <= MemReadM;
            if( data_sram_data_ok == 1'b1 ) begin
                lwflag <= 1'b0;
            end else if( data_sram_data_ok == 1'b0 ) begin
                lwflag <= lwflag;
            end
            if( data_sram_addr_ok == 1'b1) begin
                req <= 1'b0;
            end else if( data_sram_addr_ok == 1'b0) begin
                req <= req;
            end
            CP0WriteM <= CP0WriteM;
            CP0toRegM <= CP0toRegM;
            RdM <= RdM;
            isInDelaySlotM <= isInDelaySlotM;
            ExceptTypeM <= ExceptTypeM;
        end else begin
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;
            MemWriteM <= MemWriteE;
       //     ALUOutM <= ALUOutE;
            WriteDataM <= WriteDataE;
            WriteRegM <= WriteRegE;

            HiWriteM <= HiWriteE;
            LoWriteM <= LoWriteE;
            HiReadM <= HiReadE;
            LoReadM <= LoReadE;
            HilotoRegM <= HilotoRegE;
            if(isMul == 1'b1) begin
                HighM <= MulHigh;
                LowM <= MulLow;
            end else if(isDiv == 1'b1) begin
                HighM <= DivHigh;
                LowM <= DivLow;
            end else begin
                HighM <= ALUOutHigh;
                LowM <= ALUOutLow;
            end
            //HighM <= HighE;
            //LowM <= LowE;
            PCtoRegM <= PCtoRegE;
            PCPlus8M <= PCPlus8E;
            MemCtrlM <= MemCtrlE;
            //PCM <= PCE;
            //opcodeM <= opcodeE;
            //MemReadM <= MemtoRegE;
            lwflag <= MemtoRegE || MemWriteE;
            req <= (MemtoRegE || MemWriteE);
            CP0WriteM <= CP0WriteE;
            CP0toRegM <= CP0toRegE;
            RdM <= RdE;
            isInDelaySlotM <= isInDelaySlotE;
            ExceptTypeM <= ExceptTypeE;
        end
    end
endmodule

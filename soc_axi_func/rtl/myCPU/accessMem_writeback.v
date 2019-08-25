`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 03:53:43 AM
// Design Name: 
// Module Name: accessMem_writeback
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
module accessMem_writeback(
    input clock,
    input reset,
    
    // control signal
    input RegWriteM,
    input MemtoRegM,
    
    //input HiWriteM,
    //input LoWriteM,
    //input HiReadM,
    //input LoReadM,
    input HilotoRegM,
    
    input PCtoRegM, // ** added for PC
    input CP0toRegM,
    
    // input 
    input [`DATALENGTH] ReadDataM,
    input [`DATALENGTH] ALUOutM,
    input [`R_SIZE] WriteRegM,
    
    input [`DATALENGTH] HiloDataM,
    input [`DATALENGTH] CP0dataoutM,
    //input [`DATALENGTH] write_hi_dataM,
    //input [`DATALENGTH] write_lo_dataM,
    
    input [`PCSIZE] PCPlus8M,  // ** added for PC
    input [`PCSIZE] PCM,
    input StallW,   // added by LH, for data sram 1 T delay
    input FlushW,
  //  input CP0writeM, //add for cp0write
    // output
    output reg RegWriteW,
    output reg MemtoRegW,
    
    //output reg HiWriteW,
    //output reg LoWriteW,
    //output reg HiReadW,
    //output reg LoReadW,
    output reg HilotoRegW,
    
    output reg PCtoRegW,// ** added for PC
    output reg CP0toRegW,
    output reg[`PCSIZE] PCPlus8W,// ** added for PC
    
    output reg[`DATALENGTH] ReadDataW,
    output reg[`DATALENGTH] ALUOutW,
    output reg[`R_SIZE] WriteRegW,
    
    //output reg[`DATALENGTH] write_hi_dataW,
    //output reg[`DATALENGTH] write_lo_dataW
    output reg[`DATALENGTH] HiloDataW,
    output reg[`DATALENGTH] CP0dataoutW,
    output wire [`PCSIZE] PCW,
    output  [3:0] debug_wb_rf_wen,
    output  [`R_SIZE] debug_wb_rf_wnum,
    output reg writeregflag
 //   output reg CP0writeW  //add for cp0write
    );     
    assign PCW = PCPlus8W - 8;

    assign debug_wb_rf_wen = {4{RegWriteW}};
    assign debug_wb_rf_wnum = WriteRegW;
    
    always@(posedge clock)begin
        if(reset == `RESETABLE || (FlushW == 1'b1 && StallW == 1'b0))begin
            RegWriteW <= 1'b0;
            MemtoRegW <= 1'b0;
            ReadDataW <= `ZEROWORD;
            ALUOutW <= `ZEROWORD;
            WriteRegW <= 5'b00000;
            /*
            HiWriteW <= 1'b0;
            LoWriteW <= 1'b0;
            HiReadW <= 1'b0;
            LoReadW <= 1'b0;

            write_hi_dataW <= `ZEROWORD;
            write_lo_dataW <= `ZEROWORD;
            */
            HilotoRegW <= 1'b0;
            PCtoRegW <= 1'b0;
            PCPlus8W <= `ZEROWORD;
            HiloDataW <= `ZEROWORD;
            //PCW <= 32'hbfc00000;
            writeregflag <= 1'b0;
            //debug_wb_rf_wen <= 4'b0000;
            //debug_wb_rf_wnum <= 5'b00000;
   //         CP0writeW <= 1'b0;
            CP0toRegW <= 1'b0;
            CP0dataoutW <= `ZEROWORD;

        end else if(StallW == 1)begin
            RegWriteW <= 1'b0;
            MemtoRegW <= MemtoRegW;
            ReadDataW <= ReadDataW;
            ALUOutW <= ALUOutW;
            WriteRegW <= WriteRegW;
            /*
            HiWriteW <= 1'b0;
            LoWriteW <= 1'b0;
            HiReadW <= 1'b0;
            LoReadW <= 1'b0;

            write_hi_dataW <= `ZEROWORD;
            write_lo_dataW <= `ZEROWORD;
            */
            HilotoRegW <= HilotoRegW;
            PCtoRegW <= PCtoRegW;
            PCPlus8W <= PCPlus8W;
            HiloDataW <= HiloDataW;
            //PCW <= PCW;
            writeregflag <= writeregflag;
            //debug_wb_rf_wen <= {4{RegWriteM}};
            //debug_wb_rf_wnum <= WriteRegM;
       //     CP0writeW <= CP0writeW;
            CP0toRegW <= CP0toRegW;
            CP0dataoutW <= CP0dataoutW;

        end
        else begin
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            ReadDataW <= ReadDataM;
            ALUOutW <= ALUOutM;
            WriteRegW <= WriteRegM;
            /*
            HiWriteW <= HiWriteM;
            LoWriteW <= LoWriteM;
            HiReadW <= HiReadM;
            LoReadW <= LoReadM;
            
            write_hi_dataW <= write_hi_dataM;
            write_lo_dataW <= write_lo_dataM;
            */
            HilotoRegW <= HilotoRegM;
            PCtoRegW <= PCtoRegM;
            PCPlus8W <= PCPlus8M;
            HiloDataW <= HiloDataM;
            //PCW <= PCM;
            //debug_wb_rf_wen <= {4{RegWriteM}};
            //debug_wb_rf_wnum <= WriteRegM;
            writeregflag <= RegWriteM;
       //     CP0writeW <= CP0writeM;
            
            CP0toRegW <= CP0toRegM;
            CP0dataoutW <= CP0dataoutM;

        end
    end
endmodule

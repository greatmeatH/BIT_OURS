`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 04:10:41 AM
// Design Name: 
// Module Name: get_ResultW
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

module get_ResultW(
    //input clock,
    //input reset,
    
    // control signal
    input MemtoRegW,
    input HilotoRegW,
    input PCtoRegW,
    input CP0toRegW,
    
    // input 
    input [`DATALENGTH] ReadDataW,
    input [`DATALENGTH] ALUOutW,
    input [`DATALENGTH] HilodataW,
    input [`DATALENGTH] PCPlus8W,
    input [`DATALENGTH] CP0dataoutW,
    
    // output
    output [`DATALENGTH] ResultW,
    output [`DATALENGTH] debug_wb_rf_wdata
    );
    
    assign ResultW = (MemtoRegW == 1'b1) ? ReadDataW :
                     (HilotoRegW == 1'b1) ? HilodataW :
                     (PCtoRegW == 1'b1)? PCPlus8W :
                     (CP0toRegW == 1'b1) ? CP0dataoutW :
                     ALUOutW;
    assign debug_wb_rf_wdata = ResultW;
endmodule

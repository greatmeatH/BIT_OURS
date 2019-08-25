`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2019 08:32:25 PM
// Design Name: 
// Module Name: M_E_databack
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
module M_E_databack(
    //input reset,
    
    // control signal
    input HilotoRegM,
    input PCtoRegM,
    input MemReadM,
    input CP0toRegM,
    
    // input 
    input [`DATALENGTH] ALUOutM,
    input [`DATALENGTH] hilo_data_out,
    input [`DATALENGTH] PCPlus8M,
    input [`DATALENGTH] readData,
    input [`DATALENGTH] CP0_data_out,
    
    // output 
    output [`DATALENGTH] ME_databack
    
    );
    
    assign ME_databack =(HilotoRegM == 1'b1)? hilo_data_out :
                        (PCtoRegM == 1'b1) ? PCPlus8M :
                        (MemReadM == 1'b1) ? readData :
                        (CP0toRegM == 1'b1) ? CP0_data_out :
                         ALUOutM;

endmodule

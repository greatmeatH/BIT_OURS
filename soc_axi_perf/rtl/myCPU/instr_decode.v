`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 12:56:24 AM
// Design Name: 
// Module Name: instr_decode
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


module instr_decode(
    input clock,
    input reset,
    
    // control signal
    input StallD,       // deal with conflict, to be done
    input FlushD,
    input PCSrcD,       // for clear , to be done
    
    input BranchD,
    // input 
    input [`INSTRLENGTH] InstrI,
    input [`PCSIZE] PCPlus4F,
    //input [`PCSIZE] PCF,
    input [8:0] ExceptTypeF,
    
    output reg isInDelaySlotD,
    
    // output
    output reg[`INSTRLENGTH] InstrD,
    output reg[`PCSIZE] PCPlus4D,
    //output reg[`PCSIZE] PCD,
    output reg[8:0] ExceptTypeD
    
    );
    

    
    
    always@(posedge clock)begin
        if(reset == `RESETABLE || (FlushD == 1'b1 && StallD == 1'b0))begin
            InstrD <= `ZEROWORD;
            //PCD <= 32'hbfc00000;

            isInDelaySlotD <= 1'b0;
            ExceptTypeD <= 9'b000000000;
        end 
        else begin

            if(StallD == 1'b1)begin
                InstrD <= InstrD;
                PCPlus4D <= PCPlus4D;
                //PCD <= PCD;
                ExceptTypeD <= ExceptTypeD;
                

                isInDelaySlotD <= isInDelaySlotD;
            end else begin
                InstrD <= InstrI;
                PCPlus4D <= PCPlus4F;
                //PCD <= PCF;
                ExceptTypeD <= ExceptTypeF;

                
                if(BranchD == 1'b1)begin
                    isInDelaySlotD <= 1'b1;
                end else begin
                    isInDelaySlotD <= 1'b0;
                end
            end
            
            /*if(instr_after_slot_for_sram == 1'b1)begin
                InstrD <= `ZEROWORD;
                PCPlus4D <= PCPlus4F;
                PCD <= PCF;
                ExceptTypeD <= ExceptTypeF;
            end
            */
        end 
    end
    
    
endmodule

`timescale 1ns / 1ps
// update PC 
`include "defines.vh"
module get_pc(
    input clock,
    input reset,
    
    // control signals
    input StallF,
    input PCSrcD,
    //input [`PCSIZE] _PCF,
    input chooseExcPCF,
    // input 
    input [`PCSIZE] PCPlus4F,
    input [`PCSIZE] PCBranchD,
    //input [`PCSIZE] PCException,
    input [`PCSIZE] newPC,
    input inst_sram_addr_ok,
    input inst_sram_data_ok,
    // outputo
    output reg[`PCSIZE] PCF,
    output reg fetchflag,
    output reg instreq
    );
    
    wire [`PCSIZE] PC_;
    
    
    
    assign PC_ = (reset == `RESETABLE)?32'hbfc00000
                :(chooseExcPCF == 1'b1)?newPC
                :(PCSrcD == 1'b1)? PCBranchD
                :PCPlus4F;
 
    
    always @ (posedge clock) begin
        if (reset == `RESETABLE) begin 
            //PCF <= 32'hbfc00000;
            instreq <= 1'b1;
        end else if(StallF == 1'b1) begin
            //PCF <= PCF;
            if(inst_sram_addr_ok == 1'b0) begin
                instreq <= instreq;
            end else if(inst_sram_addr_ok == 1'b1) begin
                instreq <= 1'b0;
            end
            if(inst_sram_data_ok == 1'b0) begin
                fetchflag <= fetchflag;
            end else if(inst_sram_data_ok == 1'b1) begin
                fetchflag <= 1'b0;
            end
        end else begin
            //PCF <= PC_;
            instreq <= 1'b1;
            fetchflag <= 1'b1;
        end
    end
    always @ (posedge clock) begin
        if (reset == `RESETABLE) begin
            PCF <= 32'hbfc00000;
        end else if (StallF == 1'b1 && chooseExcPCF == 1'b0) begin
            PCF <= PCF;
        end else begin
            PCF <=PC_;
        end
    end
    
    
   

          
    


endmodule

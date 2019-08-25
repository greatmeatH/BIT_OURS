`timescale 1ns / 1ps
// get instrcment from instr memary
`include "defines.vh"

module get_instr(
    input wire clock,      
    //input wire reset, 
    input wire StallF,
    
    input wire PCSrcD,
    
    // addddd
    input wire chooseExcPCF,
    
  //  input 
    input wire[`PCSIZE] instr_addr,
    input wire[`PCSIZE] instr_from_ram,
    input instreq,
    input inst_sram_data_ok,
    
    output reg [`INSTRSIZE] InstrI,   // instrcment
    output wire inst_sram_req,
    output wire [1:0] inst_sram_size,
    //output wire inst_sram_en,
    //output wire [3:0] inst_sram_wen,
    output wire [`ADDRLENGTH] inst_sram_addr,
    output wire [`DATALENGTH] inst_sram_wdata,
    output inst_sram_wr,
    output [8:0] ExceptTypeF,
    output wire instr_cache,
    output wire [`PCSIZE]_PCF
    );
    wire [`INSTRSIZE] Instr;
    
    assign instr_cache = (inst_sram_addr[31:30] == 2'b11)?1'b1:(inst_sram_addr[31:29] == 3'b101)?1'b0:(inst_sram_addr[31] == 1'b1)?1'b1:1'b1;
    assign inst_sram_req = instreq;
    assign inst_sram_wr = 1'b0;
    assign ExceptTypeF = (_PCF[1:0] == 2'b00)? 9'b000000000:`ADEP_EX;//
    assign _PCF =  instr_addr;
    assign inst_sram_size = 2'b10;

        assign inst_sram_addr = instr_addr;
        assign inst_sram_wdata = 0;
        //assign Instr = (reset == 1'b1)?`ZEROWORD : ((instr_from_ram & 32'h000000FF) << 24 | (instr_from_ram & 32'h0000FF00) << 8 | 
        //                   (instr_from_ram & 32'h00FF0000) >> 8 | (instr_from_ram & 32'hFF000000) >> 24);
        assign Instr =(_PCF == `ZEROWORD ) ? `ZEROWORD :
                     //( _PCF ==  32'hbfc0f008) ? 32'h3c153130 :
                        instr_from_ram;
       
        //assign InstrI[31:0] = (_PCF == `ZEROWORD) ? `ZEROWORD :{{Instr[7:0]},{Instr[15:8]},{Instr[23:16]},{Instr[31:24]}};
        always@(posedge clock) begin
                if(inst_sram_data_ok == 1'b1) begin
                    InstrI <= Instr;
                end else begin
                    InstrI <= InstrI;
                end
            end
        
        //|| chooseExcPCF == 1'b1
    endmodule

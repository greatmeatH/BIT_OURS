`timescale 1ns / 1ps
// update PC 
`include "defines.vh"
module decode(
    //input wire clock,
    //input wire reset,
    
    // input 
    input wire[`INSTRSIZE] InstrD,
    
    // output
    output [`INSTR_INDEX]instrIndex,
    
    output [`R_SIZE] rs,
    output [`R_SIZE] rt,
    output [`R_SIZE] rd,
    
    output [`IMI_SIZE] im,
    
    output [`OP_SIZE] opcode,
    output [`OP_SIZE] funccode,
    
    output [`INSTRSIZE] Instr_out ////
    );
    
    assign Instr_out = InstrD;////
    assign instrIndex = InstrD[25:0];
    assign rs = InstrD[25:21];
    assign rt = InstrD[20:16];
    assign rd = InstrD[15:11];
    assign im = InstrD[15:0];
    assign opcode = InstrD[31:26];
    assign funccode = InstrD[5:0];
    /*
    always @ (*) begin
        if(reset == `RESETUNABLE) begin
            opcode <= InstrD[31:26];
            rs <= InstrD[25:21];
            rt <= InstrD[20:16];
            rd <= InstrD[15:11];
            im <= InstrD[15:0];
            funccode <= InstrD[5:0];
            instrIndex <= InstrD[25:0];
        end else begin 
            opcode <= 6'b0;
            rs <= 5'b0;
            rt <= 5'b0;
            rd <= 5'b0;
            im <= 15'b0;
            funccode <= 6'b0;
            instrIndex <= 26'b0;
        end
    end
    */
    
endmodule

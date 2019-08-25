`timescale 1ns / 1ps
// update PC 
`include "defines.vh"
module control_unit(
    //input wire clock,
    //input wire reset,
    
    // input
    input wire[`INSTRSIZE] Instr_in,////
    input wire[8:0] ExceptType_in,
    
    //input wire[`OP_SIZE] opcode_in,   //  assign
    //input wire[`OP_SIZE] funccode_in, //  assign
    //input wire[`R_SIZE] rt,         // added ** for fenzhi assign
   // input wire[15:0] imm,   //assign
    
    // output . these are all control signal
    output  [`EXTENDSIGNAL_SIZE] SigExtendSignalD,
    output  RegWriteD,
    output  MemtoRegD,
    output  MemWriteD,
    
    output [`ALUCONTROL_SIZE] ALUControlD,
    output  ALUSrcD,
    output  RegDstD, 
    output  BranchD,
	output  ShiftSrcD,
    // added for fenzhi instr
    output [`CONTROL_EQUALD_SIZE] EqualDControl,     
    // if PC needed to write to $31
    output  PCtoRegD,                             
    // for reg writed Rd or $31
    output  RdD_31_Control,                           
    // for J instr:
    output  J_Imi_ControlD,
    output  J_Rs_ControlD,
    
    // for hilo
    output  HiWriteD,
    output  LoWriteD,
    output  HiReadD,
    output  LoReadD,
    output  HilotoRegD,
    
    output  CP0toRegD,
    output [1:0] isDivD,     //sig div : 11 , unsig div : 01, not a div : 00 / 10
    
    output [1:0] isMulD,     
    // memory access control signal
    output [3:0] MemCtrlD,
    //output  MemReadD,
    output  CP0WriteD,//cp0 control
    output  [8:0]ExceptTypeD

   
    );
    wire [5:0]opcode_in;
    wire [5:0]funccode_in;
    wire [4:0]rt;
    wire [15:0]imm;
    
    wire instr_vaild;
    
    assign isMulD = (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MUL)? 2'b11:
                    (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MULU)? 2'b01:
                    2'b00;
    assign ExceptTypeD = (instr_vaild != 1'b1) ? (`INSTRINVAILD_EX|ExceptType_in):
                         (opcode_in == 6'b000000 && funccode_in == 6'b001100) ? (`SYSCALL_EX|ExceptType_in):
						 (opcode_in == 6'b000000 && funccode_in == 6'b001101) ? (`BREAK_EX|ExceptType_in):
						 (Instr_in == 32'b01000010000000000000000000011000) ? (`Eret_EX|ExceptType_in):
						  ExceptType_in;
						  
    assign opcode_in = Instr_in[31:26];
    assign funccode_in = Instr_in[5:0];
    assign rt = Instr_in[20:16];
    assign imm = Instr_in[15:0];
    assign SigExtendSignalD = (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL || rt == `RT_BLTZ || rt == `RT_BGEZ))?2'b01:
                              (opcode_in == `OP_ADDI || opcode_in == `OP_ADDIU  || opcode_in == `OP_SLTI|| opcode_in == `OP_SLTIU 
                                || opcode_in == `OP_BEQ|| opcode_in == `OP_BNE || opcode_in == `OP_BGTZ|| opcode_in == `OP_BLEZ
                                || opcode_in == `OP_LB || opcode_in == `OP_LBU || opcode_in == `OP_LH  || opcode_in == `OP_LHU 
                                || opcode_in == `OP_LW || opcode_in == `OP_LWL  || opcode_in == `OP_LWR || opcode_in == `OP_SB 
                                || opcode_in == `OP_SH  || opcode_in == `OP_SW   || opcode_in == `OP_SWL || opcode_in == `OP_SWR) ? 2'b01 :
                              (opcode_in == `OP_LUI)?2'b10:
                              2'b00;
    assign RegWriteD = (opcode_in == `OP_ALL_ZERO && 
                        (funccode_in == `FUNC_ADD || funccode_in == `FUNC_ADDU || funccode_in == `FUNC_SUB || funccode_in == `FUNC_SUBU
                         || funccode_in == `FUNC_SLT || funccode_in == `FUNC_SLTU || funccode_in == `FUNC_MFHI || funccode_in == `FUNC_MFLO
                          || funccode_in == `FUNC_JALR || funccode_in == `FUNC_AND || funccode_in == `FUNC_XOR || funccode_in == `FUNC_NOR
                           || funccode_in == `FUNC_OR || (funccode_in == `FUNC_SLL && imm != 5'b00000) || funccode_in == `FUNC_SLLV || funccode_in == `FUNC_SRA
                            || funccode_in == `FUNC_SRAV || funccode_in == `FUNC_SRL || funccode_in == `FUNC_SRLV)) ? 1'b1:
                       (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL))?1'b1:
                       (opcode_in == `OP_ADDI || opcode_in == `OP_ADDIU || opcode_in == `OP_ORI || opcode_in == `OP_ANDI || opcode_in == `OP_XORI
                         || opcode_in == `OP_SLTI || opcode_in == `OP_SLTIU || opcode_in == `OP_JAL|| opcode_in == `OP_LUI || opcode_in == `OP_LB 
                          || opcode_in == `OP_LBU || opcode_in == `OP_LH || opcode_in == `OP_LHU || opcode_in == `OP_LW || opcode_in == `OP_LWL 
                           || opcode_in == `OP_LWR) ? 1'b1 :
                       (opcode_in == `OP_CP0 && Instr_in[25:21] == 5'b00000 && Instr_in[10:0] == 11'b00000000000)?1'b1:
                       1'b0;
                       
    assign instr_vaild =(
                        (opcode_in == `OP_ALL_ZERO  && 
                        (funccode_in == `FUNC_ADD || funccode_in == `FUNC_ADDU || funccode_in == `FUNC_SUB || funccode_in == `FUNC_SUBU
                         || funccode_in == `FUNC_SLT || funccode_in == `FUNC_SLTU || funccode_in == `FUNC_MUL || funccode_in == `FUNC_MULU
                            || funccode_in == `FUNC_DIV|| funccode_in == `FUNC_DIVU||funccode_in == `FUNC_MFHI || funccode_in == `FUNC_MFLO || funccode_in == `FUNC_MTHI || funccode_in == `FUNC_MTLO
                          || funccode_in == `FUNC_JALR || funccode_in == `FUNC_JR || funccode_in == `FUNC_AND || funccode_in == `FUNC_XOR || funccode_in == `FUNC_NOR
                           || funccode_in == `FUNC_OR ||  funccode_in == `FUNC_SLL  || funccode_in == `FUNC_SLLV || funccode_in == `FUNC_SRA
                            || funccode_in == `FUNC_SRAV || funccode_in == `FUNC_SRL || funccode_in == `FUNC_SRLV ))  //total R-type
                            || (opcode_in == `OP_ADDI || opcode_in == `OP_ADDIU || opcode_in == `OP_ORI || opcode_in == `OP_ANDI || opcode_in == `OP_XORI
                      || opcode_in == `OP_SLTI || opcode_in == `OP_SLTIU || opcode_in == `OP_LUI || opcode_in == `OP_LB || opcode_in == `OP_LBU
                      || opcode_in == `OP_LH || opcode_in == `OP_LHU || opcode_in == `OP_LW || opcode_in == `OP_LWL || opcode_in == `OP_LWR
                      || opcode_in == `OP_SB || opcode_in == `OP_SH || opcode_in == `OP_SW || opcode_in == `OP_SWL || opcode_in == `OP_SWR 
                      || opcode_in == `OP_JAL || opcode_in == `OP_J || opcode_in == `OP_BEQ || opcode_in == `OP_BNE || opcode_in == `OP_BGTZ || opcode_in == `OP_BLEZ )//total I-type
                      || (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL || rt == `RT_BLTZ || rt == `RT_BGEZ)) 
                      || (Instr_in[31:21] == 11'b01000000100 && Instr_in[10:0] == 11'b00000000000) //mtco
                      || (Instr_in[31:21] == 11'b01000000000 && Instr_in[10:0] == 11'b00000000000) //mfco
                      || (opcode_in == 6'b000000 && funccode_in == 6'b001100)  // systemcall
                      || (opcode_in == 6'b000000 && funccode_in == 6'b001101) //break
                      || (Instr_in == 32'b01000010000000000000000000011000)// eret
                      || (Instr_in == 32'b00000000000000000000000000000000)//nop
                      )  ? 1'b1
                      :1'b0;
             
    
    
    
    
    
    
    
    
    
    
    
    assign MemtoRegD = (opcode_in == `OP_LB||opcode_in == `OP_LBU||opcode_in == `OP_LH||opcode_in == `OP_LHU
                        ||opcode_in == `OP_LW||opcode_in == `OP_LWL||opcode_in == `OP_LWR)?1'b1:
                        1'b0;
    assign MemWriteD = (opcode_in == `OP_SB ||opcode_in == `OP_SH||opcode_in == `OP_SW||opcode_in == `OP_SWL||opcode_in == `OP_SWR)? 1'b1 :
                        1'b0;
    assign ALUControlD = (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_ADD)? `ALU_ADD_OVERFLOW :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_ADDU)? `ALU_ADD :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SUB)? `ALU_SUB_OVERFLOW :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SUBU)? `ALU_SUB :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SLT)? `ALU_SLT :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SLTU)? `ALU_SLTU :
                // (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MUL)? `ALU_MUL :
                // (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MULU)? `ALU_MULU :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_DIV)? `ALU_DIV :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_DIVU)? `ALU_DIVU :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MTHI)? `ALU_MTHI :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MTLO)? `ALU_MTLO :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_AND)? `ALU_AND :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_XOR)? `ALU_XOR :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_NOR)? `ALU_NOR :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_OR)? `ALU_OR:
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SLL)? `ALU_SLL :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SLLV)? `ALU_SLL :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SRA)? `ALU_SRA :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SRAV)? `ALU_SRA :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SRL)? `ALU_SRL :
                 (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_SRLV)? `ALU_SRL :
                 (opcode_in == `OP_ADDI)? `ALU_ADD_OVERFLOW :
                 (opcode_in == `OP_ADDIU)? `ALU_ADD :
                 (opcode_in == `OP_ORI)? `ALU_OR :
                 (opcode_in == `OP_ANDI)? `ALU_AND :
                 (opcode_in == `OP_XORI)? `ALU_XOR :
                 (opcode_in == `OP_SLTI)? `ALU_SLT :
                 (opcode_in == `OP_SLTIU)? `ALU_SLTU :
                 (opcode_in == `OP_LB||opcode_in == `OP_LBU||opcode_in == `OP_LH||opcode_in == `OP_LHU
                 ||opcode_in == `OP_LW||opcode_in == `OP_LWL||opcode_in == `OP_LWR||opcode_in == `OP_SB
                 ||opcode_in == `OP_SH||opcode_in == `OP_SW||opcode_in == `OP_SWL||opcode_in == `OP_SWR)? `ALU_ADD :
                 `ALU_NONE;
    assign ALUSrcD = (opcode_in == `OP_ADDI || opcode_in == `OP_ADDIU || opcode_in == `OP_ORI || opcode_in == `OP_ANDI || opcode_in == `OP_XORI
                      || opcode_in == `OP_SLTI || opcode_in == `OP_SLTIU || opcode_in == `OP_LUI || opcode_in == `OP_LB || opcode_in == `OP_LBU
                      || opcode_in == `OP_LH || opcode_in == `OP_LHU || opcode_in == `OP_LW || opcode_in == `OP_LWL || opcode_in == `OP_LWR
                      || opcode_in == `OP_SB || opcode_in == `OP_SH || opcode_in == `OP_SW || opcode_in == `OP_SWL || opcode_in == `OP_SWR) ? 1'b1 :
                     1'b0;
    assign RegDstD = (opcode_in == `OP_ALL_ZERO && 
                        (funccode_in == `FUNC_ADD || funccode_in == `FUNC_ADDU || funccode_in == `FUNC_SUB || funccode_in == `FUNC_SUBU
                         || funccode_in == `FUNC_SLT || funccode_in == `FUNC_SLTU || funccode_in == `FUNC_MFHI || funccode_in == `FUNC_MFLO
                          || funccode_in == `FUNC_JALR || funccode_in == `FUNC_AND || funccode_in == `FUNC_XOR || funccode_in == `FUNC_NOR
                           || funccode_in == `FUNC_OR || funccode_in == `FUNC_SLL || funccode_in == `FUNC_SLLV || funccode_in == `FUNC_SRA
                            || funccode_in == `FUNC_SRAV || funccode_in == `FUNC_SRL || funccode_in == `FUNC_SRLV)) ? 1'b1:
                     (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL || rt == `RT_BLTZ || rt == `RT_BGEZ))?1'b1:
                     (opcode_in == `OP_JAL || opcode_in == `OP_BEQ || opcode_in == `OP_BNE || opcode_in == `OP_BGTZ || opcode_in == `OP_BLEZ) ? 1'b1 :
                     1'b0;
    assign BranchD = (opcode_in == `OP_ALL_ZERO && (funccode_in == `FUNC_JR || funccode_in == `FUNC_JALR)) ? 1'b1:
                     (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL || rt == `RT_BLTZ || rt == `RT_BGEZ))?1'b1:
                     (opcode_in == `OP_JAL || opcode_in == `OP_J || opcode_in == `OP_BEQ || opcode_in == `OP_BNE || opcode_in == `OP_BGTZ || opcode_in == `OP_BLEZ) ? 1'b1 :
                     1'b0;
    assign ShiftSrcD = (opcode_in == `OP_ALL_ZERO && (funccode_in == `FUNC_SLL || funccode_in == `FUNC_SRA || funccode_in == `FUNC_SRL)) ? 1'b1:
                       1'b0;
    assign EqualDControl = (opcode_in == `OP_REGIMM && (rt == `RT_BLTZ || rt == `RT_BLTZAL))? `EQC_LOW:
                           (opcode_in == `OP_REGIMM && (rt == `RT_BGEZ || rt == `RT_BGEZAL))? `EQC_HIGH_EQUAL:
                           (opcode_in == `OP_JAL || opcode_in == `OP_J || (opcode_in == `OP_ALL_ZERO && (funccode_in == `FUNC_JR || funccode_in == `FUNC_JALR)))? `EQC_J:
                           (opcode_in == `OP_BEQ)?`EQC_EQUAL:
                           (opcode_in == `OP_BNE)?`EQC_NOT_EQUAL:
                           (opcode_in == `OP_BGTZ)?`EQC_HIGH:
                           (opcode_in == `OP_BLEZ)?`EQC_LOW_EQUAL:
                           3'b000;
                           
    assign RdD_31_Control = (opcode_in == `OP_REGIMM && (rt == `RT_BGEZAL || rt == `RT_BLTZAL))?1'b1:
                            (opcode_in == `OP_JAL)?1'b1:
                            1'b0;
    assign PCtoRegD = (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_JALR) ? 1'b1:
                      RdD_31_Control;
    assign J_Imi_ControlD = (opcode_in == `OP_J || opcode_in == `OP_JAL) ? 1'b1:
                            1'b0;
    assign J_Rs_ControlD = (opcode_in == `OP_ALL_ZERO && (funccode_in == `FUNC_JR || funccode_in == `FUNC_JALR))? 1'b1:
                            1'b0;
    assign HiWriteD = (opcode_in == `OP_ALL_ZERO 
                        && (funccode_in == `FUNC_MTHI || funccode_in == `FUNC_MUL || funccode_in == `FUNC_MULU
                            || funccode_in == `FUNC_DIV|| funccode_in == `FUNC_DIVU))? 1'b1:
                       1'b0;
    assign LoWriteD = (opcode_in == `OP_ALL_ZERO 
                        && (funccode_in == `FUNC_MTLO || funccode_in == `FUNC_MUL || funccode_in == `FUNC_MULU
                            || funccode_in == `FUNC_DIV|| funccode_in == `FUNC_DIVU))? 1'b1:
                       1'b0;
    assign HiReadD = (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MFHI)? 1'b1:
                     1'b0;
    assign LoReadD = (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_MFLO)? 1'b1:
                     1'b0;
    assign HilotoRegD = (opcode_in == `OP_ALL_ZERO && (funccode_in == `FUNC_MFHI || funccode_in == `FUNC_MFLO))? 1'b1:
                        1'b0;
    assign CP0toRegD = (Instr_in[31:21] == 11'b01000000000 && // mfco docode
                 Instr_in[10:0] == 11'b00000000000)? 1'b1:
                 1'b0;
    assign isDivD =  (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_DIV)? 2'b11:
                     (opcode_in == `OP_ALL_ZERO && funccode_in == `FUNC_DIVU)? 2'b01:
                     2'b00;
    
    assign MemCtrlD =(opcode_in == `OP_LB)?`MEM_LB:
                     (opcode_in == `OP_LBU)?`MEM_LBU:
                     (opcode_in == `OP_LH)?`MEM_LH:
                     (opcode_in == `OP_LHU)?`MEM_LHU:
                     (opcode_in == `OP_LW)?`MEM_LW:
                     (opcode_in == `OP_LWL)?`MEM_LWL:
                     (opcode_in == `OP_LWR)?`MEM_LWR:
                     (opcode_in == `OP_SB)?`MEM_SB:
                     (opcode_in == `OP_SH)?`MEM_SH:
                     (opcode_in == `OP_SW)?`MEM_SW:
                     (opcode_in == `OP_SWL)?`MEM_SWL:
                     (opcode_in == `OP_SWR)?`MEM_SWR:
                     4'b0000;
                     
    /*assign MemReadD = (opcode_in == `OP_LB)?1'b1:
                     (opcode_in == `OP_LBU)?1'b1:
                     (opcode_in == `OP_LH)?1'b1:
                     (opcode_in == `OP_LHU)?1'b1:
                     (opcode_in == `OP_LW)?1'b1:
                     (opcode_in == `OP_LWL)?1'b1:
                     (opcode_in == `OP_LWR)?1'b1:
                     (opcode_in == `OP_SB)?1'b0:
                     (opcode_in == `OP_SH)?1'b0:
                     (opcode_in == `OP_SW)?1'b0:
                     (opcode_in == `OP_SWL)?1'b0:
                     (opcode_in == `OP_SWR)?1'b0:
                     1'b0;
    
*/
   assign CP0WriteD = (Instr_in[31:21] == 11'b01000000100 && // mfco docode
			         Instr_in[10:0] == 11'b00000000000)? 1'b1:
                     1'b0;
                     

   
                        

    
endmodule

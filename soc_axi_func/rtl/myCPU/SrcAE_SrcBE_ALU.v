`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 03:33:28 AM
// Design Name: 
// Module Name: SrcAE_SrcBE_ALU
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


module SrcAE_SrcBE_ALU(
    //input clock,
    //input reset,
    // control signal
    input [`ALUCONTROL_SIZE]ALUControlE,
	input [`R_SIZE] ShiftsE,	//hjw
    
    // input
    input [`DATALENGTH] SrcAE,
    input [`DATALENGTH] SrcBE,
    input [8:0] ExceptType_in,
    

    output [`DATALENGTH]ALUOutE,
    
    // for hilo
    output [`DATALENGTH] ALUOutHighE,
    output [8:0] ExceptTypeE
 //   output [`DATALENGTH] hi,      
  //  output [`DATALENGTH] lo        
    
    );
    
    wire [32:0] tmp_add;         // for tmp result
    assign tmp_add = {SrcAE[31],SrcAE} + {SrcBE[31],SrcBE};     // to be done
    
    wire [32:0] tmp_sub;         // for tmp result
    assign tmp_sub = {SrcAE[31],SrcAE} - {SrcBE[31],SrcBE};     // to be done
   
   // wire [63:0]mul_result;
   // wire if_sig;
   // wire [`DATALENGTH] mul_data_1;
   // wire [`DATALENGTH] mul_data_2;
    
    //wire [`DATALENGTH] CP0_reg;////
    
    //assign if_sig = (ALUControlE == `ALU_MUL)?1'b1:1'b0;
    //assign mul_data_1 = (if_sig && SrcAE[31] == 1'b1)?(~SrcAE+1'b1):SrcAE;
    //assign mul_data_2 = (if_sig && SrcBE[31] == 1'b1)?(~SrcBE+1'b1):SrcBE;
    //assign mul_result = ((SrcAE[31] ^ SrcBE[31] == 1'b1) && (if_sig == 1'b1))?(~(mul_data_1 * mul_data_2)+1'b1):(mul_data_1 * mul_data_2);
    
    // yi chang mei chu li
    assign ALUOutE = (ALUControlE == `ALU_OR)? (SrcAE | SrcBE) :
                     (ALUControlE == `ALU_ADD)? (SrcAE + SrcBE) :
                     (ALUControlE == `ALU_ADD_OVERFLOW && tmp_add[32] == tmp_add[31])? tmp_add[31:0] :
                     (ALUControlE == `ALU_ADD_OVERFLOW && tmp_add[32] != tmp_add[31])? `ZEROWORD :
                     (ALUControlE == `ALU_SUB)? (SrcAE - SrcBE) :
                     (ALUControlE == `ALU_SUB_OVERFLOW && tmp_sub[32] == tmp_sub[31])? tmp_sub[31:0] :
                     (ALUControlE == `ALU_SUB_OVERFLOW && tmp_sub[32] != tmp_sub[31])? `ZEROWORD :
                     (ALUControlE == `ALU_SLT && SrcAE[31] == 1'b1 && SrcBE[31] == 1'b0)? 32'h00000001 :
                     (ALUControlE == `ALU_SLT && SrcAE[31] == 1'b0 && SrcBE[31] == 1'b1)? `ZEROWORD :
                     (ALUControlE == `ALU_SLT && tmp_sub[31] == 1'b1)? 32'h00000001 :
                     (ALUControlE == `ALU_SLTU && {1'b0,SrcAE} < {1'b0,SrcBE})? 32'h00000001 :
                     (ALUControlE == `ALU_AND)? (SrcAE & SrcBE) :
                     (ALUControlE == `ALU_XOR)? (SrcAE ^ SrcBE) :
                     (ALUControlE == `ALU_NOR)? ~(SrcAE | SrcBE) :
                     (ALUControlE == `ALU_SLL)? (SrcBE << ShiftsE) :
                     (ALUControlE == `ALU_SRA)? (({32{SrcBE[31]}} << (6'd32-{1'b0,ShiftsE})) | SrcBE >> ShiftsE) :
                     (ALUControlE == `ALU_SRL)? (SrcBE >> ShiftsE) :
                     (ALUControlE == `ALU_NONE || ALUControlE == `ALU_MTC0)? SrcBE :
                     //(ALUControlE == `ALU_MUL || ALUControlE == `ALU_MULU)? mul_result[31:0]:
                     (ALUControlE == `ALU_MTLO)? SrcAE :
                     `ZEROWORD;
     assign ALUOutHighE = // (ALUControlE == `ALU_MUL || ALUControlE == `ALU_MULU)? mul_result[63:32]:
                          (ALUControlE == `ALU_MTHI)?SrcAE:
                          `ZEROWORD;
     assign ExceptTypeE = ((ALUControlE == `ALU_ADD_OVERFLOW && tmp_add[32] != tmp_add[31])||
                          (ALUControlE == `ALU_SUB_OVERFLOW && tmp_sub[32] != tmp_sub[31])) ? (ExceptType_in|`OV_EX):
                          ExceptType_in;
    /*
    always@(*)begin
        if(reset == `RESETABLE)begin
            ALUOutE <= `ZEROWORD;
            ALUOutHighE <= `ZEROWORD;
        end 
        else begin
            case(ALUControlE)
                // this place is for ALU calcluate.
                `ALU_OR:begin
                    ALUOutE <= SrcAE | SrcBE;
                end
                `ALU_ADD:begin
                    ALUOutE <= SrcAE + SrcBE;
                end
                `ALU_ADD_OVERFLOW:begin
                    if(tmp_add[32] != tmp_add[31])begin
                        ALUOutE <= `ZEROWORD;
                        // li wai ~~~ there
                    end else begin
                        ALUOutE <= tmp_add[31:0];
                    end

                end
                `ALU_SUB:begin
                    ALUOutE <= SrcAE - SrcBE;
                end
                `ALU_SUB_OVERFLOW:begin
                    if(tmp_sub[32] != tmp_sub[31])begin
                        ALUOutE <= `ZEROWORD;
                    end else begin
                        ALUOutE <= tmp_sub[31:0];
                    end

                end
                `ALU_SLT:begin
                    // sig compare
                    if(SrcAE[31] == 1'b1 && SrcBE[31] == 1'b0)begin
                        ALUOutE <= 32'h00000001;
                    end
                    else if(SrcAE[31] == 1'b0 && SrcBE[31] == 1'b1)begin
                        ALUOutE <= `ZEROWORD;
                    end 
                    else if(tmp_sub[31] == 1'b1) begin
                        ALUOutE <= 32'h00000001;
                    end else begin
                        ALUOutE <= `ZEROWORD;
                    end
                end
                `ALU_SLTU:begin
                    if({1'b0,SrcAE} < {1'b0,SrcBE})begin
                        ALUOutE <= 32'h00000001;
                    end else begin
                        ALUOutE <= `ZEROWORD;
                    end
                end
                `ALU_AND:begin  //hjw
                    ALUOutE <= SrcAE & SrcBE;
                end
                `ALU_XOR:begin  //hjw
                    ALUOutE <= SrcAE ^ SrcBE;
                end
                `ALU_NOR:begin  //hjw
                    ALUOutE <= ~(SrcAE | SrcBE);
                end
                `ALU_SLL:begin  //hjw
                    ALUOutE <= SrcBE << ShiftsE;
                end
                `ALU_SRA:begin  //hjw
                    ALUOutE <= ({32{SrcBE[31]}} << (6'd32-{1'b0,ShiftsE})) | SrcBE >> ShiftsE;
                end
                `ALU_SRL:begin  //hjw
                    ALUOutE <= SrcBE >> ShiftsE;
                end
				`ALU_NONE:begin    //hjw
                    ALUOutE <= SrcBE;
                end
                `ALU_MUL,`ALU_MULU:begin
                    ALUOutHighE <= mul_result[63:32];
                    ALUOutE <= mul_result[31:0];
                end
                `ALU_MTHI:begin
                    ALUOutHighE <= SrcAE;
                end
                `ALU_MTLO:begin
                    ALUOutE <= SrcAE;
                end
                `ALU_MTC0:begin
                    ALUOutE <= SrcBE;
                end
                default:begin
                    ALUOutE <= `ZEROWORD;
                end
            endcase
        end
    end
    */
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2019 04:14:14 AM
// Design Name: 
// Module Name: hazard_unit
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

module hazard_unit(
    //input clock,
    //input reset,
    
    // control signal
        // from writeback part
        input RegWriteW,
        // from access memory part
        input RegWriteM,
        input MemtoRegM,
        // from exe part
        input RegWriteE,
        input MemtoRegE,
        // from decode part
        input BranchD,
        input HilotoRegE,           // 5.6 
        input CP0toRegE,
        
        // added by LH, for data sram 1 T delay
        input dataflag,
        input instflag,
        input MemReadE,
        input writeregflag,
        input CP0writeM,// add for cpfo_hazzd
   
   // input 
        //from writeback part
        input [`R_SIZE] WriteRegW,
        //from access memory pary
        input [`R_SIZE] WriteRegM,
        //from exe part
        input [`R_SIZE] WriteRegE,
        input [`R_SIZE] RsE,
        input [`R_SIZE] RtE,
        // from decode part
        input [`R_SIZE] RsD,
        input [`R_SIZE] RtD, 
        input divBusy,
        input mulBusy,
        
        // exception signal
        input exceptionM,
        input inst_sram_data_ok,
        input data_sram_data_ok,
        input data_sram_addr_ok,
        input MemWriteM,
    
   // output 
   output [1:0] ForwardAE,
   output [1:0] ForwardBE,
   
   output ForwardAD,
   output ForwardBD,
   //output Forwardcp0E,
   

   
   output chooseExcPCF,
   output FlushD,
   output FlushE,
   output FlushM,
   output FlushW,
   
   output StallCP0,
   output  StallD,
   output  StallF,
   
   // added by LH, for data sram 1 T delay
   output StallE,
   output StallM,
   output StallW
    );
    
    
    // added by LH, for data sram 1 T delay
    /*reg flagReadMem;
    always @(posedge clock)begin
        if(reset == `RESETABLE)begin
            flagReadMem <= 1'b0;
        end else if(MemReadM == 1'b1 && flagReadMem == 1'b0)begin
            flagReadMem <= 1'b1;
        end else begin
            flagReadMem <= 1'b0;
        end
    end*/
   /*
    assign StallE = (reset == `RESETABLE) ? 1'b0 : flagReadMem;
    assign StallM = (reset == `RESETABLE) ? 1'b0 : flagReadMem;
    assign StallW = (reset == `RESETABLE) ? 1'b0 : flagReadMem;
    */
    //assign StallE = MemReadM;
    assign StallM = mulBusy||divBusy || (dataflag && !exceptionM) || (instflag );
    assign StallCP0 = mulBusy||divBusy || (dataflag && !exceptionM) || (instflag );
    //assign StallM = (reset == `RESETABLE) ? 1'b0:((divBusy) || (dataflag) || (instflag ) || (BranchD && (CP0toRegE || HilotoRegE || MemReadE) && ((RsD == WriteRegE) || (RtD == WriteRegE)) && (WriteRegE != 0)));
    assign StallW = mulBusy||divBusy || (dataflag && !exceptionM) || (instflag ); 
    assign StallF = ((mulBusy||divBusy) || (dataflag && !exceptionM) || (instflag ) || (!exceptionM && BranchD && ((RsD == WriteRegE) || (RtD == WriteRegE)) && (WriteRegE != 0)));
    assign StallD = ((mulBusy||divBusy) || (dataflag && !exceptionM) || (instflag ) || (!exceptionM && BranchD && ((RsD == WriteRegE) || (RtD == WriteRegE)) && (WriteRegE != 0)));
    assign StallE = mulBusy||divBusy || (dataflag && !exceptionM) || (instflag );
    assign FlushE = (exceptionM||(!(dataflag ) && !(instflag) && (BranchD && ((RsD == WriteRegE) || (RtD == WriteRegE)) && (WriteRegE != 0))));
    assign chooseExcPCF = exceptionM;
    assign FlushD= exceptionM;
    assign FlushM = exceptionM; 
    assign FlushW = exceptionM; 
    
    //reg control;
    
    // zhe li tian jia le xiu gai, xie ru de mu biao ji cun qi bu neng shi $0
    // zhe shi wei le bi mian qing kong shi hou chu cuo
    //wire lwstall;
    //assign lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE && (RtE != 0);
    //assign lwstall = 1'b0;
    //wire branchstall;
    //assign branchstall = ((BranchD) && (MemtoRegM) && ((WriteRegM == RsD) || (WriteRegM == RtD)) && WriteRegM != 0);


    //assign FlushE = (reset == `RESETABLE) ? 1'b0:(lwstall || branchstall);

    
    assign ForwardAD = ((RsD != 5'b00000) && (RsD == WriteRegM) && (RegWriteM == 1'b1)) ? 1'b1:
                        1'b0;
    assign ForwardBD = //((RtD != 5'b00000) && (RtD == WriteRegE) && (RegWriteE == 1'b1)) ? 2'b01:
                    ((RtD != 5'b00000) && (RtD == WriteRegM) && (RegWriteM == 1'b1)) ? 1'b1:
                    1'b0;
    
    
    assign ForwardAE = ((RsE != 5'b00000) &&( RsE == WriteRegM) && (RegWriteM == 1'b1)) ? 2'b10:
                    ((RsE != 5'b00000) &&( RsE == WriteRegW) && (writeregflag == 1'b1)) ? 2'b01:
                    2'b00;
    assign ForwardBE = ((RtE != 5'b00000) &&( RtE == WriteRegM) && (RegWriteM == 1'b1)) ? 2'b10:
                    ((RtE != 5'b00000) &&( RtE == WriteRegW) && (writeregflag == 1'b1)) ? 2'b01:
                    2'b00;
                    
   // assign Forwardcp0E = CP0WriteM && WriteRegM == rdE;
    /*
    always@(*)begin
        if(reset == `RESETABLE)begin
            ForwardAE <= 2'b00;
            ForwardBE <= 2'b00;
            StallF <= 1'b0;
            StallD <= 1'b0;
            FlushE <= 1'b0;
        end
        else begin
            //ForwardAE
            if((RsE != 5'b00000) &&( RsE == WriteRegM) && (RegWriteM == 1'b1))begin
                ForwardAE <= 2'b10;
            end
            else if((RsE != 5'b00000) &&( RsE == WriteRegW) && (RegWriteW == 1'b1))begin
                ForwardAE <= 2'b01;
            end else begin
                ForwardAE <= 2'b00;
            end
            //ForwardBE
            if((RtE != 5'b00000) &&( RtE == WriteRegM) && (RegWriteM == 1'b1))begin
                ForwardBE <= 2'b10;
            end
            else if((RtE != 5'b00000) &&( RtE == WriteRegW) && (RegWriteW == 1'b1))begin
                ForwardBE <= 2'b01;
            end else begin
                ForwardBE <= 2'b00;
            end
            // 5.6
            StallF <= (lwstall || branchstall);
            StallD <= (lwstall || branchstall);
            FlushE <= (lwstall || branchstall);
            
            // ForwardAD
            if((RsD != 5'b00000) && (RsD == WriteRegM) && (RegWriteM == 1'b1))begin
                ForwardAD <= 1'b1;
            end
            else begin
                ForwardAD <= 1'b0;
            end
            // ForwardBD
            if((RtD != 5'b00000) && (RtD == WriteRegM) && (RegWriteM == 1'b1))begin
                ForwardBD <= 1'b1;
            end
            else begin
                ForwardBD <= 1'b0;
            end
        end
    end
    */
endmodule

`timescale 1ns / 1ps
`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2019 01:59:03 AM
// Design Name: 
// Module Name: cp0_reg
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


module cp0_reg(
    input wire clock,
    input wire reset,
    
    // control signal
    input WriteCP0M,
    input ReadCP0M,
    //input
    input [4:0] cp0_reg,
    input [`DATALENGTH] data_in,
	
	input StallCP0,
    input [5:0] int,
	
	input wire [8:0]  ExceptTypeM,
	input wire [31:0] ExceptAddr,
	input wire  InDelaySlotM,
	input wire [31:0] data_sram_addr,
	//output
    output [`DATALENGTH] data_out,
    
//	input wire[31:0] excepttype_i,
	
//	input wire[`DATALENGTH] current_inst_addr_i,
//	input wire is_in_delayslot_i,
    //output the value of cp0_reg
	output reg timer_int,
	
	output wire ExceptFlush,
	output [`DATALENGTH] newPC
	//output [`PCSIZE] Entrance
    
    );
	reg[`DATALENGTH] count;
	reg[`DATALENGTH] compare;
	reg[`DATALENGTH] status;
	reg[`DATALENGTH] cause;
	(* max_fanout = "15" *) reg[`DATALENGTH] epc;
	reg[`DATALENGTH] badvaddr;
	
	wire[9:0]Except;
	reg INt;
	

	assign Except = (reset == `RESETABLE)?`ZEROWORD:
	                //((ExceptTypeM & `INT_EX) > 0) ? `INT_EX :
	                ((ExceptTypeM & `ADEP_EX) >0 ) ? `ADEP_EX:
	                ((ExceptTypeM & `INSTRINVAILD_EX) > 0)?`INSTRINVAILD_EX:
	                ((ExceptTypeM & `OV_EX) >0 )? `OV_EX:
	                ((ExceptTypeM & `SYSCALL_EX) >0 ) ?  `SYSCALL_EX:
	                ((ExceptTypeM & `BREAK_EX) >0)? `BREAK_EX:
	                ((ExceptTypeM & `ADES_EX ) >0) ?`ADES_EX:
	                ((ExceptTypeM & `ADEL_EX) >0 )? `ADEL_EX:
	                ((ExceptTypeM & `Eret_EX) >0)? `Eret_EX:
	                9'b000000000;
	//assign INt =((cause[15:8] & (status[15:8])) !=8'b00000000) &&(status[1] == 1'b0) && (status[0] == 1'b1) && StallCP0 == 1'b0;
	                

    always @ (posedge clock) begin
		if(reset == `RESETABLE) begin
			count <= `ZEROWORD;
			compare <= `ZEROWORD;
			status <= 32'b00000000010000000000000000000000;
			cause <= `ZEROWORD;
			epc <= `ZEROWORD;
            timer_int <= `INTERRUPTUNABLE;
            badvaddr <= `ZEROWORD;
            
            INt <= 1'b0;

		end else begin
		    count <= count + 1 ;
		    cause[15:10] <= int;
		      if(compare != `ZEROWORD && count == compare) begin
			timer_int <= `INTERRUPTABLE;
			end
					
	   if(WriteCP0M == `WRITEABLE) begin
			case (cp0_reg) 
				`CP0_REG_COUNT:		begin
					count <= data_in;
				end
				`CP0_REG_COMPARE:	begin
					compare<= data_in;
                    timer_int <= `INTERRUPTUNABLE;
				end
				`CP0_REG_STATUS:	begin
					status[21:0] <= data_in[21:0];
					status[31:23] <= data_in[31:23];
					
				end
				`CP0_REG_EPC:	begin
					epc <= data_in;
				end
				`CP0_REG_CAUSE:	begin
					cause[9:8] <= data_in[9:8];
			
			    end
			    default:begin
			    end					
				endcase  
			end  //end if(WriteCP0)
		
		if(((cause[15:8] & status[15:8]) !=8'b00000000) &&
		      (status[1] == 1'b0) && (status[0] == 1'b1) && StallCP0 == 1'b0) begin
		  INt <= 1'b1;
		  
		  /*
		  if(InDelaySlotM == 1'b1) begin
		  // ??????????????????????????????
		      epc <= ExceptAddr-4  ;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr;
              cause[31] <= 1'b0;	      
		  end
		  */
          status[1] <= 1'b1;  //EXL
          cause[6:2] <= 5'b00000;
		      
	    end else if(StallCP0 == 1'b1)begin
	       INt <= INt;

	    end else begin
	       INt <= 1'b0;
	    end
	 
		      
	       // ssssssssssss
	       if(INt == 1'b1 && StallCP0 == 1'b0)begin
	           if(InDelaySlotM == 1'b1) begin
                  epc <= ExceptAddr - 12  ;
                  cause[31] <= 1'b1;  //BD
              end else begin
                  epc <= ExceptAddr - 8;
                  cause[31] <= 1'b0;	      
              end
	       end
		
		case(Except)
		/*
		  `INT_EX:begin
		  if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr -4;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr;
              cause[31] <= 1'b0;	      
		  end
		      status[1] <= 1'b1;  //EXL
		      cause[6:2] <= 5'b00000;
	 end
		*/  
		  
          `SYSCALL_EX:begin
          if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr - 12;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	      
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b01000;
	end
	     
	     `ADEL_EX:begin
	      if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr -12;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr -8;
              cause[31] <= 1'b0;	      
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b00100;
	          badvaddr <= data_in;
	          
	end	    
		 `ADES_EX: begin
          if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr -12;
		      cause[31] <= 1'b1;  //BD
		    end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	      
		    end
	      end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b00101;
	          badvaddr <= data_in;
	       end
	      `ADEP_EX: begin
	       if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr - 12;
		      cause[31] <= 1'b1;  //BD
		      badvaddr <= ExceptAddr - 8;
		  end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	
                badvaddr <= ExceptAddr - 8;
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b00100;
	          
	          
	end	
	          
		`OV_EX:begin
		  if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr - 12;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	      
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b01100;
	end
		  `BREAK_EX:begin
		  if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr -12;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	      
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <= 5'b01001;
	end
		  `INSTRINVAILD_EX:begin
		    if(status[1] == 1'b0)begin
            if(InDelaySlotM == 1'b1) begin
		      epc <= ExceptAddr -12;
		      cause[31] <= 1'b1;  //BD
		  end else begin
		      epc <= ExceptAddr - 8;
              cause[31] <= 1'b0;	      
		  end
	end
	          status[1] <= 1'b1;
	          cause[6:2] <=5'b01010;
	end 
	      `Eret_EX:begin
	      status[1] <= 1'b0;
	      end
	   default:   begin
	   end
	endcase
   end    // if(reset)
 end  //end always      

      
      assign data_out = (reset == `RESETABLE) ? `ZEROWORD:
                        (ReadCP0M ==1'b0) ? `ZEROWORD :
                        (cp0_reg == `CP0_REG_COUNT) ? count:
                        (cp0_reg == `CP0_REG_COMPARE) ? compare:
                        (cp0_reg == `CP0_REG_STATUS) ? status:
                        (cp0_reg == `CP0_REG_CAUSE) ? cause:
                        (cp0_reg == `CP0_REG_EPC) ? epc:
                        (cp0_reg == `CP0_REG_BADVADDR) ? badvaddr:
                        `ZEROWORD;

       assign ExceptFlush = (ExceptTypeM != 0 ||INt ==1);
       //assign Entrance = (ExceptTypeM !=0 ) ?  32'hBFC00380 : `ZEROWORD; 
       assign newPC = (reset == `RESETABLE)?`ZEROWORD:
                       (( Except == `SYSCALL_EX || Except == `ADEL_EX
                       || Except == `ADES_EX || Except == `ADEP_EX || Except == `OV_EX 
                       || Except == `BREAK_EX || Except == `INSTRINVAILD_EX) || INt == 1'b1) ? 32'hbfc00380:
                        (Except == `Eret_EX)? epc :
                        `ZEROWORD;
endmodule

`timescale 1ns / 1ps
// update PC 
`include "defines.vh"
module access_mem(
    input wire clock,
    //input wire reset,
    
    // control signal
    input MemWriteM,
    
    // input wire[`OP_SIZE] opcodeM,
    input [3:0] MemCtrlM,
    // input 
    input [`ADDRLENGTH] addr,
    input  [`DATALENGTH]writeData,
    //input wire[`DATALENGTH] mem_data_i,
    input  [`DATALENGTH] data_from_sram,
    input [8:0] ExceptType_in,
    input memory_req,
    input data_sram_data_ok,
    output data_sram_wr,
    output data_sram_req,
    //input data_sram_addr_ok,
    
    // output
    //output   data_sram_en,
    output  [1:0] data_sram_size,
    //output  [3:0] data_sram_wen,
    output  [31:0] data_sram_addr,
    output  [31:0] data_sram_wdata,
    
    //output reg[32:0]          mem_addr_o,
    //output reg                mem_we_o,
    //output reg[3:0]           mem_sel_o,
    //output reg[32:0]          mem_data_o,
    //output reg                mem_ce_o,
    
    output reg[`DATALENGTH]   readData,
    output wire data_cache,
    output wire[8:0]    ExceptTypeM
    
    // added by LH , for data sram one T delay
    //output wire MemReadM
    );
    
    // added by LH
    //assign MemReadM = (reset == `RESETABLE) ? 0 :
                      //(MemCtrlM == `MEM_LB || MemCtrlM == `MEM_LBU || MemCtrlM == `MEM_LH|| MemCtrlM == `MEM_LHU||MemCtrlM == `MEM_LW) ? 1 : 0;
    wire [`DATALENGTH] _readData;
    wire [31:0] zero32;
    assign zero32 =`ZeroWord;
    assign _readData = (MemCtrlM == `MEM_LB && data_sram_addr[1:0] == 2'b00)?{{24{data_from_sram[7]}},data_from_sram[7:0]}:
        (MemCtrlM == `MEM_LB && data_sram_addr[1:0] == 2'b01)?{{24{data_from_sram[15]}},data_from_sram[15:8]}:
        (MemCtrlM == `MEM_LB && data_sram_addr[1:0] == 2'b10)?{{24{data_from_sram[23]}},data_from_sram[23:16]}:
        (MemCtrlM == `MEM_LB && data_sram_addr[1:0] == 2'b11)?{{24{data_from_sram[31]}},data_from_sram[31:24]}:
        (MemCtrlM == `MEM_LBU && data_sram_addr[1:0] == 2'b00)?{{24{1'b0}},data_from_sram[7:0]}:
        (MemCtrlM == `MEM_LBU && data_sram_addr[1:0] == 2'b01)?{{24{1'b0}},data_from_sram[15:8]}:
        (MemCtrlM == `MEM_LBU && data_sram_addr[1:0] == 2'b10)?{{24{1'b0}},data_from_sram[23:16]}:
        (MemCtrlM == `MEM_LBU && data_sram_addr[1:0] == 2'b11)?{{24{1'b0}},data_from_sram[31:24]}:
        (MemCtrlM == `MEM_LH && data_sram_addr[1:0] == 2'b00)?{{16{data_from_sram[15]}},data_from_sram[15:0]}:
        (MemCtrlM == `MEM_LH && data_sram_addr[1:0] == 2'b10)?{{16{data_from_sram[31]}},data_from_sram[31:16]}:
        (MemCtrlM == `MEM_LHU && data_sram_addr[1:0] == 2'b00)?{{16{1'b0}},data_from_sram[15:0]}:
        (MemCtrlM == `MEM_LHU && data_sram_addr[1:0] == 2'b10)?{{16{1'b0}},data_from_sram[31:16]}:
        (MemCtrlM == `MEM_LW)?data_from_sram:`ZEROWORD;
    //reg [31:0] _data_sram_addr;
    assign data_sram_addr = (addr[31:30] == 2'b11)?addr:(addr[31:29] == 3'b101)?(addr-32'ha0000000):(addr[31] == 1'b1)?(addr-32'h80000000):addr;
    assign data_cache     =(addr[31:30] == 2'b11)?1'b1:(addr[31:29] == 3'b101)?1'b0:(addr[31] == 1'b1)?1'b1:1'b1;
    assign data_sram_wdata = (MemCtrlM == `MEM_SB)?{writeData[7:0],writeData[7:0],writeData[7:0],writeData[7:0]}:
                             (MemCtrlM == `MEM_SH)?{writeData[15:0],writeData[15:0]}:
                             (MemCtrlM == `MEM_SW)?writeData:
                             `ZEROWORD;
                             
    assign data_sram_size = (MemCtrlM == `MEM_LB || MemCtrlM == `MEM_LBU || MemCtrlM == `MEM_SB) ? 2'b00 :
                            (MemCtrlM == `MEM_LH || MemCtrlM == `MEM_LHU || MemCtrlM == `MEM_SH) ? 2'b01 :
                            (MemCtrlM == `MEM_LW || MemCtrlM == `MEM_SW) ? 2'b10 : 2'b00;
                            
    assign data_sram_req = memory_req && (ExceptTypeM == 0);
    assign data_sram_wr = memory_req && MemWriteM && (ExceptTypeM == 0);
    /*
    assign data_sram_wen = (reset == 1'b1 || ExceptTypeM > 0)?4'b0000:
                           (MemCtrlM == `MEM_LB || MemCtrlM == `MEM_LBU || MemCtrlM == `MEM_LH || MemCtrlM == `MEM_LHU || MemCtrlM == `MEM_LW || MemCtrlM == `MEM_SW)?{4{MemWriteM}}:
                           (MemCtrlM == `MEM_SB && data_sram_addr[1:0] == 2'b00)? {3'b000,{MemWriteM}}:
                           (MemCtrlM == `MEM_SB && data_sram_addr[1:0] == 2'b01)? {2'b00,{MemWriteM},1'b0}:
                           (MemCtrlM == `MEM_SB && data_sram_addr[1:0] == 2'b10)? {1'b0,{MemWriteM},2'b00}:
                           (MemCtrlM == `MEM_SB && data_sram_addr[1:0] == 2'b11)? {{MemWriteM},3'b000}:
                           (MemCtrlM == `MEM_SH && data_sram_addr[1:0] == 2'b00)? {2'b00,{2{MemWriteM}}}:
                           (MemCtrlM == `MEM_SH && data_sram_addr[1:0] != 2'b00)? {{2{MemWriteM}},2'b00}:
                           4'b0000;
     */
    /*assign data_sram_en = (reset == 1'b1 || ExceptTypeM > 0)?1'b0:
                          (MemCtrlM == `MEM_LB || MemCtrlM == `MEM_LBU || MemCtrlM == `MEM_LH || MemCtrlM == `MEM_LHU || MemCtrlM == `MEM_LW 
                          || MemCtrlM == `MEM_SB|| MemCtrlM == `MEM_SH|| MemCtrlM == `MEM_SW)?`ChipEnable:
                          1'b0;
    */                       
	assign ExceptTypeM = (((MemCtrlM == `MEM_LH || MemCtrlM == `MEM_LHU) && data_sram_addr[0] != 1'b0) || ((MemCtrlM == `MEM_LW) && data_sram_addr[1:0]!= 2'b00))  ? (`ADEL_EX|ExceptType_in):
					      (((MemCtrlM == `MEM_SH)&& data_sram_addr[0] != 1'b0) || ((MemCtrlM == `MEM_SW) && data_sram_addr[1:0]!= 2'b00)) ? (`ADES_EX|ExceptType_in):
						   ExceptType_in;
     always@(posedge clock) begin
        if(data_sram_data_ok == 1'b1) begin
            readData <= _readData;
        end else begin
            readData <= readData;
        end
     end

endmodule
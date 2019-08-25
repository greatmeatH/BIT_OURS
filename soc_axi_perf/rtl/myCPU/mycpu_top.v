`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2019 07:48:36 PM
// Design Name: 
// Module Name: mycpu_top
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


module mycpu_top(
    input         aclk         ,
    input  [0:0]  aresetn      ,
    input  [5:0]  int          ,
    
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock       ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       ,
    
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata

    );
    
    assign wid = 4'b0000;
    assign awid[3] = 1'b0;
    assign awid[2] = 1'b0;
    assign awid[1] = 1'b0;
    assign arid[3] = 1'b0;
    assign arid[2] = 1'b0;
    assign arid[1] = 1'b0;
    wire inst_sram_req;
    wire inst_sram_wr;
    wire [1:0] inst_sram_size;
    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_wdata;
    wire inst_sram_addr_ok;
    wire inst_sram_data_ok;
    wire [31:0] inst_sram_rdata;
    
    wire data_sram_req;
    wire data_sram_wr;
    wire [1:0] data_sram_size;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire data_sram_addr_ok;
    wire data_sram_data_ok;
    wire [31:0] data_sram_rdata;
    
    wire [31:0]cpu_axi_interface_0_m0_axi_ARADDR;
    wire [1:0]cpu_axi_interface_0_m0_axi_ARBURST;
    wire [3:0]cpu_axi_interface_0_m0_axi_ARCACHE;
    wire [0:0]cpu_axi_interface_0_m0_axi_ARID;
    wire [7:0]cpu_axi_interface_0_m0_axi_ARLEN;
    wire [1:0]cpu_axi_interface_0_m0_axi_ARLOCK;
    wire [2:0]cpu_axi_interface_0_m0_axi_ARPROT;
    wire cpu_axi_interface_0_m0_axi_ARREADY;
    wire [2:0]cpu_axi_interface_0_m0_axi_ARSIZE;
    wire cpu_axi_interface_0_m0_axi_ARVALID;
    wire [31:0]cpu_axi_interface_0_m0_axi_AWADDR;
    wire [1:0]cpu_axi_interface_0_m0_axi_AWBURST;
    wire [3:0]cpu_axi_interface_0_m0_axi_AWCACHE;
    wire [0:0]cpu_axi_interface_0_m0_axi_AWID;
    wire [7:0]cpu_axi_interface_0_m0_axi_AWLEN;
    wire [1:0]cpu_axi_interface_0_m0_axi_AWLOCK;
    wire [2:0]cpu_axi_interface_0_m0_axi_AWPROT;
    wire cpu_axi_interface_0_m0_axi_AWREADY;
    wire [2:0]cpu_axi_interface_0_m0_axi_AWSIZE;
    wire cpu_axi_interface_0_m0_axi_AWVALID;
    wire [0:0]cpu_axi_interface_0_m0_axi_BID;
    wire cpu_axi_interface_0_m0_axi_BREADY;
    wire [1:0]cpu_axi_interface_0_m0_axi_BRESP;
    wire cpu_axi_interface_0_m0_axi_BVALID;
    wire [31:0]cpu_axi_interface_0_m0_axi_RDATA;
    wire [0:0]cpu_axi_interface_0_m0_axi_RID;
    wire cpu_axi_interface_0_m0_axi_RLAST;
    wire cpu_axi_interface_0_m0_axi_RREADY;
    wire [1:0]cpu_axi_interface_0_m0_axi_RRESP;
    wire cpu_axi_interface_0_m0_axi_RVALID;
    wire [31:0]cpu_axi_interface_0_m0_axi_WDATA;
    wire cpu_axi_interface_0_m0_axi_WLAST;
    wire cpu_axi_interface_0_m0_axi_WREADY;
    wire [3:0]cpu_axi_interface_0_m0_axi_WSTRB;
    wire cpu_axi_interface_0_m0_axi_WVALID;
    
    wire [31:0]system_cache_0_M0_AXI_ARADDR;
    wire [1:0]system_cache_0_M0_AXI_ARBURST;
    wire [3:0]system_cache_0_M0_AXI_ARCACHE;
    wire [0:0]system_cache_0_M0_AXI_ARID;
    wire [7:0]system_cache_0_M0_AXI_ARLEN;
    wire system_cache_0_M0_AXI_ARLOCK;
    wire [2:0]system_cache_0_M0_AXI_ARPROT;
    wire [3:0]system_cache_0_M0_AXI_ARQOS;
    wire system_cache_0_M0_AXI_ARREADY;
    wire [2:0]system_cache_0_M0_AXI_ARSIZE;
    wire system_cache_0_M0_AXI_ARVALID;
    wire [31:0]system_cache_0_M0_AXI_AWADDR;
    wire [1:0]system_cache_0_M0_AXI_AWBURST;
    wire [3:0]system_cache_0_M0_AXI_AWCACHE;
    wire [0:0]system_cache_0_M0_AXI_AWID;
    wire [7:0]system_cache_0_M0_AXI_AWLEN;
    wire system_cache_0_M0_AXI_AWLOCK;
    wire [2:0]system_cache_0_M0_AXI_AWPROT;
    wire [3:0]system_cache_0_M0_AXI_AWQOS;
    wire system_cache_0_M0_AXI_AWREADY;
    wire [2:0]system_cache_0_M0_AXI_AWSIZE;
    wire system_cache_0_M0_AXI_AWVALID;
    wire [0:0]system_cache_0_M0_AXI_BID;
    wire system_cache_0_M0_AXI_BREADY;
    wire [1:0]system_cache_0_M0_AXI_BRESP;
    wire system_cache_0_M0_AXI_BVALID;
    wire [31:0]system_cache_0_M0_AXI_RDATA;
    wire [0:0]system_cache_0_M0_AXI_RID;
    wire system_cache_0_M0_AXI_RLAST;
    wire system_cache_0_M0_AXI_RREADY;
    wire [1:0]system_cache_0_M0_AXI_RRESP;
    wire system_cache_0_M0_AXI_RVALID;
    wire [31:0]system_cache_0_M0_AXI_WDATA;
    wire system_cache_0_M0_AXI_WLAST;
    wire system_cache_0_M0_AXI_WREADY;
    wire [3:0]system_cache_0_M0_AXI_WSTRB;
    wire system_cache_0_M0_AXI_WVALID;
    
    assign araddr[31:0] = system_cache_0_M0_AXI_ARADDR;
    assign arburst[1:0] = system_cache_0_M0_AXI_ARBURST;
    assign arcache[3:0] = system_cache_0_M0_AXI_ARCACHE;
    assign arid[0]= system_cache_0_M0_AXI_ARID;
    assign arlen [7:0] = system_cache_0_M0_AXI_ARLEN;
    assign arlock[1] =1'b0;
    assign arlock[0]  = system_cache_0_M0_AXI_ARLOCK;
    assign arprot[2:0] = system_cache_0_M0_AXI_ARPROT;
    //assign arqos[3:0]=system_cache_0_M0_AXI_ARQOS;
    //assign arready = system_cache_0_M0_AXI_ARREADY;
    assign arsize[2:0] = system_cache_0_M0_AXI_ARSIZE;
    assign arvalid = system_cache_0_M0_AXI_ARVALID;
    assign awaddr[31:0] = system_cache_0_M0_AXI_AWADDR;
    assign awburst[1:0] = system_cache_0_M0_AXI_AWBURST;
    assign awcache[3:0] = system_cache_0_M0_AXI_AWCACHE;
    assign awid[0] = system_cache_0_M0_AXI_AWID;
    assign awlen[7:0] = system_cache_0_M0_AXI_AWLEN;
    assign awlock[1] = 1'b0;
    assign awlock[0] = system_cache_0_M0_AXI_AWLOCK;
    assign awprot[2:0] = system_cache_0_M0_AXI_AWPROT;
   // assign awqos[3:0] = system_cache_0_M0_AXI_AWQOS;
   // assign awready = system_cache_0_M0_AXI_AWREADY;
    assign awsize[2:0] = system_cache_0_M0_AXI_AWSIZE;
    assign awvalid = system_cache_0_M0_AXI_AWVALID;
    //assign bid = system_cache_0_M0_AXI_BID;
    assign bready = system_cache_0_M0_AXI_BREADY;
   // assign bresp[1:0] = system_cache_0_M0_AXI_BRESP;
   // assign bvalid = system_cache_0_M0_AXI_BVALID;
    //assign rdata[31:0] = system_cache_0_M0_AXI_RDATA;
    //assign rid = system_cache_0_M0_AXI_RID;
   // assign rlast = system_cache_0_M0_AXI_RLAST;
    assign rready = system_cache_0_M0_AXI_RREADY;
   // assign rresp[1:0] = system_cache_0_M0_AXI_RRESP;
   // assign rvalid = system_cache_0_M0_AXI_RVALID;
    assign wdata[31:0] = system_cache_0_M0_AXI_WDATA;
    assign wlast = system_cache_0_M0_AXI_WLAST;
    //assign wready = system_cache_0_M0_AXI_WREADY;
    assign wstrb[3:0] = system_cache_0_M0_AXI_WSTRB;
    assign wvalid = system_cache_0_M0_AXI_WVALID;
    
  
    wire inst_sram_cache;
    wire data_sram_cache;
    
    cpu_axi_interface cpu_axi_interface0(
    .clk(aclk),
    .resetn(aresetn),
    
    .inst_req(inst_sram_req),
    .inst_wr(inst_sram_wr),
    .inst_size(inst_sram_size),
    .inst_addr(inst_sram_addr),
    .inst_wdata(inst_sram_wdata),
    .inst_rdata(inst_sram_rdata),
    .inst_addr_ok(inst_sram_addr_ok),
    .inst_data_ok(inst_sram_data_ok),
    .inst_cache(inst_sram_cache),
    
    .data_req(data_sram_req),
    .data_wr(data_sram_wr),
    .data_size(data_sram_size),
    .data_addr(data_sram_addr),
    .data_wdata(data_sram_wdata),
    .data_rdata(data_sram_rdata),
    .data_addr_ok(data_sram_addr_ok),
    .data_data_ok(data_sram_data_ok),
    .data_cache(data_sram_cache),
    
    .m0_axi_araddr(cpu_axi_interface_0_m0_axi_ARADDR),
    .m0_axi_arburst(cpu_axi_interface_0_m0_axi_ARBURST),
    .m0_axi_arcache(cpu_axi_interface_0_m0_axi_ARCACHE),
    .m0_axi_arid(cpu_axi_interface_0_m0_axi_ARID),
    .m0_axi_arlen(cpu_axi_interface_0_m0_axi_ARLEN),
    .m0_axi_arlock(cpu_axi_interface_0_m0_axi_ARLOCK),
    .m0_axi_arprot(cpu_axi_interface_0_m0_axi_ARPROT),
    .m0_axi_arready(system_cache_0_M0_AXI_ARREADY),     //
    .m0_axi_arsize(cpu_axi_interface_0_m0_axi_ARSIZE),
    .m0_axi_arvalid(cpu_axi_interface_0_m0_axi_ARVALID),//
    .m0_axi_awaddr(cpu_axi_interface_0_m0_axi_AWADDR),
    .m0_axi_awburst(cpu_axi_interface_0_m0_axi_AWBURST),
    .m0_axi_awcache(cpu_axi_interface_0_m0_axi_AWCACHE),
    .m0_axi_awid(cpu_axi_interface_0_m0_axi_AWID),
    .m0_axi_awlen(cpu_axi_interface_0_m0_axi_AWLEN),
    .m0_axi_awlock(cpu_axi_interface_0_m0_axi_AWLOCK),
    .m0_axi_awprot(cpu_axi_interface_0_m0_axi_AWPROT),
    .m0_axi_awready(system_cache_0_M0_AXI_AWREADY),
    .m0_axi_awsize(cpu_axi_interface_0_m0_axi_AWSIZE),
    .m0_axi_awvalid(cpu_axi_interface_0_m0_axi_AWVALID),
    .m0_axi_bid(system_cache_0_M0_AXI_BID),
    .m0_axi_bready(cpu_axi_interface_0_m0_axi_BREADY),
    .m0_axi_bresp(system_cache_0_M0_AXI_BRESP),
    .m0_axi_bvalid(system_cache_0_M0_AXI_BVALID),
    .m0_axi_rdata(system_cache_0_M0_AXI_RDATA),
    .m0_axi_rid(system_cache_0_M0_AXI_RID),
    .m0_axi_rlast(system_cache_0_M0_AXI_RLAST),
    .m0_axi_rready(cpu_axi_interface_0_m0_axi_RREADY),
    .m0_axi_rresp(system_cache_0_M0_AXI_RRESP),
    .m0_axi_rvalid(system_cache_0_M0_AXI_RVALID),
    .m0_axi_wdata(cpu_axi_interface_0_m0_axi_WDATA),
    .m0_axi_wlast(cpu_axi_interface_0_m0_axi_WLAST),
    .m0_axi_wready(system_cache_0_M0_AXI_WREADY),
    .m0_axi_wstrb(cpu_axi_interface_0_m0_axi_WSTRB),
    .m0_axi_wvalid(cpu_axi_interface_0_m0_axi_WVALID)
     
    );
    
    system_cache_0 system_cache_0
       (.ACLK(aclk),
        .ARESETN(aresetn),
        .M0_AXI_ARADDR(system_cache_0_M0_AXI_ARADDR),
        .M0_AXI_ARBURST(system_cache_0_M0_AXI_ARBURST),
        .M0_AXI_ARCACHE(system_cache_0_M0_AXI_ARCACHE),
        .M0_AXI_ARID(system_cache_0_M0_AXI_ARID),
        .M0_AXI_ARLEN(system_cache_0_M0_AXI_ARLEN),
        .M0_AXI_ARLOCK(system_cache_0_M0_AXI_ARLOCK),
        .M0_AXI_ARPROT(system_cache_0_M0_AXI_ARPROT),
        .M0_AXI_ARQOS(system_cache_0_M0_AXI_ARQOS),
        .M0_AXI_ARREADY(arready),
        .M0_AXI_ARSIZE(system_cache_0_M0_AXI_ARSIZE),
        .M0_AXI_ARVALID(system_cache_0_M0_AXI_ARVALID),
        .M0_AXI_AWADDR(system_cache_0_M0_AXI_AWADDR),
        .M0_AXI_AWBURST(system_cache_0_M0_AXI_AWBURST),
        .M0_AXI_AWCACHE(system_cache_0_M0_AXI_AWCACHE),
        .M0_AXI_AWID(system_cache_0_M0_AXI_AWID),
        .M0_AXI_AWLEN(system_cache_0_M0_AXI_AWLEN),
        .M0_AXI_AWLOCK(system_cache_0_M0_AXI_AWLOCK),
        .M0_AXI_AWPROT(system_cache_0_M0_AXI_AWPROT),
        .M0_AXI_AWQOS(system_cache_0_M0_AXI_AWQOS),
        .M0_AXI_AWREADY(awready),  //
        .M0_AXI_AWSIZE(system_cache_0_M0_AXI_AWSIZE),
        .M0_AXI_AWVALID(system_cache_0_M0_AXI_AWVALID),
        
        .M0_AXI_BID(bid[0]),
        .M0_AXI_BREADY(system_cache_0_M0_AXI_BREADY),
        .M0_AXI_BRESP(bresp),
        .M0_AXI_BVALID(bvalid),
        .M0_AXI_RDATA(rdata),
        
        .M0_AXI_RID(rid[0]),
        .M0_AXI_RLAST(rlast),
        .M0_AXI_RREADY(system_cache_0_M0_AXI_RREADY),
        
        .M0_AXI_RRESP(rresp),
        .M0_AXI_RVALID(rvalid),
        .M0_AXI_WDATA(system_cache_0_M0_AXI_WDATA),
        .M0_AXI_WLAST(system_cache_0_M0_AXI_WLAST),
        .M0_AXI_WREADY(wready),  //
        .M0_AXI_WSTRB(system_cache_0_M0_AXI_WSTRB),
        .M0_AXI_WVALID(system_cache_0_M0_AXI_WVALID),
        .S0_AXI_ARADDR(cpu_axi_interface_0_m0_axi_ARADDR),
        .S0_AXI_ARBURST(cpu_axi_interface_0_m0_axi_ARBURST),
        .S0_AXI_ARCACHE(cpu_axi_interface_0_m0_axi_ARCACHE),
        .S0_AXI_ARID(cpu_axi_interface_0_m0_axi_ARID),
        .S0_AXI_ARLEN(cpu_axi_interface_0_m0_axi_ARLEN),
        .S0_AXI_ARLOCK(cpu_axi_interface_0_m0_axi_ARLOCK[0]),
        .S0_AXI_ARPROT(cpu_axi_interface_0_m0_axi_ARPROT),
        .S0_AXI_ARQOS({1'b0,1'b0,1'b0,1'b0}),
        
        .S0_AXI_ARREADY(system_cache_0_M0_AXI_ARREADY),
        .S0_AXI_ARSIZE(cpu_axi_interface_0_m0_axi_ARSIZE),
        .S0_AXI_ARVALID(cpu_axi_interface_0_m0_axi_ARVALID),
        .S0_AXI_AWADDR(cpu_axi_interface_0_m0_axi_AWADDR),
        .S0_AXI_AWBURST(cpu_axi_interface_0_m0_axi_AWBURST),
        .S0_AXI_AWCACHE(cpu_axi_interface_0_m0_axi_AWCACHE),
        .S0_AXI_AWID(cpu_axi_interface_0_m0_axi_AWID),
        .S0_AXI_AWLEN(cpu_axi_interface_0_m0_axi_AWLEN),
        .S0_AXI_AWLOCK(cpu_axi_interface_0_m0_axi_AWLOCK[0]),
        .S0_AXI_AWPROT(cpu_axi_interface_0_m0_axi_AWPROT),
        .S0_AXI_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S0_AXI_AWREADY(system_cache_0_M0_AXI_AWREADY),  //
        .S0_AXI_AWSIZE(cpu_axi_interface_0_m0_axi_AWSIZE),
        .S0_AXI_AWVALID(cpu_axi_interface_0_m0_axi_AWVALID),
        .S0_AXI_BID(system_cache_0_M0_AXI_BID),
        .S0_AXI_BREADY(cpu_axi_interface_0_m0_axi_BREADY),
        
        .S0_AXI_BRESP(system_cache_0_M0_AXI_BRESP),
        .S0_AXI_BVALID(system_cache_0_M0_AXI_BVALID),
        
        .S0_AXI_RDATA(system_cache_0_M0_AXI_RDATA),
        .S0_AXI_RID(system_cache_0_M0_AXI_RID),
        
        .S0_AXI_RLAST(system_cache_0_M0_AXI_RLAST),
        .S0_AXI_RREADY(cpu_axi_interface_0_m0_axi_RREADY),
        .S0_AXI_RRESP(system_cache_0_M0_AXI_RRESP),
        .S0_AXI_RVALID(system_cache_0_M0_AXI_RVALID),
        .S0_AXI_WDATA(cpu_axi_interface_0_m0_axi_WDATA),
        .S0_AXI_WLAST(cpu_axi_interface_0_m0_axi_WLAST),
        
        .S0_AXI_WREADY(system_cache_0_M0_AXI_WREADY),
        .S0_AXI_WSTRB(cpu_axi_interface_0_m0_axi_WSTRB),
        .S0_AXI_WVALID(cpu_axi_interface_0_m0_axi_WVALID)
        );
    
    
    wire _aresetn;
    assign _aresetn = ~aresetn;
    /*reg clk_double;
    reg count;
    always@(posedge clk) begin
        if(_resetn == 1'b1) begin
            count <= 0;
            clk_double <= 1;
        end else begin
            count <= count + 1;
            if(count == 1)begin
                clk_double <= ~clk_double;
            end
        end
    end*/
    

    mips core(
        .clock(aclk),
        .reset(_aresetn),
        .int(int),
        
        .inst_sram_req(inst_sram_req),
        .inst_sram_wr(inst_sram_wr),
        .inst_sram_size(inst_sram_size),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_wdata(inst_sram_wdata),
        .inst_sram_addr_ok(inst_sram_addr_ok),
        .inst_sram_data_ok(inst_sram_data_ok),
        .inst_sram_rdata(inst_sram_rdata),
        .instr_cache(inst_sram_cache),
        
        .data_sram_req(data_sram_req),
        .data_sram_wr(data_sram_wr),
        .data_sram_size(data_sram_size),
        .data_sram_addr(data_sram_addr),
        .data_sram_wdata(data_sram_wdata),
        .data_sram_addr_ok(data_sram_addr_ok),
        .data_sram_data_ok(data_sram_data_ok),
        .data_sram_rdata(data_sram_rdata),
        .data_cache(data_sram_cache),
        
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );
    
endmodule


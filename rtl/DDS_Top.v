`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2021 02:32:31 PM
// Design Name: 
// Module Name: DDS_Top
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


module DDS_Top(
input sys_clk,
input rstn_i , //#IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
             
input btnc_i , //#IO_L9P_T1_DQS_14 Sch=btnc
input btnu_i , //#IO_L4N_T0_D05_14 Sch=btnu
input btnl_i , //#IO_L12P_T1_MRCC_14 Sch=btnl
input btnr_i , //#IO_L10N_T1_D15_14 Sch=btnr
input btnd_i , //#IO_L9N_T1_DQS_D13_14 Sch=btnd

output wire [8:1] JA  ,
inout  wire [8:1] JB  ,
output wire [4:1] XA_N ,
output wire [4:1] XA_P 
    );

wire clk,Ref_Clk;
wire rstn = rstn_i;
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
  clk_wiz_0 clk_wiz_inst
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    .clk_out2(Ref_Clk),     // output clk_out2
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
    
reg [5:0] TimeCounter;
always @(posedge clk or negedge rstn)
    if (!rstn) TimeCounter <= 6'h00;
     else if (TimeCounter == 6'h18) TimeCounter <= 6'h00;
     else TimeCounter <= TimeCounter + 1;
     
wire vioRW ;
wire [31:0] vioData; 
wire vioStart;  
wire RunSeq;
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
    vio_0 vio_0_inst (
      .clk(clk),                // input wire clk
      .probe_out0(vioRW),  // output wire [0 : 0] probe_out0
      .probe_out1(vioData),  // output wire [31 : 0] probe_out1
      .probe_out2(vioStart),  // output wire [0 : 0] probe_out2
      .probe_out3(RunSeq)  // output wire [0 : 0] probe_out3
    );

wire  RegIOup;
reg  HighVal;
always @(posedge clk or negedge rstn)
    if (!rstn) HighVal <= 1'b0;
     else if (RegIOup) HighVal <= ~HighVal;
wire [31:0] WriteData = (!RunSeq) ? vioData :
                        (HighVal) ? 32'h0cd00d41 : 32'h0c000d3c;
reg [1:0] DevStart;
always @(posedge clk or negedge rstn)
    if (!rstn) DevStart <= 2'b00;
     else DevStart <= {DevStart[0],vioStart};
reg DtartW4Zero;
always @(posedge clk or negedge rstn)
    if (!rstn) DtartW4Zero <= 1'b0;
     else if (RunSeq) DtartW4Zero <= 1'b1;
     else if (DevStart == 2'b01) DtartW4Zero <= 1'b1;
     else if (TimeCounter == 6'h00) DtartW4Zero <= 1'b0;
reg RWtran;
always @(posedge clk or negedge rstn)
    if (!rstn) RWtran <= 1'b0;
     else if ((TimeCounter == 6'h18) && DtartW4Zero) RWtran <= 1'b1;
     else if  (TimeCounter == 6'h18) RWtran <= 1'b0;         

reg RegPclk;
always @(posedge clk or negedge rstn) 
    if (!rstn) RegPclk <= 1'b0;
     else if (TimeCounter == 6'h18) RegPclk <= 1'b1;         
     else if (TimeCounter[1] == 1'b0) RegPclk <= 1'b0;         
     else if (TimeCounter[1] == 1'b1) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h00) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h03) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h06) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h09) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h0C) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h0F) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h12) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h15) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h18) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h1B) RegPclk <= 1'b1;         
//     else if (TimeCounter == 6'h1E) RegPclk <= 1'b0;         
//     else if (TimeCounter == 6'h21) RegPclk <= 1'b1;         

reg RegCS;
always @(posedge clk or negedge rstn) 
    if (!rstn) RegCS <= 1'b1;
     else if (!RWtran) RegCS <= 1'b1;
     else if (TimeCounter == 6'h00) RegCS <= 1'b0;
     else if (TimeCounter == 6'h08) RegCS <= 1'b1;
     else if (TimeCounter == 6'h0c) RegCS <= 1'b0;
     else if (TimeCounter == 6'h14) RegCS <= 1'b1;

reg RegRWn;
always @(posedge clk or negedge rstn) 
    if (!rstn) RegRWn <= 1'b1;
     else if (TimeCounter == 6'h00) RegRWn <= vioRW;

reg [7:0] RegData;
always @(posedge clk or negedge rstn)
    if (!rstn) RegData <= 8'h00;
     else if (!RWtran) RegData <= 8'h00;
     else if (TimeCounter == 6'h00) RegData <= WriteData[31:24];
     else if (TimeCounter == 6'h04) RegData <= WriteData[23:16];
     else if (TimeCounter == 6'h0c) RegData <= WriteData[15:8];
     else if (TimeCounter == 6'h10) RegData <= WriteData[7:0];


reg ReadData;
always @(posedge clk or negedge rstn) 
    if (!rstn) ReadData <= 1'b0;
     else if (!RegRWn || !RWtran) ReadData <= 1'b0;
     else if (TimeCounter == 6'h04) ReadData <= 1'b1;
     else if (TimeCounter == 6'h0c) ReadData <= 1'b0;
     else if (TimeCounter == 6'h10) ReadData <= 1'b1;
     else if (TimeCounter == 6'h16) ReadData <= 1'b0;

//reg RegIOup;
//always @(posedge clk or negedge rstn) 
//    if (!rstn) RegIOup <= 1'b0;
//     else if (!RWtran || RegRWn) RegIOup <= 1'b0;
//     else if (TimeCounter == 6'h00) RegIOup <= 1'b0;
//     else if (TimeCounter == 6'h1F) RegIOup <= 1'b1;
    
assign  RegIOup = (RWtran && !RegRWn && (TimeCounter == 6'h18)) ? 1'b1 : 1'b0; 

assign XA_N[4] = Ref_Clk;
 assign JA[5] = ~rstn; // reset
 assign JA[2] = 1'b0;  // PowerDown
 assign JA[6] = RegIOup;  // IO_update
 assign JA[3] = RegCS;  // CSB
 assign JA[7] = RegRWn;  // RWn
 assign JA[4] = RegPclk;  // PCLK
 assign JA[8] = 1'b1;  // PAR
 assign JB[1] = (!ReadData) ? RegData[7] : 1'bz;   
 assign JB[5] = (!ReadData) ? RegData[6] : 1'bz;   
 assign JB[2] = (!ReadData) ? RegData[5] : 1'bz;   
 assign JB[6] = (!ReadData) ? RegData[4] : 1'bz;   
 assign JB[3] = (!ReadData) ? RegData[3] : 1'bz;   
 assign JB[7] = (!ReadData) ? RegData[2] : 1'bz;   
 assign JB[4] = (!ReadData) ? RegData[1] : 1'bz;   
 assign JB[8] = (!ReadData) ? RegData[0] : 1'bz;   

wire [7:0] DataReadFDDS;
assign DataReadFDDS[7] = JB[1];
assign DataReadFDDS[6] = JB[5];
assign DataReadFDDS[5] = JB[2];
assign DataReadFDDS[4] = JB[6];
assign DataReadFDDS[3] = JB[3];
assign DataReadFDDS[2] = JB[7];
assign DataReadFDDS[1] = JB[4];
assign DataReadFDDS[0] = JB[8];
//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ila_0 ila_inst (
	.clk(clk), // input wire clk

	.probe0(RegIOup), // input wire [0:0]  probe0  
	.probe1(RegCS ), // input wire [0:0]  probe1 
	.probe2(RegRWn), // input wire [0:0]  probe2 
	.probe3(RegPclk), // input wire [0:0]  probe3 
	.probe4(vioRW), // input wire [0:0]  probe4 
	.probe5(vioStart), // input wire [0:0]  probe5 
	.probe6(TimeCounter), // input wire [4:0]  probe6 
	.probe7(RegData), // input wire [7:0]  probe7 
	.probe8(Ref_Clk), // input wire [0:0]  probe8 
	.probe9(rstn), // input wire [0:0]  probe9
	.probe10(DataReadFDDS), // input wire [7:0]  probe10
	.probe11(ReadData) // input wire [0:0]  probe11
);

////----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
//ila_1 ila_1_inst (
//	.clk(clk), // input wire clk

//	.probe0(JA), // input wire [7:0]  probe0  
//	.probe1(DataReadFDDS) // input wire [7:0]  probe1
//);
     
endmodule

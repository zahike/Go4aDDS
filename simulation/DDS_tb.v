`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2021 20:43:27
// Design Name: 
// Module Name: DDS_tb
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


module DDS_tb();
reg clk ;
reg rstn;
initial begin
clk = 1'b0;
rstn = 1'b0;
#1000;
rstn = 1'b1; 
end

always #5 clk = ~clk;

reg vioRW ;
reg [31:0] vioData; 
reg vioStart;  
reg RunSeq;
initial begin 
force DDS_Top_inst.vioRW    = vioRW    ;
force DDS_Top_inst.vioData  = vioData  ; 
force DDS_Top_inst.vioStart = vioStart ;
force DDS_Top_inst.RunSeq   = RunSeq ;
vioRW    = 1'b0;
vioData  = 32'h00000000; 
vioStart = 1'b0;  
RunSeq   = 1'b0;
@(posedge rstn);
#1000;
vioRW    = 1'b0;
vioData  = 32'h0c120d34; 
vioStart = 1'b0;  
@(posedge clk);
vioStart = 1'b1;  
#1000;
vioRW    = 1'b1;
vioData  = 32'h04000500; 
vioStart = 1'b0;  
#1;
@(posedge clk);
vioStart = 1'b1;  
#1000;
vioRW    = 1'b0;
vioStart = 1'b0;  
RunSeq   = 1'b1;
#10000;
$finish;
end
DDS_Top DDS_Top_inst(
.sys_clk(clk),
.rstn_i (rstn)// #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
);

endmodule

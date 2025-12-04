`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 21:37:02
// Design Name: 
// Module Name: RF
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


module RF(input clk,//分频后的主时钟，实例化的时候弄上CPU_clk
input rst,
input RFWr,//mem2reg，写使能信号
input [15:0]sw_i,
input [4:0]A1,A2,A3,//第几个寄存器,sw_i的11到8指定寄存器号
input [31:0]WD,//write data，sw_i的7到4用来写入数据
output [31:0]RD1,RD2
    );
reg [31:0] rf[31:0];//定义32个寄存器
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
    for(integer i=0;i<8;i=i+1)
    begin
    rf[i]=i;
    end
    end
    else begin
    if(RFWr&&(!sw_i[1]))//非调试模式，并且写入信号有效，寄存器值可以被修改
    begin 
        rf[A3]=WD;//寄存器A3的值变为我输入的值,是有符号数
    end
    end
end
//integer i;
//always@(posedge clk or negedge rst)begin
//if(!rst)
//begin
//for(i=0;i<6;i=i+1)
//begin rf[i]=i;end
//end
//else begin
//if(RFWr&&(!sw_i[1]))//非调试模式，并且写入信号有效，寄存器值可以被修改
//begin 
//    rf[A3]=WD;//寄存器A3的值变为我输入的值,是有符号数
//end
//end
//end
assign RD1=(A1!=0)?rf[A1]:0;
assign RD2=(A2!=0)?rf[A2]:0;//若输出寄存器不是0号寄存器则输出它原本的值
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 22:18:32
// Design Name: 
// Module Name: DM
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

//DMWr写信号，6位地址，32位数据，DMType文档给了3种，sw_i[4:3],输出数据是从DM输入地址拿出的数据
module DM(input clk,input DMWr,input[5:0]addr,input [31:0]din,input [2:0]DMType,output reg [31:0]dout   );
reg [7:0]dmem[6:0];//二维数组，7个8位的
//定义类型
`define dm_byte 3'b011
`define dm_halfword 3'b001
`define dm_word 3'b000

//初始化128个单元
initial begin
dmem[0]=8'b00000000;
dmem[1]=8'b00000001;
dmem[2]=8'b00000010;
dmem[3]=8'b00000011;
dmem[4]=8'b00000100;
dmem[5]=8'b00000101;
dmem[6]=8'b00000110;
end
always@(posedge clk)
begin
if(DMWr==1'b1)//写信号为1,往所输入地址中添加输入数据
begin
case(DMType)
`dm_byte:dmem[addr]<=din[7:0];//地址有64种，代表64个内存单元，每个内存单元有8位
`dm_halfword:begin dmem[addr]<=din[7:0];dmem[addr+1]<=din[15:8]; end
`dm_word:begin dmem[addr]<=din[7:0];dmem[addr+1]<=din[15:8];dmem[addr+2]<=din[23:16];dmem[addr+3]<=din[31:24];end
endcase
end
end

always@(*)
begin
case(DMType)
`dm_byte:dout={{24{dmem[addr][7]}},dmem[addr][7:0]};//24{dmem[addr][7]}意味着把dmem[addr][7]复制24次，也就是符号扩展的作用
`dm_halfword:dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};
`dm_word:dout={{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};
endcase
end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/07 20:10:30
// Design Name: 
// Module Name: ALU
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

//A和B为参与计算的两个数，ALUop选择参与什么计算，C为参与计算的结果，Zero为两数是否相等
module ALU(input signed[31:0] A,B,input[4:0] ALUOp,output reg signed[31:0] C,output reg Zero);
//定义操作
//`define ALUOp_add 5'b00001
//`define ALUOp_sub 5'b00000//第一个实验
`define ALUOp_add 5'b00001
`define ALUOp_sub 5'b00010//第二个实验

always@(*)
begin
case(ALUOp)
`ALUOp_add:C=A+B;
`ALUOp_sub:C=A-B;
endcase
Zero=(C==0)?1:0;
end
endmodule

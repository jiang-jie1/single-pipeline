`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/09 12:53:23
// Design Name: 
// Module Name: lab2
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


module lab2(
    input clk,
    input rstn,
    input [15:0] sw_i,
    output [15:0] led_o
    );
  parameter div_num = 24;
  reg [15:0] led_tmp;
  reg ledset_flag;
  wire clk_div2;
  wire clk_div29;

  //clk_div2
  reg clk_div2_tmp;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) clk_div2_tmp <= 1'b0;
    else clk_div2_tmp <= ~clk_div2_tmp;
  end
  assign clk_div2 = clk_div2_tmp;

  //clk_div29
  reg [31:0] clk_cnt;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) clk_cnt <= 32'b0;
    else clk_cnt <= clk_cnt + 1;
  end
  assign clk_div29 = clk_cnt[div_num];
  reg [15:0]current_pos;
  //led splash
  always @(posedge clk_div29 or negedge rstn) begin
  if (!rstn) begin
    led_tmp <= 16'b0;
    ledset_flag <= 1'b1;
    current_pos <= 5'd15;  // 初始位置为sw_i[15]
  end else if ((ledset_flag == 1'b1) && (sw_i[4:1] == 4'b1010)) begin
    // 初始启动时点亮sw_i[15]对应的LED
    led_tmp <= 16'b1000_0000_0000_0000;
    ledset_flag <= 1'b0;
    current_pos <= 5'd14;  // 下一个位置为sw_i[14]
  end else if (sw_i[4:1] == 4'b1010) begin
    // 循环移位：从sw_i[15]依次移到sw_i[0]，再回到sw_i[15]
    led_tmp <= 16'b1 << current_pos;  // 当前位置对应的LED点亮
    current_pos <= (current_pos == 5'd0) ? 5'd15 : current_pos - 5'd1;  // 位置更新
  end else begin
    led_tmp <= 16'b0000_0000_0000_0000;
    ledset_flag <= 1'b1;
    current_pos <= 5'd15;  // 重置位置
  end
  end
  assign led_o[15:0] = led_tmp;
endmodule

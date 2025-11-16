`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/09 14:06:07
// Design Name: 
// Module Name: top
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


module sccomp(clk,rstn, sw_i,disp_seg_o , disp_an_o );
    input clk;
    input rstn;
    input [15:0] sw_i;
    output [7:0] disp_an_o,disp_seg_o;

    reg[31:0]clkdiv;
    wire  Clk_CPU;

    always @ (posedge clk or negedge rstn) begin
      if (!rstn) clkdiv <= 0;
      else clkdiv <= clkdiv + 1'b1; 
    end

    assign Clk_CPU=(sw_i[15])? clkdiv[27] : clkdiv[25];//2^

    reg [63:0] display_data;  //7 segments disp

    reg [5:0]led_data_addr;
    reg [63:0]led_disp_data;
    parameter LED_DATA_NUM = 19;
    
    reg  [63:0]LED_DATA[18:0];
    initial begin
      LED_DATA[0]=64'hC6F6F6F0C6F6F6F0;
      LED_DATA[1]=64'hF9F6F6CFF9F6F6CF;
      LED_DATA[2]=64'hFFC6F0FFFFC6F0FF;
      LED_DATA[3]=64'hFFC0FFFFFFC0FFFF;
      LED_DATA[4]=64'hFFA3FFFFFFA3FFFF;
      LED_DATA[5]=64'hFFFFA3FFFFFFA3FF;
      LED_DATA[6]=64'hFFFF9CFFFFFF9CFF;
      LED_DATA[7]=64'hFF9EBCFFFF9EBCFF;
      LED_DATA[8]=64'hFF9CFFFFFF9CFFFF;
      LED_DATA[9]=64'hFFC0FFFFFFC0FFFF;
      LED_DATA[10]=64'hFFA3FFFFFFA3FFFF;
      LED_DATA[11]=64'hFFA7B3FFFfA7B3FF;
      LED_DATA[12]=64'hFFC6F0FfFFC6F0FF;
      LED_DATA[13]=64'hF9F6F6CFF9F6F6CF;
      LED_DATA[14]=64'h9EBEBEBC9EBEBEBC;
      LED_DATA[15]=64'h2737373327373733;
      LED_DATA[16]=64'h505454EC505454EC;
      LED_DATA[17]=64'h744454F8744454F8;
      LED_DATA[18]=64'h0062080000620800;
// LED_DATA[0]=64'hFFFFFFFEFEFEFEFE;
//LED_DATA[1]=64'hFFFEFEFEFEFEFFFF;
//LED_DATA[2]=64'hDEFEFEFEFFFFFFFF;
//LED_DATA[3]=64'hCEFEFEFFFFFFFFFF;
//LED_DATA[4]=64'hC2FFFFFFFFFFFFFF;
//LED_DATA[5]=64'hC1FEFFFFFFFFFFFF;
//LED_DATA[6]=64'hF1FCFFFFFFFFFFFF;
//LED_DATA[7]=64'hFDF8F7FFFFFFFFFF;
//LED_DATA[8]=64'hFFF8F3FFFFFFFFFF;
//LED_DATA[9]=64'hFFFBF1FEFFFFFFFF;
//LED_DATA[10]=64'hFFFFF9F8FFFFFFFF;
//LED_DATA[11]=64'hFFFFFDF8F7FFFFFF;
//LED_DATA[12]=64'hFFFFFFF9F1FFFFFF;
//LED_DATA[13]=64'hFFFFFFFFF1FCFFFF;
//LED_DATA[14]=64'hFFFFFFFFF9F8FFFF;
//LED_DATA[15]=64'hFFFFFFFFFFF8F3FF;
//LED_DATA[16]=64'hFFFFFFFFFFFBF1FE;
//LED_DATA[17]=64'hFFFFFFFFFFFFF9BC;
//LED_DATA[18]=64'hFFFFFFFFFFFFBDBC;
//LED_DATA[19]=64'hFFFFFFFFBFBFBFBD;
//LED_DATA[20]=64'hFFFFBFBFBFBFBFFF;
//LED_DATA[21]=64'hFFBFBFBFBFBFFFFF;
//LED_DATA[22]=64'hAFBFBFBFFFFFFFFF;
//LED_DATA[23]=64'h2737FFFFFFFFFFFF;
//LED_DATA[24]=64'h277777FFFFFFFFFF;
//LED_DATA[25]=64'h7777777777FFFFFF;
//LED_DATA[26]=64'hFFFF7777777777FF;
//LED_DATA[27]=64'hFFFFFF7777777777;
//LED_DATA[28]=64'hFFFFFFFFFF777771;
//LED_DATA[29]=64'hFFFFFFFFFFFF7750;
//LED_DATA[30]=64'hFFFFFFFFFFFFFFC8;
//LED_DATA[31]=64'hFFFFFFFFFFFFE7CE;
//LED_DATA[32]=64'hFFFFFFFFFFFFC7CF;
//LED_DATA[33]=64'hFFFFFFFFFFDEC7FF;
//LED_DATA[34]=64'hFFFFFFFFF7CEDFFF;
//LED_DATA[35]=64'hFFFFFFFFC7CFFFFF;
//LED_DATA[36]=64'hFFFFFFFEC7EFFFFF;
//LED_DATA[37]=64'hFFFFFFCECFFFFFFF;
//LED_DATA[38]=64'hFFFFE7CEFFFFFFFF;
//LED_DATA[39]=64'hFFFFC7CFFFFFFFFF;
//LED_DATA[40]=64'hFFDEC7FFFFFFFFFF;
//LED_DATA[41]=64'hF7CEDFFFFFFFFFFF;
//LED_DATA[42]=64'hA7CFFFFFFFFFFFFF;
//LED_DATA[43]=64'hA7AFFFFFFFFFFFFF;
//LED_DATA[44]=64'hAFBFBFBFFFFFFFFF;
//LED_DATA[45]=64'hBFBFBFBFBFFFFFFF;
//LED_DATA[46]=64'hFFFFBFBFBFBFBFFF;
//LED_DATA[47]=64'hFFFFFFFFBFBFBFBD;
    end
        //产生LED_DATA
    always@(posedge Clk_CPU or negedge rstn) begin
      if(!rstn) begin led_data_addr = 6'd0 ;led_disp_data = 64'b1;end
      else if(sw_i[0]==1'b1) begin
        if (led_data_addr == LED_DATA_NUM) begin led_data_addr = 6'd0 ; led_disp_data = 64'b1;end
        led_disp_data = LED_DATA[led_data_addr];
        led_data_addr = led_data_addr + 1'd1;  end
      else led_data_addr  = led_data_addr ;
    end

    wire [31:0]  instr;
    reg[31:0] reg_data;//regvalue
    reg[31:0] alu_disp_data;
    reg [31:0] dmem_data;
    //choose display source data
    always @(sw_i) begin
      if (sw_i[0] == 0) begin
        case (sw_i[14:11])
          4'b1000:  display_data = instr;//ROM
          4'b0100:  display_data = reg_data;//RF
          4'b0010:  display_data = alu_disp_data;//
          4'b0001:  display_data = dmem_data;
          default:  display_data = 32'b01110110010101000011001000010000;
        endcase 
      end
      else  begin display_data = led_disp_data ; end
    end

    seg7x16 u_seg7x16(
        .clk(clk),
        .rstn (rstn),
        .i_data(display_data),
        .disp_mode(sw_i[0]),
        .o_seg(disp_seg_o),
        .o_sel(disp_an_o)
    );
    //指令显示模块
    parameter CODE_NUM=12;
    reg [7:0] rom_addr;
    dist_mem_gen_0 U_IM(.a(rom_addr),.spo(instr));
always@(posedge Clk_CPU or negedge rstn) begin
    if(!rstn) begin rom_addr=32'b0;end
    else if(sw_i[14]==1'b1) begin
        if (!sw_i[1]) rom_addr=rom_addr+1'b1;  // 调试模式下指令不往前走
        if (rom_addr==CODE_NUM) begin
            rom_addr=32'b0;
        end
    end
    else rom_addr=rom_addr;
end

//RF
wire RegWrite;
assign RegWrite=sw_i[3];
wire [4:0]rs1,rs2,rd;
assign rd=sw_i[11:8];
//reg [31:0]WD;
//wire [31:0]RD1,RD2;
//always@(*)begin
//WD<=U_alu.C;
//end
//实例化RF模块
RF U_RF(.clk(Clk_CPU),.rst(rstn),.RFWr(RegWrite),.sw_i(sw_i),.A1(rs1),.A2(rs2),.A3(rd),.WD(sw_i[7:4]),.RD1(RD1),.RD2(RD2));
//循环显示RF
 reg [5:0]reg_addr;
 always@(posedge Clk_CPU)begin
 if(!rstn||reg_addr>=32)begin reg_data=32'hffffffff;reg_addr=0; end
 else reg_data=U_RF.rf[reg_addr];reg_addr=reg_addr+1'b1;
 end
endmodule
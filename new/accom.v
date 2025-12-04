`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 10:49:23
// Design Name: 
// Module Name: accom
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


module sccomp(input clk,input rstn,input[15:0]sw_i,output[7:0]disp_an_o,output[7:0]disp_seg_o
    );
    reg[31:0]clkdiv;
    wire Clk_CPU;
    always@(posedge clk or negedge rstn)
    begin
    if(!rstn)clkdiv<=0;
    else clkdiv<=clkdiv+1'b1;
    end
    assign Clk_CPU=(sw_i[15])?clkdiv[27]:clkdiv[25];//慢速时钟和快速时钟
    reg[63:0]display_data;
    reg[5:0]led_data_addr;
    reg[63:0]led_disp_data;
    parameter LED_DATA_NUM=15;
    reg [63:0]LED_DATA[14:0];//二维数组,可以想象成有19行，然后每行有64位
    initial begin
    LED_DATA[0] = 64'hFFFFFFFEFEFEFEFE;
    LED_DATA[1] = 64'hFFFEFEFEFEFEFFFF;
    LED_DATA[2] = 64'hDEFEFEFEFFFFFFFF;
    LED_DATA[3] = 64'hCEFEFEFFFFFFFFFF;
    LED_DATA[4] = 64'hC2FFFFFFFFFFFFFF;
    LED_DATA[5] = 64'h81FEFFFFFFFFFFFF;
    LED_DATA[6] = 64'hF1FCFFFFFFFFFFFF;
    LED_DATA[7] = 64'hFDF8F7FFFFFFFFFF;
    LED_DATA[8] = 64'hFFF8F3FFFFFFFFFF;
    LED_DATA[9] = 64'hFFFBF1FEFFFFFFFF;
    LED_DATA[10] = 64'hFFFFF9F8FFFFFFFF;
    LED_DATA[11] = 64'hFFFFFDF8F7FFFFFF;
    LED_DATA[12] = 64'hFFFFFFF9F1FFFFFF;
    LED_DATA[13] = 64'hFFFFFFFFF1FCFFFF;
    LED_DATA[14] = 64'hFFFFFFFFF9F8FFFF;
    end
    //产生led_data
    always@(posedge Clk_CPU or negedge rstn)begin
    if(!rstn)begin led_data_addr=6'b0;led_disp_data=64'b1;end
    else if(sw_i[0]==1'b1)begin
    if(led_data_addr==LED_DATA_NUM)begin led_data_addr=6'b0;led_disp_data=64'b1;end//到达最后
    led_disp_data=LED_DATA[led_data_addr];
    led_data_addr=led_data_addr+1'b1;end
    else led_data_addr=led_data_addr;
    end   
    wire[31:0]instr;
    reg[31:0]reg_data;
    reg[31:0]alu_disp_data;
    reg[31:0]dmem_data;
always@(sw_i)begin
if(sw_i[0]==0)begin
case(sw_i[14:11])//选择显示什么内容
4'b1000:display_data=instr;//ROM
4'b0100:display_data=reg_data;//RF
4'b0010:display_data=alu_disp_data;
4'b0001:display_data=dmem_data;
default:display_data=32'h00000000;
endcase end
else begin display_data=led_disp_data;end
end

//循环显示ROM
reg [5:0]addr;
 always@(posedge Clk_CPU or negedge rstn)begin
 if(!rstn||addr>=12)addr<=0;
 else addr=addr+6'b000001;
 end
 wire [5:0]rom_addr;
 assign rom_addr=addr;
 
 //循环显示RF
 reg [5:0]reg_addr;
 always@(posedge Clk_CPU)begin
 if(!rstn||reg_addr>=6'b001000)begin reg_data=32'hffffffff;reg_addr=0; end
 else reg_data=U_RF.rf[reg_addr];reg_addr=reg_addr+1'b1;
 end
 
 //循环显示ALU
 reg [2:0]alu_addr;
 always@(posedge Clk_CPU)begin
 alu_addr=alu_addr+1'b1;
 case(alu_addr)
 3'b001:alu_disp_data=U_alu.A;
 3'b010:alu_disp_data=U_alu.B;
 3'b011:alu_disp_data=U_alu.C;
 3'b100:alu_disp_data=U_alu.Zero;
 default:alu_disp_data=32'hffffffff;
 endcase
 end
 
 //循环显示DM
wire MemWrite;//写信号，sw_i[2]
assign MemWrite=sw_i[2];
wire [8:0]dm_addr;
assign dm_addr=sw_i[10:8];
wire [31:0]dm_din;
assign dm_din={{29{sw_i[7]}},sw_i[7:5]};
wire [1:0]DMType;
assign DMType=sw_i[4:3];
wire[31:0]dm_out;
reg [8:0]dmem_addr;
parameter DM_DATA_NUM=16;
 always@(posedge Clk_CPU)
 begin
 if(sw_i[11]==1'b1)begin
 dmem_addr=dmem_addr+1'b1;
 dmem_data=U_DM.dmem[dmem_addr][7:0];
 if(dmem_addr==DM_DATA_NUM)begin
 dmem_addr=6'd0;dmem_data=32'hffffffff;end
 end
 end

dist_mem_gen_0 U_IM(.a(rom_addr),.spo(instr));
seg7x16 u_seg7x16(.clk(clk),
      .rstn(rstn),
      .disp_mode(sw_i[0]),
      .i_data(display_data),
      .o_seg(disp_seg_o),
      .o_sel(disp_an_o)                              
);

//RF
wire RegWrite;
assign RegWrite=sw_i[2];//上一个实验写使能信号是sw_i[3]
wire [4:0]rs1,rs2,rd;
assign rs1=sw_i[10:8];//缩短为3位
assign rs2=sw_i[7:5];
assign rd=sw_i[10:8];
reg [31:0]WD;
wire [31:0]RD1,RD2;
always@(*)begin
WD<=U_alu.C;
end
//实例化RF模块
RF U_RF(.clk(Clk_CPU),.rst(rstn),.RFWr(RegWrite),.sw_i(sw_i),.A1(rs1),.A2(rs2),.A3(rd),.WD(WD),.RD1(RD1),.RD2(RD2));

//ALU
wire [31:0]A,B;
assign A=RD1;
assign B=RD2;
wire [4:0]ALUOp;
assign ALUOp={3'b000,sw_i[4:3]};
//实例化ALU模块
ALU U_alu(.A(A),.B(B),.ALUOp(ALUOp),.C(aluout),.Zero(Zero));

//实例化DM

DM U_DM(.clk(Clk_CPU),.DMWr(MemWrite),.addr(dm_addr[8:0]),.din(dm_din),.DMType(DMType[1:0]),.dout(dm_out));
endmodule
`timescale 1ns / 1ps

module UART_RAM_TFT(
    Clk,
    Reset_n,
    uart_rx,
    VGA_RGB,//TFT数据输出
    VGA_HS, //TFT行同步信号
    VGA_VS, //TFT场同步信号
    VGA_BLK,        //VGA 场消隐信号
    VGA_CLK,
    TFT_BL  //背光
);


    input Clk;
    input Reset_n;
    input uart_rx;
    output [15:0]VGA_RGB;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLK;     //VGA 场消隐信号
    output VGA_CLK; 
    output TFT_BL;

    wire [7:0]rx_data;
    wire rx_done;
    
    wire ram_wren;
    wire [15:0]ram_wraddr;
    wire [15:0]ram_wrdata;
    reg [15:0]ram_rdaddr;
    wire Clk_TFT;
    wire [15:0]ram_rddata;
    
    assign VGA_CLK = Clk_TFT;
    assign TFT_BL = 1;
    
    MMCM MMCM(
        .clk_out1(Clk_TFT),
        .clk_in1(Clk)
    );
    
    uart_byte_rx uart_byte_rx(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .Baud_Set(4),
        .uart_rx(uart_rx),
        .Data(rx_data),
        .Rx_Done(rx_done)  
    ); 
    
    img_rx_wr img_rx_wr(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .ram_wren(ram_wren),
        .ram_wraddr(ram_wraddr),
        .ram_wrdata(ram_wrdata)
    );
    
    RAM RAM (
      .clka(Clk),    // input wire clka
      .ena(1),      // input wire ena
      .wea(ram_wren),      // input wire [0 : 0] wea
      .addra(ram_wraddr),  // input wire [15 : 0] addra
      .dina(ram_wrdata),    // input wire [15 : 0] dina
      .clkb(Clk_TFT),    // input wire clkb
      .enb(1),      // input wire enb
      .addrb(ram_rdaddr),  // input wire [15 : 0] addrb
      .doutb(ram_rddata)  // output wire [15 : 0] doutb
    );

    wire Data_Req;
    wire [11:0]hcount,vcount;
    
    wire [15:0]disp_data;
    VGA_CTRL VGA_CTRL(
        .Clk(Clk_TFT),    //系统输入时钟33MHZ
        .Reset_n(Reset_n),
        .Data(disp_data),    //待显示数据
		.Data_Req(Data_Req),
        .hcount(hcount),        //VGA行扫描计数器
        .vcount(vcount),        //VGA场扫描计数器
        .VGA_RGB(VGA_RGB),  //VGA数据输出
        .VGA_HS(VGA_HS),        //VGA行同步信号
        .VGA_VS(VGA_VS),        //VGA场同步信号
        .VGA_BLK(VGA_BLK)      //VGA 场消隐信号
    );
    
    //RAM中存储的图像是256*256的像素矩阵
    always@(posedge Clk_TFT or negedge Reset_n)
    if(!Reset_n)
        ram_rdaddr <= 0;
    else if(ram_data_en)
        ram_rdaddr <= ram_rdaddr + 1'd1;
    
    wire ram_data_en;
    
    assign ram_data_en = Data_Req && (hcount < 255) && (vcount <= 255);
    assign disp_data = ram_data_en? ram_rddata:0;
    
endmodule

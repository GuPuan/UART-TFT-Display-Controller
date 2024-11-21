module img_rx_wr(
    Clk,
    Reset_n,
    rx_data,
    rx_done,
    ram_wren,
    ram_wraddr,
    ram_wrdata
);
    input Clk;
    input Reset_n;
    input [7:0]rx_data;
    input rx_done;
    output reg ram_wren;
    output reg[15:0]ram_wraddr;
    output [15:0]ram_wrdata;
    
    reg [15:0]rx_data_tmp;
    
    reg [16:0]data_cnt; //统计串口接收的数据个数计数器
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) 
        data_cnt <= 0;
    else if(rx_done)
        data_cnt <= data_cnt + 1'd1;
 
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) 
        rx_data_tmp <= 0;
    else if(rx_done)
        rx_data_tmp <= {rx_data_tmp[7:0], rx_data};
        
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) 
        ram_wren <= 0;
    else if(rx_done && data_cnt[0])
        ram_wren <= 1'd1;
    else
        ram_wren <= 0;
        
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n) 
        ram_wraddr <= 0;
    else if(rx_done && data_cnt[0]) 
        ram_wraddr <= data_cnt[16:1];  //data_cnt/2
        
    assign ram_wrdata = rx_data_tmp;
    
endmodule

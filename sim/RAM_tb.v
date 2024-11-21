`timescale 1ns / 1ps

module RAM_tb();
    
    reg clka;
    reg ena;
    reg wea;
    reg [15:0]addra;
    reg [15:0]dina;
    reg clkb;
    reg enb;
    reg [15:0]addrb;
    wire [15:0]doutb;

    RAM RAM (
      .clka(clka),    // input wire clka
      .ena(ena),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [15 : 0] addra
      .dina(dina),    // input wire [15 : 0] dina
      .clkb(clkb),    // input wire clkb
      .enb(enb),      // input wire enb
      .addrb(addrb),  // input wire [15 : 0] addrb
      .doutb(doutb)  // output wire [15 : 0] doutb
    );

    //先写满RAM  再读出来
    
    initial clka = 1;
    always #10 clka = ~clka;
    
    initial clkb = 1;
    always #15 clkb = ~clkb;
    
    initial begin
        ena = 0;
        wea = 0;
        addra = 0;
        addrb = 0;  
        dina = 0;    
        enb = 0;
        #201;
        repeat(65536)begin
            ena = 1;
            wea = 1;
            #20;
            dina = dina + 1;
            addra = addra + 1;
        end
        ena = 0;
        wea = 0;
        #20000;
        addrb = 65535;
        #300;
        repeat(65536)begin
            enb = 1;
            #30;
            addrb = addrb - 1;
        end
        #2000;
        $stop;       
    end
    

endmodule

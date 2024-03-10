`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Deepak Sharda
// 
// Create Date: 27.02.2024 20:31:46
// Design Name: 
// Module Name: baud_rate_gen
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

/* non blocking assignment are not giving correct value */ 
module baud_rate #( 
    parameter SYSTEM_CLK = 100000000, // clock for the fpga or design
    parameter BAUD_RATE  = 9600, // deseired baud rate for communication 
    parameter OVERSAMPLE_RATE = 8  // oversampling scemhme 
) (input logic clk , // system clock input  should be wire in case of verilog 
   input logic reset, // active high reset asserted on 1
   output logic rx_clk, // reciver clock 1/over_sample times the tx_clk should be reg
   output logic tx_clk // trasmitter clock  // reg
);
    localparam  rx_baud_ticker = (SYSTEM_CLK/(BAUD_RATE*OVERSAMPLE_RATE));  // oversamppling clock 
    localparam  tx_baud_ticker = (SYSTEM_CLK/(BAUD_RATE));            
    localparam  rx_baud_counter_width = $clog2(rx_baud_ticker); // counter width 
    localparam  tx_baud_conuter_width = $clog2(tx_baud_ticker);

    logic [rx_baud_counter_width-1:0] rx_baud_counter = 0;
    logic [tx_baud_conuter_width-1:0] tx_baud_counter =0;
   // initial begin 
    //   rx_clk=0;
      //  tx_clk=0;
     //   end
   always @ (posedge clk ) begin
       if (reset) begin
         rx_baud_counter =0;
         rx_clk =0;
        end
       else begin
            if (rx_baud_counter == rx_baud_ticker) begin
                rx_baud_counter =0;
                rx_clk = 1'b1;
            end
            else 
            rx_clk =1'b0;
            rx_baud_counter = rx_baud_counter+1;
        end
      end 

    always @ (posedge clk ) begin
        if (reset) begin
         tx_baud_counter =0;
         tx_clk =0;
        end
       else begin
            if (tx_baud_counter == tx_baud_ticker) begin
                tx_baud_counter =0;
                tx_clk = 1'b1;
            end
            else 
            tx_clk = 1'b0;
            tx_baud_counter = tx_baud_counter+1;
        end
   end
endmodule 

  /*always @ (posedge clk ) begin
       if (reset) begin
       rx_clk <=0;
         rx_baud_counter <=0;
         
         //rx_clk =0;
        end
       else begin
            if (rx_baud_counter == rx_baud_ticker) begin
                
                rx_clk <= 1'b1;
                rx_baud_counter <=0;
                
            end
            else 
            rx_clk <=1'b0;
            rx_baud_counter <= rx_baud_counter+1;
        end
      end 

    always @ (posedge clk ) begin
        if (reset) begin
         tx_clk <=0;
         tx_baud_counter <=0;
        // tx_clk =0;
        end
       else begin
            if (tx_baud_counter == tx_baud_ticker) begin
                tx_clk <= 1'b1;
                tx_baud_counter <=0;
                
            end
            else 
            tx_clk <= 1'b0;
            tx_baud_counter <= tx_baud_counter+1;
        end
   end
endmodule */




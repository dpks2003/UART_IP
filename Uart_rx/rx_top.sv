`timescale 1ns / 1ps
////////////////////d//////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 21:14:56
// Design Name: 
// Module Name: rx_top
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


module rx_top #( parameter PARITY_MODE = 00 , // parameter to chosse ending bit 
                  parameter STOP_MODE = 0,    // parameter to choose stoop bitss 
    parameter OVERSAMPLE_RATE = 08 ,
    parameter SYSTEM_CLK = 10000000, // clock for the fpga or design
    parameter BAUD_RATE  = 9600,  // deseired baud rate for communication 
    parameter FLOPS = 2
    ) 

    (input logic rx_i_data , // serial input data it should come from the syncronizer

    input logic clk ,
   // input logic rx_clk, wiill use tis a internal signal 
    input logic reset,


    output logic [7:0] rx_o_data ,// parallel data out 
    output logic       rx_o_parity_error ,
    output logic       rx_data_valid ,
    output logic       rx_o_error
    
    );

     // internal signal declaration 

     logic rx_clk ; // rx baud ratre clock at the oversampling speed 
     logic tx_clk;
     logic o_rx_synced; 
// instatntinng the sun module 

    rx_logic #(PARITY_MODE,  // parameter to chosse ending bit 
               STOP_MODE ,    // parameter to choose stoop bitss 
              OVERSAMPLE_RATE 
    )  rx_FSM (
            o_rx_synced , // serial input data it should come from the syncronizer

            clk ,
            rx_clk,
            reset,


            rx_o_data ,// parallel data out 
            rx_o_parity_error ,
            rx_data_valid ,
            rx_o_error
    );

// instantianion of baud rate clock 
    
    baud_rate #( 
                SYSTEM_CLK ,// clock for the fpga or design
                 BAUD_RATE , // deseired baud rate for communication 
                 OVERSAMPLE_RATE // oversampling scemhme 
    ) rx_baudCLOCK(clk , // system clock input  should be wire in case of verilog 
                reset, // active high reset asserted on 1
                rx_clk, // reciver clock 1/over_sample times the tx_clk should be reg
                tx_clk // trasmitter clock  // reg
    );

// 

  rx_sync # (FLOPS)  // no of flip flop or no of synchronizatio states 
  flopp  ( clk , 
          reset ,  // remove this in case of FPGA 
           rx_i_data, // rx data from the external transmitter unsynchronixed 
           o_rx_synced // syncronized output to be transmitted to the rx_logic
);
    
endmodule
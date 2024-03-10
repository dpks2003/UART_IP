`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 20:49:41
// Design Name: 
// Module Name: tx_top
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


// topp module for UART transmisiion 

/* instantiation of tx_logic.sv ,, baud_rate.sh */ 

//------------------------------------------------------------------------------------------------------------------------------------------
module tx_top #(parameter PARITY_MODE = 00 , // parameter to chosse ending bit 
    parameter STOP_MODE = 01 ,    // parameter to choose stoop bitss 
    parameter SYSTEM_CLK = 125000000, // clock for the fpga or design
    parameter BAUD_RATE  = 9600,  // deseired baud rate for communication 
    parameter OVERSAMPLE_RATE = 8
    ) ( 
        input logic clk ,
      
     
        input logic reset, // reset the sytem when high 

      //  input logic [7:0] tx_i_data, // input paralle data converts input paralla data to send it serially 

        input logic       tx_i_start, // signal to start the transmsision 

        output logic tx_o_ready, // output ready to say the system i sready to transmit 

        output logic tx_o_data // sending data over teh UART  
        );


    // internal signals 

    logic tx_clk; // tx_baudclock from baud rate  grnrator 
    logic rx_clk;
// Instantiation of baud rate genrator 

    baud_rate #( 
    SYSTEM_CLK, // clock for the fpga or design
    BAUD_RATE  ,// deseired baud rate for communication 
    OVERSAMPLE_RATE // oversampling scemhme 
    )  clock_genrator
    ( clk , // system clock input  should be wire in case of verilog 
        reset, // active high reset asserted on 1
        rx_clk, // reciver clock 1/over_sample times the tx_clk should be reg
        tx_clk // trasmitter clock  // reg
    ); 

// INstantiation of transmittior 
    tx_logic #(
        PARITY_MODE , // parameter to chosse ending bit 
        STOP_MODE      // parameter to choose stoop bitss 
    )  
    transmitter 
        (   clk ,
         tx_clk, // tx_baudclock from baud rate  grnrator  
     
        reset, // reset the sytem when high 

        8'h4a , // input paralle data converts input paralla data to send it serially 

        tx_i_start, // signal to start the transmsision 

        tx_o_ready, // output ready to say the system i sready to transmit 
        
        tx_o_data // sending data over teh UART  
        );
    
    
endmodule
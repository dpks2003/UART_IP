`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 22:26:47
// Design Name: 
// Module Name: in_cdc
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



module rx_sync # ( parameter FLOPS = 2)  // no of flip flop or no of synchronizatio states 
( input logic clk , 
  input logic reset ,  // remove this in case of FPGA 
  input logic rx_i_data, // rx data from the external transmitter unsynchronixed 
  output logic o_rx_synced // syncronized output to be transmitted to the rx_logic
);
 
logic [FLOPS-1:0] flop_stage;

// logic for syncronization 

always @ (posedge clk) begin
    
    if(reset) 
    begin
        flop_stage =0;
    end

    else begin
        flop_stage <= { flop_stage [FLOPS-2:0],rx_i_data};
    end
end

// asinig the synchronized data 
assign o_rx_synced = flop_stage [FLOPS-1];

endmodule

// end/// 

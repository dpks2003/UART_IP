`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 20:22:32
// Design Name: 
// Module Name: rx_logic
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 17:17:07
// Design Name: 
// Module Name: rx_logic
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


/* RX logic for getting the data 
 written by - Deepak Sharda 
 Date - 1-march-2024 

*/ 

module rx_logic #(parameter PARITY_MODE = 00 , // parameter to chosse ending bit 
                  parameter STOP_MODE = 0,    // parameter to choose stoop bitss 
                  parameter OVERSAMPLE_RATE =08 
)   (
    input logic rx_i_data , // serial input data it should come from the syncronizer

    input logic clk ,
    input logic rx_clk,
    input logic reset,


    output logic [7:0] rx_o_data ,// parallel data out 
    output logic       rx_o_parity_error ,
    output logic       rx_data_valid ,
    output logic       rx_o_error
);
    //  internal sigansl 
    logic [2:0] databit_count;
    logic [7:0] rx_data_buffer;  // buffer holds the rx data parallelly 
//logic []
    logic [2:0] state_reg;
    logic frame_sync ;
    logic [2:0] start_sample_count;
    logic [2:0] data_sample_count;
    logic [2:0] parity_sample_count;
    logic [2:0] stop_sample_count;
    logic       start_bit_reg;
    logic       parity_bit_reg;
  //  logic [2:0] databit_count;
    logic       frame_error;
    logic       parity_error;      
    logic       stop_flag;

// Local Parameter for FSM STATES
//------------------------------------------------------------------------------------------------
    localparam IDLE       = 3'b000,
            //  START_BIT  = 3'b001,
              DATA_BIT    = 3'b010,
              PARITY_BIT  = 3'b011,
              STOP_BIT_I  = 3'b100,
              STOP_BIT_F  = 3'b101,
              BUFF_STAGE  = 3'b110;

// local parameter for the multple oversampling 

   localparam LAST_SAMPLE= OVERSAMPLE_RATE-1;
   localparam MID_SAMPLE = OVERSAMPLE_RATE/2 ;

/* -----------------------------------------------------------------------------
     Suncronized logic for RX FSM 
--------------------------------------------------------------------------------*/

    always @(posedge clk) begin

        if (reset) begin

            rx_o_data            <=8'b0;
            rx_data_valid        <= 0;
            rx_o_parity_error    <=0;
        // intternal 

            state_reg <= IDLE ;

            frame_sync <= 0;
            start_bit_reg <= 1;
            parity_bit_reg <= 0;
            rx_data_buffer <=0;
            databit_count <= 0;
            
            start_sample_count <= 0;
            data_sample_count <= 0;
            parity_sample_count <=0;
            stop_sample_count <= 0;
            
            
            parity_bit_reg <= 0;
            start_bit_reg <=0;
            parity_error <=0; 
            frame_error <=0;
            stop_flag <=0;
            
        end


        else begin


            case (state_reg)

                // STATE IDLE 
                IDLE : begin
                    if (rx_clk) begin
                        if (rx_i_data == 1'b0) begin
                            start_sample_count <= start_sample_count +1;
                            frame_sync <=1;
                        end
                        if (frame_sync) begin
                            start_sample_count <= start_sample_count +1;
                        end

                        if (start_sample_count == MID_SAMPLE) begin
                            start_bit_reg <= rx_i_data ;
                        end

                        if (start_sample_count == LAST_SAMPLE) begin
                            
                            if (start_bit_reg == 1'b0) begin
                                state_reg <= DATA_BIT ;
                            end
                            else begin
                                frame_sync <= 1'b0;
                            end

                        
                        end
                    end


                end

                // Receive DATA state -- DATA_BIT 

                DATA_BIT : begin
                    
                    if (rx_clk) begin
                        data_sample_count <= data_sample_count+1;

                        // sampling in middle 
                        if(data_sample_count == MID_SAMPLE) begin
                            rx_data_buffer[databit_count] <= rx_i_data ;

                        end

                        if (data_sample_count == LAST_SAMPLE) begin
                            
                            databit_count <= databit_count +1;
                            //last bit 
                            if (databit_count == 7) begin    
                                
                                 if (PARITY_MODE [0]) begin
                                    state_reg <= PARITY_BIT;
                                end

                                 else if (STOP_MODE == 1) begin // no parity two estop bit 
                                    state_reg <= STOP_BIT_I;

                                end
                                 else begin 
                                     state_reg <= STOP_BIT_F; // no parity one stop bit 
                                  end 

                                if (STOP_MODE == 0)
                                 begin
                                   stop_flag <=1'b0;
                                  
                                    end
                            end
                             
                        end
                    
                    end
                end
/* recive parity bit ------------------------------------------------------------------*********************/ 

                PARITY_BIT : begin
                    if (rx_clk) begin
                        // increment sample counter 

                        parity_sample_count = parity_sample_count +1;

                        // sampling at middle 

                        if (parity_sample_count == MID_SAMPLE) begin
                            
                            parity_bit_reg <= rx_i_data;
                        end
                        // last sample \
                        if(parity_sample_count == LAST_SAMPLE) begin
                            
                            if (STOP_MODE == 0) begin
                                
                                state_reg <= STOP_BIT_F;
                            end

                            if (STOP_MODE == 1) begin
                                
                                state_reg<= STOP_BIT_I; // two stop bit 
                            end
                        end
                        
                    end
                end                

// Intial stop bit only applicable for two stop bit modeee 


                STOP_BIT_I : begin
                    if(rx_clk) begin
                        // increamnet sample count 

                        stop_sample_count <= stop_sample_count +1;

                        // sampling at midd

                        if (stop_sample_count == MID_SAMPLE) begin
                            stop_flag <= ~ rx_i_data ;  // /*** check this out 
                        end

                        if (stop_sample_count == LAST_SAMPLE) begin
                            
                            state_reg <= STOP_BIT_F ;
                        end
                    end
                end

                // FINAL dtop bit 

                STOP_BIT_F : begin
                    if(rx_clk) begin
                        
                        // incrementing the sample counter 

                        stop_sample_count <= stop_sample_count +1;

                        if (stop_sample_count == MID_SAMPLE) begin
                            stop_sample_count <= 0 ;

                            if(rx_i_data == 1'b0) begin
                                frame_error <= 1'b1;
                                // stop bit not sampled sampling error 
                            end

                            else begin
                                frame_error <= 1'b0 | stop_flag; // inital and final stop bit anaysis 
                            end

                            frame_sync <= 1'b0;
                            state_reg <= BUFF_STAGE ;
                        end

                    end
                end
            
                /* Buffer STAGe for data */ 

                BUFF_STAGE : begin
                    // buffer parity error flag 

                    rx_o_parity_error <= parity_error;

                    // buffer the data to output reg only if no error
                    if(!frame_error)begin
                        rx_o_data <= rx_data_buffer;

                        rx_data_valid <= 1'b1;

                    end

                    state_reg <= IDLE ; 

                end

                default:  state_reg <= IDLE ;
            endcase

// Parity Claculation 

        if(PARITY_MODE[0]) begin
            parity_error <= PARITY_MODE[1] ? ((~ (^rx_data_buffer)) == parity_bit_reg ) : 
                                             (( ^rx_data_buffer) == parity_bit_reg ) ; 

        end

        else begin 
          parity_error <=1'b0;   
        end
        end

    end
    // continuous  assignment 

    assign rx_o_error = frame_error ;

endmodule


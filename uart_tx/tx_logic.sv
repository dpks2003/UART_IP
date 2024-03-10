`timescale 1ns / 1ps
// this module contains the logic for the state machine of uart tranmisssioon 
// takes data in paralled and send out in serioes 

// works on the tx_clk from from the baud_rate mosule 
// written by deepak Sharda 

// Date - 29 FEB 2024 - 17:20 


/*  Parity mode ---
  this module has parity bit enabled you can either choose between 

                 parity Mode      Bit

                 NO_Parity         00
                 ODD_Parity        01
                 EVEN_parity       11

  this module gives you feature of sending either one or two stop bits 

               no of Stop bits   Bit 
                    1             0
                    2             1

    */ 

module tx_logic #(
    parameter PARITY_MODE = 00, // parameter to chosse ending bit 
    parameter STOP_MODE = 1     // parameter to choose stoop bitss 
      ) 
   ( input logic clk ,
     input logic tx_clk, // tx_baudclock from baud rate  grnrator  
     
     input logic reset, // reset the sytem when high 

     input logic [7:0] tx_i_data, // input paralle data converts input paralla data to send it serially 

     input logic       tx_i_start, // signal to start the transmsision 

     output logic tx_o_ready, // output ready to say the system i sready to transmit 

     output logic tx_o_data // sending data over teh UART  
   );

   // ---- STATE DErfinations 

   localparam IDLE       = 3'b000,
              START_BIT  = 3'b001,
              DATA_BIT   = 3'b010,
              PARITY_BIT = 3'b011,
              STOP_BIT   = 3'b100;
    

    // Internal signal or register 

    logic [2:0] state_reg = 000; // holds teh state data 
    logic [7:0] data_buffer ;    // buffer for tx input data 
    logic       ready_reg;
    logic [2:0] databit_count;  // no of data bit send only for the dat anot sratr or stop its a reg
    logic       stop_count ; 
    logic       parity_reg ;
// -- logic 

always @(posedge clk) begin
    
    if (reset) begin

        tx_o_data <= 1'b1; // put the line to ideal 

        data_buffer <= 8'b00000000;
        state_reg   <= IDLE ;
        ready_reg   <= 1'b0;
        databit_count <=1'b0;
        stop_count    <=1'b0;
        parity_reg    <=1'b0;
    end

    /// if not reset then FSM module for the transmisiion of bits 

    else begin
        
        case(state_reg)

        // IDEL STATE 

        IDLE : begin

            ready_reg <= 1'b1; // ready to accecpt data /// removed this 

            if (tx_i_start & ready_reg)begin  // changing this
                data_buffer <= tx_i_data;
                ready_reg <= 1'b0;
                state_reg <= START_BIT;
            end
        end

        // send start bit state 

        START_BIT : begin
            
            if (tx_clk) begin
                
                tx_o_data <= 1'b0;
                state_reg <= DATA_BIT ;
            end
        end

        // SEND DATA STATE 

        DATA_BIT  : begin
            
            if(tx_clk) begin
            
                tx_o_data <= data_buffer[databit_count];
                databit_count <= databit_count + 1;      
                
                 // Incremenbt the data bit 
                // assigning the oputput data 
                 // dynamically alocating 

                if (&databit_count) begin
                    databit_count <= 1'b0;

                    if(PARITY_MODE[0])begin
                        
                        state_reg = PARITY_BIT;
                    end

                    else begin
                        state_reg = STOP_BIT; 
                     
                    end
                end 

                
            end

        end

        // PARITY BIT STATE 

        PARITY_BIT : begin
            
            if (tx_clk)

            tx_o_data <= parity_reg;
            state_reg<= STOP_BIT; 
            // will be written afterrr i write teh partiyt genration logic 

        end

        // STOP BIT state 

        STOP_BIT : begin
            
            if (tx_clk)begin
                
                tx_o_data <= 1'b1;

                stop_count <= stop_count +1;

                if (stop_count == STOP_MODE)begin
                    stop_count <= 1'b0;

                    state_reg <= IDLE;
                end
            end
        end

        default : state_reg <= IDLE;


        endcase
        // parity genrator uses conditon operator to genrate either even or odd parity 

        parity_reg <= PARITY_MODE[1] ? (^data_buffer): (~ (^data_buffer)) ;
    end
end
       // assigning output to tx output reg

       assign tx_o_ready = ready_reg;

endmodule
`include "UartStates.v"

module Transmitter (clk, empty, fromBuffer, reset, tx, txDone);
    input  wire clk, empty, reset;    // baud rate
    input  wire [7:0] fromBuffer;           // data to transmit
    output reg  tx, txDone;          // tx

    reg [2:0] state  = `IDLE;
    reg [7:0] data   = 8'b0; // to store a copy of input data
    reg [2:0] bitIdx = 3'b0; // for 8-bit data

    parameter MAX_RATE_TX = `CLOCK_RATE / `BAUD_RATE;
    parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX);
    reg [TX_CNT_WIDTH - 1:0] txCounter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
            data <= 8'b0;
            bitIdx <= 3'b0;
            tx <= 1'b1;
            txDone <= 1'b0;
            txCounter <= 0;
        end 
        else begin
            case (state)
                default: begin
                    state <= `IDLE;
                end
                `IDLE: begin
                    bitIdx <= 3'b0;
                    tx <= 1'b1; // drive line high for idle
                    txCounter <= 0;
                    if (~empty) begin
                        data <= fromBuffer; // save a copy of input data
                        txDone <= 1'b1;
                        state <= `START_BIT;
                    end else begin
                        data <= 8'b0;
                        txDone <= 1'b0;
                        state <= `IDLE;                    
                    end 
                end

                `START_BIT: begin
                    txDone <= 1'b0; 
                    if (txCounter >= MAX_RATE_TX) begin
                        txCounter <= 0;
                        tx <= 1'b0; // send start bit (low)
                        state <= `DATA_BITS;
                    end else txCounter <= txCounter + 1'b1;
                end

                `DATA_BITS: begin // Wait 8 clock cycles for data bits to be sent
                    if (txCounter >= MAX_RATE_TX) begin
                        txCounter <= 0;
                        tx <= data[bitIdx];
                        if (&bitIdx) begin
                            bitIdx <= 3'b0;
                            state <= `STOP_BIT;
                        end else begin
                            bitIdx <= bitIdx + 1'b1;
                        end
                    end else txCounter <= txCounter + 1'b1;
                end

                `STOP_BIT: begin // Send out Stop bit (high)
                    if (txCounter >= MAX_RATE_TX) begin
                        txCounter <= 0;
                        data <= 8'b0;
                        state <= `IDLE;
                        tx <= 1'b1;
                    end else txCounter <= txCounter + 1'b1;
                end
            endcase
        end
    end
endmodule
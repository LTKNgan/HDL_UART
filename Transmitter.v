`include "UartStates.v"

module Transmitter (baudClk, in, en, fromMem, reset, tx, txDone);
    input  wire baudClk, in, en, reset;    // baud rate
    input  wire [7:0] fromMem;           // data to transmit
    output reg  tx, txDone;          // tx

    reg [2:0] state  = `IDLE;
    reg [7:0] data   = 8'b0; // to store a copy of input data
    reg [2:0] bitIdx = 3'b0; // for 8-bit data

    always @(posedge baudClk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
            data <= 8'b0;
            bitIdx <= 3'b0;
            tx <= 1'b1;
            txDone <= 1'b0;
        end 
        else begin
            case (state)
                default: begin
                    state <= `IDLE;
                end
                `IDLE: begin
                    bitIdx <= 3'b0;
                    tx <= 1'b1; // drive line high for idle
                    if (~en && in) begin
                        data <= fromMem; // save a copy of input data
                        txDone <= 1'b1;
                        state <= `START_BIT;
                    end else begin
                        data <= 8'b0;
                        txDone <= 1'b0;
                        state <= `IDLE;                    
                    end
                    
                end
                `START_BIT: begin
                    tx <= 1'b0; // send start bit (low)
                    txDone <= 1'b0;
                    state <= `DATA_BITS;
                end
                `DATA_BITS: begin // Wait 8 clock cycles for data bits to be sent
                    tx <= data[bitIdx];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= `STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 1'b1;
                    end
                end
                `STOP_BIT: begin // Send out Stop bit (high)
                    data <= 8'b0;
                    state <= `IDLE;
                    tx <= 1'b1;
                end
            endcase
        end
    end
endmodule
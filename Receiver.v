`include "UartStates.v"

module Receiver (baudClk, rx, reset, toMem, rxDone);
    input  wire baudClk, rx, reset;    // baud rate
    output reg  [7:0] toMem;          // received data
    output reg rxDone;                // end on transaction

    reg [1:0] state = `IDLE;
    reg [2:0] bitIdx = 3'b0;        // for 8-bit data
    reg [1:0] inputSw = 2'b0;       // shift reg for input signal state
    reg [3:0] clockCount = 4'b0;    // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0;  // temporary storage for input data

    always @(posedge baudClk or posedge reset) begin
        if (reset) begin
            state <= `IDLE;
            bitIdx <= 3'b0;
            clockCount <= 4'b0;
            receivedData <= 8'b0;
            toMem <= 8'b0;
            rxDone <= 1'b0;
        end
        else begin
            inputSw = { inputSw[0], rx };   // shift bit
            case (state)
                default: begin
                    state <= `IDLE;
                end
                `IDLE: begin
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    toMem <= 8'b0;
                    rxDone <= 1'b0;
                    if (~rx) state <= `START_BIT;
                end
                // Wait 8 full cycles to receive serial data
                `START_BIT: begin
                    if (&clockCount[2:0]) begin
                        state <= `DATA_BITS;
                        clockCount <= 0;
                    end
                    else clockCount <= clockCount + 4'b1;
                end
    
                `DATA_BITS: begin
                    if (&clockCount) begin // save one bit of received data
                        clockCount <= 4'b0;
                        receivedData[bitIdx] <= inputSw[0]; // little edian
                        if (&bitIdx) begin
                            bitIdx <= 3'b0;
                            state <= `STOP_BIT;
                        end else begin
                            bitIdx <= bitIdx + 3'b1;
                        end
                    end else begin
                        clockCount <= clockCount + 4'b1;
                end
            end
    
                `STOP_BIT: begin
                    rxDone <= 1'b1;
                    toMem <= receivedData;
                    if (&clockCount || (clockCount >= 4'h8 && !(|inputSw))) begin      // receive stop bit
                        state <= `IDLE;
                        clockCount <= 4'b0;
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end
            endcase
        end
    end
endmodule

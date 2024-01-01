`include "UartStates.v"

module BaudRateGenerator  (clk, reset, rxClk, txClk);
    input wire clk, reset;     // board clock and reset
    output reg rxClk;           // baud rate for rx
    output reg txClk;           // baud rate for tx

parameter MAX_RATE_RX = `CLOCK_RATE / (2 * `BAUD_RATE * 16); // 16x oversampling
parameter MAX_RATE_TX = `CLOCK_RATE / (2 * `BAUD_RATE);
parameter RX_CNT_WIDTH = $clog2(MAX_RATE_RX);
parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX);

reg [RX_CNT_WIDTH - 1:0] rxCounter;
reg [TX_CNT_WIDTH - 1:0] txCounter;


always @(posedge clk or posedge reset) begin
    if (reset) begin
        rxClk <= 0;
        txClk <= 0;
        rxCounter <= 0;
        txCounter <= 0;
    end   
    else begin
        // rx clock
        if (rxCounter >= MAX_RATE_RX) begin
            rxCounter <= 0;
            rxClk <= ~rxClk;
        end 
        else begin
            rxCounter <= rxCounter + 1'b1;
        end
        // tx clock
        if (txCounter >= MAX_RATE_TX) begin
            txCounter <= 0;
            txClk <= ~txClk;
        end 
        else begin
            txCounter <= txCounter + 1'b1;
        end
    end
end

endmodule
module Uart  (clk, reset, rx, tx);
    input wire clk, reset;

    // rx interface
    input wire rx;
    
    // tx interface
    output wire tx;

    //tx buffer to tx
    output wire full, empty;
    wire [7:0] fromBuffer;
    wire txDone;
    

    //wire to test
    wire [7:0] toBuffer;
    wire rxDone;
    
    Receiver Rx (
        .clk(clk), 
        .rx(rx), 
        .reset(reset), 
        .toBuffer(toBuffer),    // to test
        .rxDone(rxDone)
    );
    Transmitter Tx (
        .clk(clk), 
        .empty(empty), 
        .fromBuffer(fromBuffer), 
        .reset(reset), 
        .tx(tx), 
        .txDone(txDone)
    );
    fifo_mem txBuffer (
        .clk(clk),
        .reset(reset), 
        .wr(rxDone),             // to test
        .rd(txDone), 
        .data_in(toBuffer),     // to test
        .data_out(fromBuffer), 
        .empty(empty),
        .full(full)
    );

endmodule
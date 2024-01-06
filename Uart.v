module Uart  (clk, reset, rx, txEn, tx, full, empty);
    input wire clk, reset;

    // rx interface
    input wire rx;
    
    // tx interface
    output wire tx;
    input wire txEn;

    output wire full, empty;

    wire rxClk;
    wire txClk;
    wire rxDone, txDone;
    
    wire [7:0] toMem;   // from rx
    wire [7:0] fromMem;   // to tx
    
    BaudRateGenerator generatorInst (.clk(clk), .reset(reset), .rxClk(rxClk), .txClk(txClk));
    Receiver Rx (.baudClk(rxClk), .rx(rx), .reset(reset), .toMem(toMem), .rxDone(rxDone));
    Transmitter Tx (.baudClk(txClk), .in(txEn), .en(empty), .fromMem(fromMem), .reset(reset), .tx(tx), .txDone(txDone));
    fifo_mem fifo (.clk(clk), .reset(reset), .wr(rxDone), .rd(txDone), .data_in(toMem), .data_out(fromMem), .full(full), .empty(empty));

endmodule
# DESCRIPTION

1. This is a simple model designed for UART communication protocol and tested on Arty-z7 FPGA development board. Its flow is PC -> receiver -> buffer -> transmitter -> PC.
2. In `UartStates.v`, baud rate `BAUD_RATE` can be configured. `CLOCK_RATE` is the internal clock of the FPGA board.
3. Buffer operates on a first-in, first-out (FIFO) basis. A read pointer and a write pointer are used to read and write data on buffer.
4. Transmitter is designed to send any data written in buffer. User can configure to use a button to enable the transmitter.

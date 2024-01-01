module fifo_mem(baudClk, reset, wr, rd, data_in, data_out, full, empty);  // reset from button
   input wr, rd, baudClk, reset;  // signal from controller
   input[7:0] data_in; 
   output[7:0] data_out;  
   output full, empty;        // use for enable read and write 
   wire[4:0] wptr,rptr;       // read, write pointer  of memory
   wire enWrite, enRead;  

   status_signal  status(.wptr(wptr), .rptr(rptr), .full(full), .empty(empty)); 
   write_pointer  writePtr(.wr(wr), .full(full), .baudClk(baudClk), .reset(reset), .wptr(wptr), .enWrite(enWrite));  
   read_pointer   readPtr(.rd(rd), .empty(empty), .baudClk(baudClk), .reset(reset), .rptr(rptr), .enRead(enRead));  
   memory_array   mem(.data_in(data_in), .baudClk(baudClk), .enWrite(enWrite), .wptr(wptr), .rptr(rptr), .data_out(data_out));    

endmodule  

module status_signal(wptr, rptr, full, empty);  
   input[4:0] wptr, rptr;  
   output full, empty;  

    wire pointer_equal, fbit_comp;  
    
    assign fbit_comp = wptr[4] ^ rptr[4]; 
    assign pointer_equal = (wptr[3:0] - rptr[3:0]) ? 0:1; 
     
    assign full = fbit_comp & pointer_equal;
    assign empty = (~fbit_comp) & pointer_equal;
endmodule


module write_pointer(wr, full, baudClk, reset, wptr, enWrite);  
input wr, full, baudClk, reset;  
output reg[4:0] wptr;  
output enWrite;  

assign enWrite = (~full)&wr;

always @(posedge baudClk)  begin 
    if(reset)
      wptr <= 5'b00000;  
    else if(enWrite)
      wptr <= wptr + 5'b00001;
    else  
      wptr <= wptr;  
end

endmodule  


module read_pointer(rd, empty, baudClk, reset, rptr, enRead);  
input rd, empty,baudClk, reset;  
output reg[4:0] rptr;  
output enRead;

assign enRead = (~empty)&rd;  

always @(posedge baudClk) begin  
    if(reset)
      rptr <= 5'b00000;
    else if(enRead)
      rptr <= rptr + 5'b00001;  
    else
      rptr <= rptr;
end  

endmodule  


module memory_array(data_in, baudClk, enWrite, wptr, rptr, data_out);  
input[7:0] data_in;  
input baudClk, enWrite;  
input[4:0] wptr, rptr;  
output wire[7:0] data_out;

reg[7:0] mem[15:0];  

always @(posedge baudClk)  
begin  
   if(enWrite) mem[wptr[3:0]] <= data_in;
end  

assign data_out = mem[rptr[3:0]];    

endmodule  
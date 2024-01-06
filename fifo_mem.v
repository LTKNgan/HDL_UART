module fifo_mem(clk, reset, wr, rd, data_in, data_out, full, empty);  // reset from button
  input clk, reset, wr, rd;  // signal from controller
  input[7:0] data_in; 
  output[7:0] data_out;  
  output full, empty;        // use for enable read and write 
  wire[4:0] wptr,rptr;       // read, write pointer  of memory
  wire enWrite, enRead;  

  status_signal  status(
    .wptr(wptr), 
    .rptr(rptr), 
    .full(full), 
    .empty(empty)
  ); 

  write_pointer  writePtr(
    .wr(wr), 
    .full(full), 
    .clk(clk), 
    .reset(reset), 
    .wptr(wptr), 
    .enWrite(enWrite)
  );  

  read_pointer   readPtr(
    .rd(rd), 
    .empty(empty), 
    .clk(clk), 
    .reset(reset), 
    .rptr(rptr), 
    .enRead(enRead)
  );  

  memory_array   mem(
    .data_in(data_in), 
    .clk(clk), 
    .enWrite(enWrite), 
    .wptr(wptr), 
    .rptr(rptr), 
    .data_out(data_out)
  );    

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

module write_pointer(wr, full, clk, reset, wptr, enWrite);  
input wr, full, clk, reset;  
output reg[4:0] wptr;  
output enWrite; 

reg preEnWrite;

assign enWrite = (~full)&wr;

always @(posedge clk or posedge reset)  begin 
    if(reset) begin
      wptr <= 5'b00000;  
      preEnWrite <= 0;
    end else begin
        if(enWrite & ~preEnWrite)
          wptr <= wptr + 5'b00001;
        else  
          wptr <= wptr; 
        preEnWrite <= enWrite; 
    end
end

endmodule  


module read_pointer(rd, empty, clk, reset, rptr, enRead);  
input rd, empty,clk, reset;  
output reg[4:0] rptr;  
output enRead;

reg preEnRead;

assign enRead = (~empty)&rd;  

always @(posedge clk or posedge reset) begin  
    if(reset) begin
      rptr <= 5'b00000;
      preEnRead <= 0;
    end else begin
        if(enRead & ~preEnRead)
          rptr <= rptr + 5'b00001;  
        else
          rptr <= rptr;
        preEnRead <= enRead;
    end      
end  

endmodule  


module memory_array(data_in, clk, enWrite, wptr, rptr, data_out);  
input[7:0] data_in;  
input clk, enWrite;  
input[4:0] wptr, rptr;  
output wire[7:0] data_out;

reg[7:0] mem[15:0];  

always @(posedge clk)  
begin  
    if(enWrite) mem[wptr[3:0]] <= data_in;
end  

assign data_out = mem[rptr[3:0]];    

endmodule  
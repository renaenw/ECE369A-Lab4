module ClkDiv(Clk, Rst, ClkOut);
   input Clk, Rst;
   output reg ClkOut;
  // Lab 7: ~5 kHz clock from the 100 MHz board clock (period = 2*(DivVal+1)*10 ns)
  parameter DivVal = 10000;
   reg [25:0] DivCnt;
   reg ClkInt;
	
   always @(posedge Clk) begin
      if( Rst == 1 )begin
         DivCnt <= 0;
         ClkOut <= 0;
         ClkInt <= 0;
      end
      else begin
         if( DivCnt == DivVal ) begin
            	ClkOut <= ~ClkInt;
            	ClkInt <= ~ClkInt;
            	DivCnt <= 0;
         end
         else begin
            	ClkOut <= ClkInt;
            	ClkInt <= ClkInt;
            	DivCnt <= DivCnt + 1;
         end
      end
   end
endmodule

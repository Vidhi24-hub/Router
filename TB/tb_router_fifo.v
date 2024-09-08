// test bench code for FIFO used in 1X3 router

module tb_router_fifo();

	// data type declaration
	
	reg clock,resetn,soft_reset,we,re,lfd_state;
	reg [8:0]data_in;
	wire full,empty;
	wire [8:0]data_out;

	integer k;
	
	// Instantiate
	
	router_fifo DUT(data_in,clock,resetn,soft_reset,we,re,lfd_state,data_out,full,empty);

	// Generating the clock
	
	initial
		begin
			clock = 1'b0;
			forever #5 clock = ~clock;
		end

	//Initializing the inputs 
	
	initial
		begin
			{data_in,clock,resetn,soft_reset,we,re,lfd_state}=0;
		end
	
	// task for synchronous active low RESET
	
	task rst_dut();
		begin
			@(negedge clock)
			resetn = 1'b0;
			@(negedge clock)
			resetn = 1'b1;
		end
	endtask
	
	// Task for writing operation
	
	task write;
		reg [7:0]payload_data,parity,header;
		reg [5:0]payload_length;
		reg [1:0]addr;

		begin
			@(negedge clock)
			lfd_state = 1'b1;
			@(negedge clock)
			payload_length = 6'd14;
			addr = 2'b01;
			header = {payload_length,addr};
			data_in = header;
			lfd_state = 1'b0;
			we = 1;
          
			for(k=0;k<payload_length;k=k+1)
			begin
				@(negedge clock)
				payload_data = {$random}%256;
				data_in = payload_data;
			end
          
			@(negedge clock)
			parity = {$random}%256;
			data_in = parity;
		end
	endtask
	
	task read;
		begin
		    re=1;
			we=0;
		end
	endtask

	initial
		begin
		   rst_dut;
		   #10;
		   write;
		   #10;
		   read;
		   #200 $finish;
	    end

endmodule




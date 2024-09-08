module tb_router_reg();

	reg [7:0]data_in; 
	reg clock,resetn,packet_valid,fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
	wire err, parity_done, low_packet_valid;
	wire [7:0]data_out;

	integer i;
	
	router_reg DUT(data_in,clock,resetn,packet_valid,fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg,err, parity_done, low_packet_valid,data_out);
						
	initial
		begin
			clock = 1'b0;
			forever #5 clock = ~clock;
		end
	
	initial
		begin
			{data_in,clock,resetn,packet_valid,fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg}=0;
		end
		
	task rst_dut();
		begin
			@(negedge clock)
			resetn = 1'b0;
			@(negedge clock)
			resetn = 1'b1;
		end
   endtask
		
	task packet1();
		reg [7:0]header,payload_data,parity;
		reg [5:0]payloadlen;
		begin
			@(negedge clock)
			payloadlen = 8;
			parity = 0;
			detect_add = 1'b1;
			packet_valid = 1'b1;
			header = {payloadlen,2'b10};
			data_in = header;
			parity = parity ^ data_in;
			@(negedge clock)
			detect_add = 1'b0;
			lfd_state = 1'b1;
			for(i=0;i<payloadlen;i=i+1)
				begin
					@(negedge clock)
					lfd_state = 0;
					ld_state = 1;
					payload_data = {$random}%256;
					data_in = payload_data;
					parity = parity ^ data_in;
				end
			@(negedge clock)
			packet_valid = 0;
			data_in = parity;
			@(negedge clock)
			ld_state = 0;
		end
	endtask
	
	task packet2();
		reg [7:0] header,payload_data, parity;
		reg [5:0]payloadlen;	
		begin
			@(negedge clock)
			payloadlen = 8;
			parity = 0;
			detect_add = 1'b1;
			packet_valid = 1'b1;
			header = {payloadlen,2'b10};
			data_in = header;
			parity = parity ^ data_in;
			@(negedge clock)
			detect_add = 1'b0;
			lfd_state = 1'b1;
			for(i=0;i<payloadlen;i=i+1)
				begin
					@(negedge clock)
					lfd_state = 0;
					ld_state = 1;
					payload_data = {$random}%256;
					data_in = payload_data;
					parity = parity ^ data_in;
				end
			@(negedge clock)
			packet_valid = 0;
			data_in = !parity;
			@(negedge clock)
			ld_state = 0;
		end
	endtask
	
	initial
		begin
			rst_dut;
			fifo_full = 1'b0;
			laf_state = 1'b0;
			full_state = 1'b0;
			#20;
			packet1();
			#100;
			packet2();
			$finish;
		end
			
endmodule


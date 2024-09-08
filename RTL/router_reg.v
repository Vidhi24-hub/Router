// ---------- Router Register -------------

module router_reg(input [7:0]data_in, input clock,resetn,packet_valid,fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg,
						output reg err, parity_done, low_packet_valid,
						output reg [7:0]data_out);
						
	reg [7:0] hold_header_byte, fifo_full_state_byte, internal_parity,packet_parity_byte;
	
  
	// PARITY DONE logic
	always@(posedge clock)
	begin
		if(!resetn)
			parity_done <= 1'b0;
		else
			begin
				if(ld_state && !fifo_full && !packet_valid)
					parity_done <= 1'b1;
				else if(laf_state && low_packet_valid && !parity_done)
					parity_done <= 1'b1;
				else
					begin
						if(detect_add)
							parity_done <= 1'b0;
					end
			end
	end
		
  
	// LOW_PACKET_VALID logic	
	always@(posedge clock)
	begin
		if(!resetn)
			low_packet_valid <= 1'b0;
		else
			begin
				if(rst_int_reg)
					low_packet_valid <= 1'b0;
				else if(ld_state==1'b1 && packet_valid == 1'b0)
					low_packet_valid <= 1'b1;
			end
	end
	
  
	//DATA OUT logic
	always@(posedge clock)
	begin
		if(!resetn)
			data_out <= 8'b0;
		else
			begin
				if(detect_add && packet_valid)
					hold_header_byte <= data_in;
				else if(lfd_state)
					data_out <= hold_header_byte;
				else if(ld_state && !fifo_full)
					data_out <= data_in;
				else if(ld_state && fifo_full)
					fifo_full_state_byte <= data_in;
			   else if(laf_state)
					data_out <= fifo_full_state_byte;
			end
	end
	
  
	// INTERNAL PARITY logic
	always@(posedge clock)
	begin
		if(!resetn)
			internal_parity <= 8'b0;
		else if(lfd_state)
			internal_parity <= internal_parity ^ hold_header_byte;
		else if(ld_state && packet_valid && !full_state)
			internal_parity <= internal_parity ^ data_in;
		else if(detect_add)
			internal_parity <= 8'b0;
	end
	
	
	//error and packet
	always@(posedge clock)
		begin
			if(!resetn)
				packet_parity_byte <= 8'b0;
			else
				begin
					if(ld_state && !packet_valid)
						packet_parity_byte <= data_in;
				end
		end
		
		
	// error 
	always@(posedge clock)
	begin
		if(!resetn)
			err <= 1'b0;
		else
			begin
				if(parity_done)
					begin
						if(internal_parity != packet_parity_byte)
							err <= 1'b1;
						else
							err <= 1'b0;
					end
			end
	end
	
endmodule


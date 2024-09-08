
// --------- FSM/Controller ---------
module router_fsm(
	input clk,rst,pkt_valid,parity_done,soft_rst_0,soft_rst_1,soft_rst_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
	input [1:0] data_in,
	output busy,detect_add,lfd_state,ld_state,full_state,laf_state,write_enb_reg,rst_int_reg
	);
	
	parameter    decode_addr = 3'b000,
				 load_first_data = 3'b001,
				 load_data = 3'b010,
				 load_parity = 3'b011,
				 fifo_full_state = 3'b100,
				 load_after_full = 3'b101,
				 wait_till_empty = 3'b110,
				 check_parity_error = 3'b111;
	
	reg [1:0] addr;
	reg [2:0] present_state, next_state;
	
	//address logic
	always@(posedge clk)
		begin
			if(!rst)
				addr <= 2'b00;
			else
				addr <= data_in;
		end
	
	//reset logic for state
	always@(posedge clk)
		begin
			if(!rst)
				present_state <= decode_addr;
			else if(soft_rst_0 && (data_in == 2'b00) ||  soft_rst_1 && (data_in == 2'b01) 
					  || soft_rst_2 && (data_in == 2'b10)) 
				present_state <= decode_addr;
			else 
				present_state <= next_state;
		end
	
	//next state	
	always@(*)
		begin
		
			next_state = decode_addr;
			
			case(present_state)
			
			decode_addr : begin 
									if((pkt_valid && (data_in == 2'b00) && fifo_empty_0) ||
										(pkt_valid && (data_in == 2'b01) && fifo_empty_1) ||
										(pkt_valid && (data_in == 2'b10) && fifo_empty_2))
										
										next_state = load_first_data;
										
									else if((pkt_valid && (data_in == 2'b00) && !fifo_empty_0) ||
											  (pkt_valid && (data_in == 2'b01) && !fifo_empty_1) ||
											  (pkt_valid && (data_in == 2'b10) && !fifo_empty_2))
											  
											  next_state = wait_till_empty;
									else
											  next_state = decode_addr;
								end
			
			load_first_data : next_state = load_data;
			
			load_data : begin
								if(fifo_full)	
									next_state = fifo_full_state;
								else if(!fifo_full && !pkt_valid)
									next_state = load_parity;
								else
									next_state = load_data;
						end
			
			load_parity : next_state = check_parity_error;
			
			fifo_full_state : begin
										if(!fifo_full)
											next_state = load_after_full;
										else
											next_state = fifo_full_state;
							  end
			
			load_after_full : begin
										if(!parity_done && !low_pkt_valid)
											next_state = load_data;
										else if(!parity_done && low_pkt_valid)
											next_state = load_parity;
										else
											begin
												if(parity_done)
													next_state = decode_addr;
												else
													next_state = load_after_full;
											end
							  end
									
			wait_till_empty : begin
										if(((fifo_empty_0) && (addr == 2'b00)) ||
											((fifo_empty_1) && (addr == 2'b01)) ||
											((fifo_empty_2) && (addr == 2'b10)))
											next_state = load_first_data;
										else 
											next_state = wait_till_empty;
							  end
              
			check_parity_error : begin
											if(fifo_full)
												next_state = fifo_full_state;
											else
												next_state = decode_addr;
								 end
		endcase
	end
	
	//busy - lfd, fifo full, laf, load parity, wait till empty, check parity error	
	assign busy = (present_state == load_first_data || present_state == load_parity   
						|| present_state == fifo_full_state || present_state == load_after_full 
						|| present_state == wait_till_empty || present_state == check_parity_error) 
						? 1'b1 : 1'b0; 
	
	assign detect_add = present_state == decode_addr ? 1'b1 : 1'b0;
	
	assign ld_state = present_state == load_data ? 1'b1 : 1'b0 ;
	
	assign laf_state = present_state == load_after_full ? 1'b1 : 1'b0;
	
	assign full_state = present_state == fifo_full_state ? 1'b1 : 1'b0;
	
	assign write_enb_reg = (present_state == load_data || present_state == load_parity
									|| present_state == load_after_full) ? 1'b1 : 1'b0;
	
	assign rst_int_reg = present_state == check_parity_error ? 1'b1 : 1'b0;
	
	assign lfd_state = (present_state == load_first_data) ? 1'b1 : 1'b0;
	
endmodule
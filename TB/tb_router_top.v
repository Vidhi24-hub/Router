
// test bench for top module of router

module tb_router_top();

	reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
	reg [7:0]datain;
	wire [7:0]data_out_0, data_out_1, data_out_2;
	wire vld_out_0, vld_out_1, vld_out_2, err, busy;
	integer i;

	router_top DUT(.clk(clk),
			   .resetn(resetn),
			   .read_enb_0(read_enb_0),
			   .read_enb_1(read_enb_1),
			   .read_enb_2(read_enb_2),
			   .packet_valid(packet_valid),
			   .datain(datain),
			   .data_out_0(data_out_0),
			   .data_out_1(data_out_1),
			   .data_out_2(data_out_2),
			   .vldout_0(vld_out_0),
			   .vldout_1(vld_out_1),
			   .vldout_2(vld_out_2),
			   .err(err),
			   .busy(busy) );			   
			   
	//clock generation

	initial 
		begin
		clk = 1;
		forever 
		#2 clk=~clk;
		end
	
	
	task reset;
		begin
			resetn=1'b1;
			@(negedge clk) resetn=1'b0;
			@(negedge clk) resetn=1'b1;
			{read_enb_0, read_enb_1, read_enb_2, packet_valid,datain}=0;
			
		end
	endtask
//	
	task pktm_gen_8;	// packet generation payload 8 | FIFO 1
			reg [7:0]header, payload_data, parity;
			reg [8:0]payloadlen;
			begin
				parity=0;
				wait(!busy)
				begin
				@(negedge clk);
				payloadlen=9'd8;
				packet_valid=1'b1;
				header={payloadlen,2'b01};
				//read_enb_2 = 1'b1;
				datain=header;
				parity=parity^datain;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
					begin
					wait(!busy)				
					@(negedge clk);
					payload_data={$random}%256;
					datain=payload_data;
					parity=parity^datain;				
					end					
								
				wait(!busy)				
					@(negedge clk);
					packet_valid=0;				
					datain=parity;
					repeat(30) @(negedge clk) read_enb_1=1'b1;
					read_enb_1=1'b0;
			
			end
	endtask
	
	task pktm_gen_8_sft_rst;	// packet generation payload 8 for soft reset  | FIFO 1
			reg [7:0]header, payload_data, parity;
			reg [8:0]payloadlen;
			begin
				parity=0;
				wait(!busy)
				begin
				@(negedge clk);
				payloadlen=9'd8;
				packet_valid=1'b1;
				header={payloadlen,2'b01};
				//read_enb_2 = 1'b1;
				datain=header;
				parity=parity^datain;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
					begin
					wait(!busy)				
					@(negedge clk);
					payload_data={$random}%256;
					datain=payload_data;
					parity=parity^datain;				
					end					
								
				wait(!busy)				
					@(negedge clk);
					packet_valid=0;				
					datain=parity;
					repeat(5) @(negedge clk) read_enb_1=1'b1;
					repeat(30) @(negedge clk) read_enb_1=1'b0;
					
			
			end
	endtask
	
	
	task pktm_gen_5;	// packet generation payload 5 | FIFO 2
			reg [7:0]header, payload_data, parity;
			reg [4:0]payloadlen;
			
			begin
				parity=0;
				wait(!busy)
				begin
				@(negedge clk);
				payloadlen=5'd5;
				packet_valid=1'b1;
				header={payloadlen,2'b10};
				datain=header;
				parity=parity^datain;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
					begin
					wait(!busy)				
					@(negedge clk);
					payload_data={$random}%256;
					datain=payload_data;
					parity=parity^datain;				
					end					
								
				wait(!busy)				
					@(negedge clk);
					packet_valid=0;				
					datain=parity;
					repeat(30)
			@(negedge clk) read_enb_2=1'b1;
			read_enb_2=1'b0;
			end
	endtask
	
	initial
		begin
			reset;
			pktm_gen_8;
			pktm_gen_8_sft_rst;
			pktm_gen_5;
			#10000; 
			$finish;
		end
		
		
endmodule

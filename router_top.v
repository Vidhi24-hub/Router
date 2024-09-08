// RTL code for the top module of router

module router_top (input clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2,
		  input [7:0]datain, 
		  output vldout_0, vldout_1, vldout_2, err, busy,
		  output [7:0]data_out_0, data_out_1, data_out_2);

	wire [2:0]w_enb;
	wire [2:0]soft_reset;
	wire [2:0]read_enb; 
	wire [2:0]empty;
	wire [2:0]full;
	wire lfd_state_w;
	wire [7:0]data_out_temp [2:0] ;
	wire [7:0]dout;

	genvar a;

	generate 
		for(a=0;a<3;a=a+1)

		begin:fifo
          fifo_router f0(.clk(clk), .rst(resetn), .soft_rst(soft_reset[a]),
                         .lfd_state(lfd_state_w), .we(w_enb[a]), .din(dout), .re(read_enb[a]), 
                         .full(full[a]), .empty(empty[a]), .dout(data_out_temp[a])); 
		end
	endgenerate			  
						
	router_reg r1(.clock(clk), .resetn(resetn), .packet_valid(packet_valid), .data_in(datain), 
			  .data_out(dout), .fifo_full(fifo_full), .detect_add(detect_add), 
			  .ld_state(ld_state),  .laf_state(laf_state), .full_state(full_state), 
			  .lfd_state(lfd_state_w), .rst_int_reg(rst_int_reg),  .err(err), .parity_done(parity_done), .low_packet_valid(low_packet_valid));


	router_fsm fsm(.clk(clk), .rst(resetn), .pkt_valid(packet_valid), 
			   .data_in(datain[1:0]), .soft_rst_0(soft_reset[0]), .soft_rst_1(soft_reset[1]), .soft_rst_2(soft_reset[2]), 
			   .fifo_full(fifo_full), .fifo_empty_0(empty[0]), .fifo_empty_1(empty[1]), .fifo_empty_2(empty[2]),
			   .parity_done(parity_done), .low_pkt_valid(low_packet_valid), .busy(busy), .rst_int_reg(rst_int_reg), 
			   .full_state(full_state), .lfd_state(lfd_state_w), .laf_state(laf_state), .ld_state(ld_state), 
			   .detect_add(detect_add), .write_enb_reg(write_enb_reg));


	fifo_sync s(.clk(clk), .rst(resetn), .data_in(datain[1:0]), .detect_add(detect_add), 
             	   	  .full_0(full[0]), .full_1(full[1]), .full_2(full[2]), .re_0(read_enb[0]), 
			  .re_1(read_enb[1]), .re_2(read_enb[2]), .write_en_reg(write_enb_reg), 
			  .empty_0(empty[0]), .empty_1(empty[1]), .empty_2(empty[2]), .valid_0(vldout_0), .valid_1(vldout_1), .valid_2(vldout_2), 
			  .sft_rst_0(soft_reset[0]), .sft_rst_1(soft_reset[1]), .sft_rst_2(soft_reset[2]), .write_en(w_enb), .fifo_full(fifo_full));
			  
	assign read_enb[0] = read_enb_0;
	assign read_enb[1] = read_enb_1;
	assign read_enb[2] = read_enb_2;
	assign data_out_0=data_out_temp[0];
	assign data_out_1=data_out_temp[1];
	assign data_out_2=data_out_temp[2];

endmodule



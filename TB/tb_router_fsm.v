
module router_fsm_tb;

	// Inputs
	reg clk;
	reg rst;
	reg pkt_valid;
	reg parity_done;
	reg soft_rst_0;
	reg soft_rst_1;
	reg soft_rst_2;
	reg fifo_full;
	reg low_pkt_valid;
	reg fifo_empty_0;
	reg fifo_empty_1;
	reg fifo_empty_2;
	reg [1:0] data_in;

	// Outputs
	wire busy;
	wire detect_add;
	wire lfd_state;
	wire ld_state;
	wire full_state;
	wire laf_state;
	wire write_enb_reg;
	wire rst_int_reg;

	// Instantiate the Unit Under Test (UUT)
	router_fsm dut (
		.clk(clk), 
		.rst(rst), 
		.pkt_valid(pkt_valid), 
		.parity_done(parity_done), 
		.soft_rst_0(soft_rst_0), 
		.soft_rst_1(soft_rst_1), 
		.soft_rst_2(soft_rst_2), 
		.fifo_full(fifo_full), 
		.low_pkt_valid(low_pkt_valid), 
		.fifo_empty_0(fifo_empty_0), 
		.fifo_empty_1(fifo_empty_1), 
		.fifo_empty_2(fifo_empty_2), 
		.data_in(data_in), 
		.busy(busy), 
		.detect_add(detect_add), 
		.lfd_state(lfd_state), 
		.ld_state(ld_state), 
		.full_state(full_state), 
		.laf_state(laf_state), 
		.write_enb_reg(write_enb_reg), 
		.rst_int_reg(rst_int_reg)
	);
	
	initial begin 
		clk=1'b0; forever #10 clk=~clk;
	end
	
	task initialize;
		begin
			// Initialize Inputs
			clk = 0;
			rst = 1;
			pkt_valid = 0;
			parity_done = 0;
			soft_rst_0 = 0;
			soft_rst_1 = 0;
			soft_rst_2 = 0;
			fifo_full = 0;
			low_pkt_valid = 0;
			fifo_empty_0 = 0;
			fifo_empty_1 = 0;
			fifo_empty_2 = 0;

		end
	endtask
    
	task reset;
		begin
			@(negedge clk) rst = 1'b0;
			@(negedge clk) rst = 1'b1;
		end
	endtask
	
	task t1;
		begin
			@(negedge clk);
			pkt_valid = 1;
			data_in = 2'b01;
			fifo_empty_1 = 1'b1;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 0;
			pkt_valid = 0;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 0;
		end
	endtask
	
	task t2;
		begin
			@(negedge clk);
			pkt_valid = 1;
			data_in = 2'b00;
			fifo_empty_0 = 1'b1;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 1;
			@(negedge clk);
			fifo_full = 1'b0;
			@(negedge clk);
			parity_done = 0;
			low_pkt_valid = 1;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 0;
		end
	endtask
	
	task t3;
		begin
			@(negedge clk);
			pkt_valid = 1;
			data_in = 2'b10;
			fifo_empty_2 = 1'b1;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 0;
			pkt_valid = 0;
			@(negedge clk);
			@(negedge clk);
			fifo_full = 1;
			@(negedge clk);
			fifo_full = 0;
			@(negedge clk);
			parity_done = 1;
		end
	endtask
	
	task t4;
		begin
			@(negedge clk);
			pkt_valid = 1;
			data_in = 2'b01;
			fifo_empty_1 = 1'b1;
			@(negedge clk);
			fifo_full = 1;
			@(negedge clk);
			fifo_full = 0;
			@(negedge clk)
			parity_done = 0;
			low_pkt_valid = 0;
			@(negedge clk);
			fifo_full = 0;
			pkt_valid =0;
			@(negedge clk);
			@(negedge clk);
			fifo_full =0;
		end
	endtask
	
	initial 
		begin
			initialize;
			reset;
			#10; t1;
			#20; t2;
			#20; t3;
			#20; t4;
			#20; $finish;
		end
endmodule



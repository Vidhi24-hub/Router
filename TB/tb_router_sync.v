                
module tb_router_sync;

	// Inputs
	reg detect_add;
	reg [1:0] data_in;
	reg write_en_reg;
	reg clk;
	reg rst;
	reg re_0;
	reg re_1;
	reg re_2;
	reg empty_0;
	reg empty_1;
	reg empty_2;
	reg full_0;
	reg full_1;
	reg full_2;

	// Outputs
	wire valid_0;
	wire valid_1;
	wire valid_2;
	wire [2:0] write_en;
	wire fifo_full;
	wire sft_rst_0;
	wire sft_rst_1;
	wire sft_rst_2;

	// Instantiate 
	router_sync dut (
		.detect_add(detect_add), 
		.data_in(data_in), 
		.write_en_reg(write_en_reg), 
		.clk(clk), 
		.rst(rst), 
		.valid_0(valid_0), 
		.valid_1(valid_1), 
		.valid_2(valid_2), 
		.re_0(re_0), 
		.re_1(re_1), 
		.re_2(re_2), 
		.write_en(write_en), 
		.fifo_full(fifo_full), 
		.empty_0(empty_0), 
		.empty_1(empty_1), 
		.empty_2(empty_2), 
		.sft_rst_0(sft_rst_0), 
		.sft_rst_1(sft_rst_1), 
		.sft_rst_2(sft_rst_2), 
		.full_0(full_0), 
		.full_1(full_1), 
		.full_2(full_2)
	);
 
	
	//clock generation
	initial 
		begin 
			clk=0;
			forever #5 clk=~clk;
		end
		
	//reset
	task reset;
		begin
			@(negedge clk) rst = 1'b0;
			@(negedge clk) rst = 1'b1;
		end
	endtask
	
	//initialize
	task initialize;
		begin
			detect_add = 0;
			data_in = 0;
			write_en_reg = 0;
			empty_0 = 0;
			empty_1 = 0;
			empty_2 = 0;
			full_0 = 0;
			full_1 = 0;
			full_2 = 0;
		end
	endtask
	
	//detect address
	task detect_addr(input n);
		begin
			detect_add = n;
		end
	endtask
	
	//data address
	task data_addr(input [1:0] p);
		begin
			data_in = p;
		end
	endtask
	
	//write_enable_reg
	task write_enable(input m);
		begin
			write_en_reg = m;
		end
	endtask
	
	//empty for fifo0
	task empty0(input l);
		begin
			empty_0 = l;
		end
	endtask
	
	//empty for fifo1
	task empty1(input l);
		begin
			empty_1 = l;
		end
	endtask
	
	//empty for fifo2
	task empty2(input l);
		begin
			empty_2 = l;
		end
	endtask
	
	//read enable for fifo0
	task read_enable_0(input t);
		begin
			re_0 = t;
		end
	endtask
	
	//read enable for fifo1
	task read_enable_1(input t);
		begin
			re_1 = t;
		end
	endtask
	
	//read enable for fifo2
	task read_enable_2(input t);
		begin
			re_2 = t;
		end
	endtask
	
	//full fifo0 
	task full_fifo_0(input i);
		begin
			full_0 = i;
		end
	endtask
	
	//full fifo1 
	task full_fifo_1(input i);
		begin
			full_1 = i;
		end
	endtask
	
	//full fifo2 
	task full_fifo_2(input i);
		begin
			full_2 = i;
		end
	endtask
	
	initial begin
		initialize;
		reset;
		detect_addr(1);
		data_addr(2'b00);
		write_enable(1);
		@(negedge clk) full_fifo_0(1);
		@(negedge clk) 
		#500; 
		@(negedge clk) empty0(0);
		#500;
		@(negedge clk) read_enable_0(0);
		#200;
		full_fifo_0(1);
		empty0(0);
		#200;
		data_addr(2'b01);
		write_enable(1);
		empty1(1);
		#200;
		full_fifo_1(1);
		empty1(0);
		#200; 
		data_addr(2'b10);
		write_enable(1);
		empty2(1);
		#200;
		full_fifo_2(1);
		empty2(0);
		#500 $finish;
	end
      
endmodule


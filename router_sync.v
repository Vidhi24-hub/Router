
//-------- Router Synchronizer --------

module router_sync(
	input detect_add,                          //detect address
	input [1:0] data_in,                       //address
	input write_en_reg,clk,rst,                //input-write enable to select to write in desired fifo
	output valid_0,valid_1,valid_2,            //valid outputs
	input re_0,re_1,re_2,                      //read eanble
	output reg [2:0] write_en,                 //write enable to write in particular fifo
	output reg fifo_full,                       //fifo full 
	input empty_0,empty_1, empty_2,            //fifo empty
	output reg sft_rst_0, sft_rst_1,sft_rst_2, //soft reset
	input full_0,full_1,full_2);               //particular fifo full

	reg [1:0] addr;                            //fifo address
	reg [4:0] fifo_0_count_sft_rst,             //count upto 30 clock cycles
				 fifo_1_count_sft_rst, 
				 fifo_2_count_sft_rst; 


	//capture address
	always@(posedge clk)
		begin
			if(!rst)
				addr <= 0;
			else if(detect_add)
				addr <= data_in;
		end


	//write enable signal for FIFO
	always@(*)
		begin
			if(write_en_reg)
				begin
					case(addr)
						2'b00   : write_en = 3'b001;
						2'b01   : write_en = 3'b010;
						2'b10   : write_en = 3'b100;
						default : write_en = 3'b000;
					endcase
				end
			else
				write_en = 3'b000;
		end
		

	//fifo full
	always@(*)
			begin
				case(addr)
					2'b00   : fifo_full = full_0;
					2'b01   : fifo_full = full_1;
					2'b10   : fifo_full = full_2;
					default : fifo_full = 0;								
				endcase
			end
	 
	 
	//valid out logic
	assign valid_0 = ~empty_0;
	assign valid_1 = ~empty_1;
	assign valid_2 = ~empty_2;


	//timeout logic for fifo_0
	//soft reset after 30 clock cycles if valid is asserted but read is deassereted
	always@(posedge clk)
		begin
			if(!rst)
            	{sft_rst_0,fifo_0_count_sft_rst} <= 0;
			else if(!valid_0)
            	{sft_rst_0,fifo_0_count_sft_rst} <= 0;
			else if(re_0)
            	{sft_rst_0,fifo_0_count_sft_rst} <= 0;			
			else if(fifo_0_count_sft_rst == 5'd29)
				begin
					sft_rst_0 <= 1;
					fifo_0_count_sft_rst <= 0;
				end
			else 
				begin
					sft_rst_0 <= 0;
					fifo_0_count_sft_rst <= fifo_0_count_sft_rst + 1'b1;
				end
		end


	//timeout logic for fifo_1
	always@(posedge clk)
		begin
			if(!rst)
            	{sft_rst_1,fifo_1_count_sft_rst} <= 0;
			else if(!valid_1)
            	{sft_rst_1,fifo_1_count_sft_rst} <= 0;
			else if(re_1)
            	{sft_rst_1,fifo_1_count_sft_rst} <= 0;
			else if(fifo_1_count_sft_rst == 5'd29)
				begin
					sft_rst_1 <= 1;
					fifo_1_count_sft_rst <= 0;
				end
			else 
				begin
					sft_rst_1 <= 0;
					fifo_1_count_sft_rst <= fifo_1_count_sft_rst + 1'b1;
				end
		end


	//timeout logic for fifo_2
	always@(posedge clk)
		begin
			if(!rst)
            	{sft_rst_2,fifo_2_count_sft_rst} <= 0;
			else if(!valid_2)
            	{sft_rst_2,fifo_2_count_sft_rst} <= 0;
			else if(re_2)
            	{sft_rst_2,fifo_2_count_sft_rst} <= 0;
			else if(fifo_2_count_sft_rst == 5'd29)
				begin
					sft_rst_2 <= 1;
					fifo_2_count_sft_rst <= 0;
				end
			else 
				begin
					sft_rst_2 <= 0;
					fifo_2_count_sft_rst = fifo_2_count_sft_rst + 1'b1;
				end
		end	
endmodule			
			

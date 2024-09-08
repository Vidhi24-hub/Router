
`timescale 1ns / 1ps
// ------- FIFO 16x9 ------
module router_fifo(clk,rst,we,re,lfd_state,din,dout,empty,full,soft_rst);
	input clk,rst,we,re,soft_rst,lfd_state;
	input [7:0] din; // 6-bit of payload and 2-bit of address of fifo
	output reg [7:0] dout;
	output full,empty;
	reg [4:0] wt_ptr, rd_ptr;  //Depth = 16
	reg [8:0] mem [0:15];      //Mem = 16x9 | Depth = 16 | Width = 9 (din + lfd_state)
	reg lfd_state_s;
	reg [6:0] fifo_count;      //fifo count of 7-bit (payload + parity)
	integer i;


	//delay by one clock cycle
	always@(posedge clk)
		begin
			if(!rst)
				lfd_state_s <= 0;
			else
				lfd_state_s <= lfd_state;
		end


	//increment
	always@(posedge clk)
		begin
			if(!rst)
				{wt_ptr,rd_ptr} <= 0;
			else if(soft_rst) 
				{wt_ptr,rd_ptr} <= 0;
			else if(we && !full)
				wt_ptr <= wt_ptr + 1'b1;
			else if(re && !empty)
				rd_ptr <= rd_ptr + 1'b1;
		end


	//fifo write
	always@(posedge clk)
		begin
			if(!rst)
				begin
					for(i=0;i<16;i=i+1)
						mem[i] <= 0;
				end
			else if(soft_rst)
				begin
					for(i=0;i<16;i=i+1)
						mem[i] <= 0;
				end
			else if(we && !full)
				mem[wt_ptr[3:0]] <= {lfd_state_s,din};
		end
	
	
	//fifo down counting
	always@(posedge clk)
		begin
			if(!rst)
				fifo_count <= 0;
			else if(soft_rst)
				fifo_count <= 0;
			else if(re && !empty)
				begin 	
					if(mem[rd_ptr[3:0]][8] == 1) 
						fifo_count <= mem[rd_ptr[3:0]][7:2] + 1'b1; 
					else if (fifo_count !== 0)
						fifo_count <= fifo_count - 1'b1;
				end
		end


	//fifo read
	always@(posedge clk)
		begin
			if(!rst)
				dout <= 8'b0;
			else if(soft_rst)
				dout <= 8'b0;
			else if(fifo_count == 0 && dout != 0)
				dout <= 8'bz;
			else if(re && !empty)
				dout <= mem[rd_ptr[3:0]][7:0];
		end


	assign full = ((wt_ptr == 5'b10000) && (rd_ptr == 5'b0)) ? 1'b1 : 1'b0 ;
	assign empty = (wt_ptr == rd_ptr) ? 1'b1 : 1'b0;

endmodule	

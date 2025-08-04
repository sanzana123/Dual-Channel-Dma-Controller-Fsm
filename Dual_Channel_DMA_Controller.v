module DMA_2ch(
    input wire clk, //Systen Clock
    input wire reset, //DMA RESET SIGNAL
    input wire start1 , start2,
    output reg done1 , done2,
    
    
    input wire [7:0] length1, length2,
    input wire [7:0] src_base1, src_base2,      // where to read from
    input wire [7:0] dst_base1, dst_base2,     // where to write to
    
    
    input wire [15:0] mem_in_data1, mem_in_data2,
    output reg [15:0] mem_out_data1, mem_out_data2, 
    output reg [7:0] src_addr1, src_addr2, 
    output reg [7:0] dst_addr1, dst_addr2,
    output reg wr_en1, wr_en2

);
    
reg [7:0] count1;   
reg [7:0] count2;


//FSM model 
reg [3:0] state1, state2;
localparam  IDLE = 4'd0,
            READ = 4'd1,
            WRITE = 4'd2,
            DONE = 4'd3;

//--------------- Channel 1 --------------//
always @(posedge clk or posedge reset) begin 
    if (reset) begin
        state1 <= IDLE;
        done1 <= 0;
        count1 <= 0;
        wr_en1 <= 0;
    end
    
    else begin 
        case(state1)
            IDLE: begin
                done1 <= 0;
                wr_en1 <= 0;
                if (start1) begin
                    count1 <= 0;
                    state1 <= READ;
                end
            end 
            
            READ: begin
                src_addr1 <= src_base1 + count1;
                state1 <= WRITE;
            
            end
            
            WRITE: begin
                dst_addr1 <= dst_base1 + count1;
                mem_out_data1 <= mem_in_data1;
                wr_en1 <= 1;
                count1 <= count1 + 1;
                
                if (count1 + 1 == length1)
                    state1 <= DONE;
                else
                    state1 <= READ;
            end
            
            DONE: begin
                wr_en1 <= 0;
                done1 <= 1;
                state1 <= IDLE;
            end
            default: state1 <= IDLE;
        endcase
    
    end
end


//--------------- Channel 2 --------------//
always @(posedge clk or posedge reset) begin 
    if (reset) begin
        state2 <= IDLE;
        done2 <= 0;
        count2 <= 0;
        wr_en2 <= 0;
    end
    
    else begin 
        case(state2)
            IDLE: begin
                done2 <= 0;
                wr_en2 <= 0;
                if (start2) begin
                    count2 <= 0;
                    state2 <= READ;
                end
            end 
            
            READ: begin
                src_addr2 <= src_base2 + count2;
                state2 <= WRITE;
            
            end
            
            WRITE: begin
                dst_addr2 <= dst_base2 + count2;
                mem_out_data2 <= mem_in_data2;
                wr_en2 <= 1;
                count2 <= count2 + 1;
                
                if (count2 + 1 == length2)
                    state2 <= DONE;
                else
                    state2 <= READ;
            end
            
            DONE: begin
                wr_en2 <= 0;
                done2 <= 1;
                state2 <= IDLE;
            end
            default: state2 <= IDLE;
        endcase
    
    end
end


endmodule 


module testbench_DMA();

	reg clk = 0;
	reg reset = 0;
	
	//Channel 1
	reg start1; 
	wire done1; 
	reg [7:0] length1, src_base1, dst_base1;
	wire [7:0] src_addr1, dst_addr1; 
	reg [15:0] mem_in_data1;
	wire [15:0] mem_out_1; 
	wire wr_en1;
	
	//Channel 2
	reg start2;
	wire done2; 
	reg [7:0] length2, src_base2, dst_base2;
	wire [7:0] src_addr2, dst_addr2; 
	reg [15:0] mem_in_data2;
	wire [15:0] mem_out_2; 
	wire wr_en2;

    //Memory Simulating
	
	reg [15:0] mem [0:255];
	
	// instantiation of DMA 2 channels
	DMA_2ch DMA(
		.clk(clk),
		.reset(reset),
		
		//For channel 1
		.start1(start1),
		.done1(done1),
		.length1(length1),
		.src_base1(src_base1),
		.dst_base1(dst_base1),
		.src_addr1(src_addr1),
		.dst_addr1(dst_addr1),
		.mem_in_data1(mem_in_data1),
		.mem_out_data1(mem_out_1),
		.wr_en1(wr_en1),
		
		//For channel 2
		.start2(start2),
		.done2(done2),
		.length2(length2),
		.src_base2(src_base2),
		.dst_base2(dst_base2),
		.src_addr2(src_addr2),
		.dst_addr2(dst_addr2),
		.mem_in_data2(mem_in_data2),
		.mem_out_data2(mem_out_2),
		.wr_en2(wr_en2)
	
	);
	
	
	
	//Making a 10 cycle clk
	always #5 clk = ~clk;
	
	//assign mem_in data (READING from the source) 
	always @(*) begin
		mem_in_data1 = mem[src_addr1];
		mem_in_data2 = mem[src_addr2];
	end
	
	//write to destination each time enable happens (WRTING to destiniation)
	always @(posedge clk) begin
        if (wr_en1)
            mem[dst_addr1] <= mem_out_1;
        if (wr_en2)
            mem[dst_addr2] <= mem_out_2;
    end
	
	//Testing phase
	integer i;
	initial begin
		$display ("Starting DMA !! ...");
		
		//initialize inputs
		reset = 1;
		start1 = 0; start2 = 0;
		length1 = 0; length2 = 0;
		
		#20 reset = 0;	//release reset after 2 cycle
		
		//init test memory data
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 0;
            if (i >= 10 && i < 18)  //hard code for rn
                mem[i] = 1000 + i;
            if (i >= 40 && i < 48)
                mem[i] = 2000 + i;
        end
		
		
		//Random addresses for no reasons why not !!! 
		src_base1 = 8'd10;
        dst_base1 = 8'd100;
        src_base2 = 8'd40;
        dst_base2 = 8'd200;
		
		length1 = 8; length2 = 8;
		
		// Start 2 channels
		start1 = 1; start2 = 1;
		#10;	// release start
		start1 = 0; start2 = 0;
		
		
		wait(done1 && done2);
		$display ("Processes Completed");
		
		
		//verify data transfer success
		$display("\n=========After Transfering =======");
		for (i = 0; i < 256; i = i + 1) begin
			$display("mem[%0d] = %0d", i, mem[i]);
		end
		
		
				
	end

endmodule

`timescale 1ns/1ns

module barrel_tb();
	reg Load, Reset, Clock;
	reg [2:0] Select;
	reg [7:0] Data_in,Expected_out;
	wire [7:0] Simulated_out;
	reg [7:0] br1_out,br1_in;
	integer errors, i, j, k;
	
	barrel #(.data_size(8)) testTestTest(Clock, Reset, Load, Select, Data_in, Simulated_out);
	
	//declare the clock
	initial begin
		Clock = 0;
		Load = 0;
		Select = 3;
		errors = 0;
		Data_in = {$random};
	  #100   if(errors != 0)	$display("Error: %d", errors);
	   	    	else		$display("Successfully tested with zero error!");
	         $finish;
	end
	
	
	always #5 Clock <= ~Clock;
	
	//set value for Select
	initial begin
	 for(k=3;k>=0;k = k -1) begin
	   # 10 Select = Select - 1;
	   if(Select == 0) begin 
	     Select = 3;
	     Load = 1;
	   end
	 end  
	end
	
	//declare the reset
	initial begin
		Reset <= 0;
		@(posedge Clock)
		@(negedge Clock) Reset <= 1;
	end
	
	
  //call verify_output task and reset the function.
	always@(posedge Clock, negedge Reset) begin
		verify_output(Simulated_out,Expected_out);
		if (Reset)
			Expected_out <= 8'd0;
		else
			Expected_out <= br1_out;
	end
	
	//call multiplexer and barrel_shifter task.
	always@(Select, Load, Data_in) begin
		multiplexer();
		barrel_shifter();
	end

	
	
	//verify the output values
	task verify_output;
		input [23:0] simulated_value;
		input [23:0] expected_value;
		begin
			if (simulated_value != expected_value)
			begin
				errors = errors + 1;
				$display("Simulated Value = %h, Expected Value = %h, errors = %d, at time = %d\n", simulated_value, expected_value,	errors, $time);
			end
		end
	endtask 
		
	//multiplexer
	task multiplexer;
		begin
			if(Load)
				br1_in = Data_in;
			else 
				br1_in = Expected_out;
		end    
	endtask
	
	//barrel_shifter
	task barrel_shifter;
		begin
			for(j=0;j<=Select;j=j+1) begin
				for(i=0;i<7;i=i+1)
					br1_out[i+1] = br1_in[i];
				br1_out[0] = br1_in[7];
			end
		end
	endtask
	
endmodule 

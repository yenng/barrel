`timescale 1ns/1ns

module barrel_tb();
	reg Load, Reset, Clock;
	reg [2:0] Select;
	reg [7:0] Data_in,Expected_out;
	wire [7:0] Simulated_out;
	wire [7:0] br1_out,br1_in;
	
	barrel #(.data_size(8)) testTestTest(Clock, Reset, Load, Select, Data_in, Simulated_out);
	
	//declare the clock
	initial begin
		Clock <= 0;
		Select <= 3;
		Data_in <= 8'd20;
	end
	
	always #5 Clock <= ~Clock;
	
	//declare the reset
	initial begin
		Reset <= 0;
		@(posedge Clock)
		@(negedge Clock) Reset <= 1;
	end
	
	

	always@(posedge Clock, negedge Reset) begin
		verify_output(Simulated_out,Expected_out);
		if (Reset)
			Expected_out <= 8'd0;
		else
			Expected_out <= br1_out;
	end
	always@(Select, Load, Data_in) begin
		multiplexer(Data_in, Expected_out, Load, br1_in);
		barrel_shifter(Select, br1_in, br1_out);
	end

	
	
	//verify the output values
	task verify_output;
		input [23:0] simulated_value;
		input [23:0] expected_value;
		integer errors = 0;
		begin
			if (simulated_value != expected_value)
			begin
				errors = errors + 1;
				$display("Simulated Value = %h, Expected Value = %h, errors = %d, at time = %d\n", simulated_value, expected_value,	errors, $time);
			end
		end
	endtask 
		
	task multiplexer;
		input [7:0] in1, in2;
		input selector;
		output reg [7:0] out;
		begin
			if(selector)
				out = in1;
			else 
				out = in2;
		end    
	endtask
	
	task barrel_shifter;
		input [2:0] sel;
		input [7:0] in;
		output reg [7:0] out;
		integer i, j;
		begin
			for(j=0;j<=sel;j=j+1) begin
				for(i=0;i<7;i=i+1)
					out[i+1] = in[i];
				out[0] = in[7];
			end
		end
	endtask
	
endmodule 

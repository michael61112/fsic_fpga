module mac 
(
	input 			axis_clk,
	input			reset,
	input			mac_EN,
	input [31:0]	A,
	input [31:0]	B,
	output [31:0]  result
);

	reg [31:0] accumulator;

	always @(posedge axis_clk) begin
		if (reset) begin
			accumulator <= 32'b0;
		end else begin
				if (mac_EN) begin
					accumulator <= accumulator + (A * B);
				end
				else begin
					accumulator <= accumulator;
				end
		end
	end

	assign result = accumulator;

endmodule

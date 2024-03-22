module axi4lite_read
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
	parameter S0 = 2'b00,
	parameter S1 = 2'b01,
	parameter S2 = 2'b10,
	parameter S3 = 2'b11
)
(
	// Global Signals 
	input   wire                     axis_clk,
	input   wire                     axis_rst_n,
	output  wire [1:0] 			 	 state_o,
	
	// Read Address Channel
	input   wire [(pADDR_WIDTH-1):0] araddr,
	output  wire                     arready,
	input   wire                     arvalid,
	
	// Read Data Channel
	output  wire                     rvalid,
	input   wire                     rready,

	// config_write Feedback
	output  wire [(pADDR_WIDTH-1):0]  config_read_address
);
	
	reg [1:0] state;
	assign state_o = state;
	
	reg arready_temp = 0;
	reg rvalid_temp = 0;
	
	reg [(pADDR_WIDTH-1):0]  config_read_address_temp;

	assign arready = (arready_temp) ? 1'b1 : 1'b0;
	assign rvalid = (rvalid_temp) ? 1'b1 : 1'b0;
	assign config_read_address = config_read_address_temp;
	
	always@(negedge axis_clk or negedge axis_rst_n) begin
		if (!axis_rst_n) begin
			state <= S0;
		end else begin
			case(state)
				S0: begin
					if (arvalid) begin
						state <= S1;
					end 
					else begin
						state <= S0;
					end
				end
				S1: begin
					if (!arvalid) begin
						state <= S2;
					end
					else begin
						state <= S1;
					end
				end
				S2: begin
					if (rready) begin
						state <= S3;
					end
					else begin
						state <= S2;
					end
				end
				S3: begin
					if (!rready) begin
						state <= S0;
					end
					else begin
						state <= S3;
					end
				end
				default: begin
					state <= S0;
				end
			endcase
		end
	end
	
	// Set output value
	always @(posedge axis_clk) begin
		case(state)
			S0: begin arready_temp <= 1'b0; rvalid_temp <= 1'b0; end
			S1: begin arready_temp <= 1'b1; rvalid_temp <= 1'b0; config_read_address_temp <= araddr; end
			S2: begin arready_temp <= 1'b0; rvalid_temp <= 1'b0; end
			S3: begin arready_temp <= 1'b0; rvalid_temp <= 1'b1; end
		endcase
	end

	always @(negedge arvalid) begin
		arready_temp <= 1'b0;
	end
	
	always @(negedge rready) begin
		rvalid_temp <= 1'b0;
	end

endmodule
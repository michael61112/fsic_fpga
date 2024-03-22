module axi4lite_write
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
	
	// Write Address Channel
	input   wire [(pADDR_WIDTH-1):0] awaddr,
	input   wire                     awvalid,
    output  wire                     awready,
	
	// Write Data Channel
	input   wire [(pDATA_WIDTH-1):0] wdata,
	input   wire                     wvalid,
    output  wire                     wready,

	// config_write Feedback
	output wire [(pADDR_WIDTH-1):0]  config_write_address,
	output wire [(pDATA_WIDTH-1):0]  config_write_data
);
	
	reg [1:0] state;
	assign state_o = state;
	
	reg awready_temp = 0;
	reg wready_temp = 0;
	reg [(pADDR_WIDTH-1):0] 		  config_write_address_temp;
	reg [(pDATA_WIDTH-1):0]			  config_write_data_temp;

	assign awready = (awready_temp) ? 1'b1 : 1'b0;
	assign wready = (wready_temp) ? 1'b1 : 1'b0;

	assign config_write_address = (awvalid & awready) ? awaddr : config_write_address;
	assign config_write_data = config_write_data_temp;

	always@(negedge axis_clk or negedge axis_rst_n) begin
		if (!axis_rst_n) begin
			state <= S0;
		end else begin
			case(state)
				S0: begin
					if (awvalid) begin
						
						state <= S1;
					end
					else begin
						state <= S0;
					end
				end
				S1: begin
					if (!awvalid) begin
						state <= S2;
					end
					else begin
						state <= S1;
					end
				end
				S2: begin
					if (wvalid) begin
						
						state <= S3;
					end
					else begin
						state <= S2;
					end
				end
				S3: begin
					if (!wvalid) begin
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
			S0: begin awready_temp <= 1'b0; wready_temp <= 1'b0; end
			S1: begin awready_temp <= 1'b1; wready_temp <= 1'b0; end
			S2: begin awready_temp <= 1'b0; wready_temp <= 1'b1; end
			S3: begin awready_temp <= 1'b0; wready_temp <= 1'b1; config_write_data_temp <= wdata; end
		endcase
	end

	always @(negedge awvalid) begin
		awready_temp <= 1'b0;
	end
	
	always @(negedge wvalid) begin
		wready_temp <= 1'b0;
	end

endmodule
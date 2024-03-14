module ap_fsm
#(  parameter pADDR_WIDTH = 12,
	parameter pDATA_WIDTH = 32,
	parameter S0 = 2'b00,
	parameter S1 = 2'b01,
	parameter S2 = 2'b10,
	parameter S3 = 2'b11
)
(
	// Global Signals 
	input   wire                     	axis_clk,
	input   wire                     	axis_rst_n,
	
	input   wire [(pADDR_WIDTH-1):0] 	config_write_address,
	input   wire [(pDATA_WIDTH-1):0] 	config_write_data,
	input   wire [9:0]					counter,
	input   wire [31:0]                 data_length,
	input   wire 						sm_tvalid,
	
	output	wire						ap_start,
	output	wire						ap_done,
	output	wire						ap_idle,
	output	wire						fir_start
);

	reg [1:0] state;
	reg ap_start_temp;
	reg ap_done_temp;
	reg ap_idle_temp;
	reg fir_start_temp;
	
	assign ap_start = ap_start_temp;
	assign ap_done = ap_done_temp;
	assign ap_idle = ap_idle_temp;
	assign fir_start = fir_start_temp;

	always@(negedge axis_clk) begin
		if (!axis_rst_n) begin
			state <= S0;
		end else begin
			case(state)
				S0: begin
					if ((config_write_address == 12'h00) && |(config_write_data & 32'b1)) begin
						state <= S1;
					end 
					else begin
						state <= S0;
					end
				end
				S1: begin
						state <= S2;
				end
				S2: begin
					if ((counter == data_length) && sm_tvalid) begin
						state <= S3;
					end
					else begin
						state <= S2;
					end
				end
				S3: begin
						state <= S3;
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
			S0: begin ap_start_temp <= 1'b0; ap_done_temp <= 1'b0; ap_idle_temp <= 1'b1; fir_start_temp <= 1'b0; end
			S1: begin ap_start_temp <= 1'b1; ap_done_temp <= 1'b0; ap_idle_temp <= 1'b0; fir_start_temp <= 1'b0; end
			S2: begin ap_start_temp <= 1'b0; ap_done_temp <= 1'b0; ap_idle_temp <= 1'b0; fir_start_temp <= 1'b1; end
			S3: begin ap_start_temp <= 1'b0; ap_done_temp <= 1'b1; ap_idle_temp <= 1'b1; fir_start_temp <= 1'b0; end
		endcase
	end

endmodule
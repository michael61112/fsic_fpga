module address_gen
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
	parameter S0 = 3'b000, // Idle
	parameter S1 = 3'b001, // TB write
	parameter S2 = 3'b010, // TB read
	parameter S3 = 3'b011, // FIR read
	parameter S4 = 3'b100, // R/W Done
	parameter S5 = 3'b101, // Send result
	parameter S6 = 3'b110  // Reset
)
(
	// Global Signals 
	input   wire                     axis_clk,
	input   wire                     axis_rst_n,
	output  wire [2:0] 			 	 state_o,
	
	// Write Address Channel
	input  wire [2:0]				 state_data_ram ,
	input  wire [2:0]				 last_state ,
	input  wire                      fir_start,
	output  wire                      sm_fready,
	input  wire                      sm_fvalid,
	
	
    output wire                     mac_reset,
	output wire 					result_ready,
	output wire 					mac_EN,
	output  wire	[3:0]				 i_o,
	
	input wire  [(pADDR_WIDTH-1):0]	 fir_start_address,
	output wire [9:0]				 counter,
	
	output wire [(pADDR_WIDTH-1):0]	 tap_addr_r,
	output wire [(pADDR_WIDTH-1):0]  fir_addr_r
);
	
	reg [2:0] state;
	reg [3:0] i;
	assign state_o = state;
	reg [9:0]				 counter_temp;
	reg mac_reset_temp;
	reg sm_fready_temp;
	reg mac_EN_temp;
	reg result_ready_temp;
	reg [(pADDR_WIDTH-1):0]		 tap_addr_r_temp;
	reg [(pADDR_WIDTH-1):0] 		 fir_addr_r_temp=32'b0;
	
	always@(negedge axis_clk) begin
		if (!axis_rst_n) begin
			state <= S6;
		end else begin
			case(state)
				S0: begin
					if (fir_start) begin
						if (last_state == S1) begin
							state <= S1;
						end
						else begin
							state <= S0;
						end
					end
					else begin
						state <= S6;
					end
				end
				S1: begin
					if (i == 4'd11) begin
						state <= S5;
					end
					else begin
						state <= S2;
					end
				end
				S2: begin
					if (sm_fvalid) begin
						state <= S3;
					end
					else begin
						state <= S2;
					end
				end
				S3: begin
					state <= S4;
				end
				S4: begin
					state <= S1;
				end
				S5: begin 
					state <= S0;
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
			S0: begin mac_reset_temp <= 1'b1; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b0;
				tap_addr_r_temp <= 12'h00; 
				fir_addr_r_temp <= fir_start_address;
				i <= 4'h0;
				end
			S1: begin mac_reset_temp <= 1'b0; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b0; end
			S2: begin mac_reset_temp <= 1'b0; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b1; mac_EN_temp <= 1'b0; end
			S3: begin mac_reset_temp <= 1'b0; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b1; end
				
			S4: begin mac_reset_temp <= 1'b0; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b0; 
						tap_addr_r_temp <= (tap_addr_r_temp < 12'h028) ? (tap_addr_r_temp + 12'h4) : 12'h0;
						fir_addr_r_temp <= (fir_addr_r_temp == 12'h000) ? 12'h028 : (fir_addr_r_temp - 12'h4);
						i <= i + 4'h1;
				end
			S5: begin mac_reset_temp <= 1'b0; result_ready_temp <= 1'b1; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b0;
						counter_temp <= counter_temp + 10'b1;
				end
			S6: begin mac_reset_temp <= 1'b1; result_ready_temp <= 1'b0; sm_fready_temp <= 1'b0; mac_EN_temp <= 1'b0;
				tap_addr_r_temp <= 12'h00;
				fir_addr_r_temp <= 12'h00;
				counter_temp <= 10'b0;
				i <= 4'h0;
				end
		endcase
	end

	assign mac_reset = mac_reset_temp;
	
	assign result_ready = result_ready_temp;
	
	assign tap_addr_r = tap_addr_r_temp;
	assign fir_addr_r = fir_addr_r_temp;
	assign i_o = i;
	assign sm_fready = sm_fready_temp;
	assign mac_EN = mac_EN_temp;
	assign counter = counter_temp;

endmodule
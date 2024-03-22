module data_ram_axi4stream
#(  parameter pADDR_WIDTH = 12,
	parameter pDATA_WIDTH = 32,
	parameter S0 = 3'b000, // Idle
	parameter S1 = 3'b001, // TB write
	parameter S2 = 3'b010, // TB read
	parameter S3 = 3'b011, // FIR read
	parameter S4 = 3'b100, // R/W Done
	parameter S5 = 3'b101  // Send result
)
(
	input 							axis_clk,
	input							axis_rst_n,
	input							ss_tvalid,
	output							ss_tready,
	input 	[(pDATA_WIDTH-1):0]		ss_tdata,
	input 							sm_tready,
	output 							sm_tvalid,
	output 	[(pDATA_WIDTH-1):0]		sm_tdata,
	input 							sm_fready,
	output 							sm_fvalid,
	output 	[(pDATA_WIDTH-1):0]		sm_fdata,
	input 	[(pADDR_WIDTH-1):0]  	tb_A,
	input 	[(pADDR_WIDTH-1):0]  	fir_A,
	output  [2:0]					state_o,

	// bram for data RAM
	output  wire [3:0]               data_WE,
	output  wire                     data_EN,
	output  wire [(pDATA_WIDTH-1):0] data_Di,
	output  wire [(pADDR_WIDTH-1):0] data_A,
	input   wire [(pDATA_WIDTH-1):0] data_Do,
	
	input 							ap_idle,
	input  							result_ready,
	input	[(pDATA_WIDTH-1):0]		result_Y
);

	reg [2:0] 					state;
	reg 						ss_tready_temp;
	reg 						sm_tvalid_temp;
	reg 						sm_fvalid_temp;
	reg [3:0] 					data_WE_temp;
	reg 						data_EN_temp;
	reg [(pADDR_WIDTH-1):0]		data_A_temp;
	reg [(pDATA_WIDTH-1):0]		data_Di_temp;
	reg [(pDATA_WIDTH-1):0]		sm_tdata_temp;
	reg [(pDATA_WIDTH-1):0]		sm_fdata_temp;

	assign ss_tready = ss_tready_temp;
	assign sm_tvalid = sm_tvalid_temp;
	assign sm_fvalid = sm_fvalid_temp;
	assign data_WE = data_WE_temp;
	assign data_EN = data_EN_temp;
	assign data_A = data_A_temp;
	assign data_Di = data_Di_temp;
	assign sm_tdata = sm_tdata_temp;
	assign sm_fdata = data_Do;
	assign state_o = state;

	always@(negedge axis_clk) begin
		if (~axis_rst_n) begin
			state <= S0;
		end else begin
			case(state)
				S0: begin
					if(result_ready && sm_tready) begin
						state <= S5;
					end
					else if(sm_fready) begin
						state <= S3;
					end
					else if (ss_tvalid) begin
						state <= S1;
					end
					//else if (sm_tready && ap_idle) begin
					// else if (sm_tready && result_ready) begin
					// 	state <= S2;
					// end
					else begin
						state <= S0;
					end
				end
				S1: begin
					if(sm_fready) begin
						state <= S3;
					end
					else if(result_ready && sm_tready) begin  //test
						state <= S5;
					end
					else begin
						state <= S0;
					end
				end
				S2: begin
					// if (sm_tready && ap_idle) begin
					// 	state <= S2;
					// end
					// else begin
					 	state <= S0;
					// end
				end
				S3: begin
					if(sm_fready) begin
						state <= S3;
					end
					else if (ss_tvalid) begin
						state <= S1;
					end
					else begin
						state <= S0;
					end
				end

				S5: begin
					// if(result_ready && sm_tready) begin
					// 	state <= S5;
					// end
					// else begin
					// 	state <= S0;
					// end
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
			S0: begin
					ss_tready_temp <= 1'b0;
					sm_tvalid_temp <= 1'b0;
					sm_fvalid_temp <= 1'b0;
					data_WE_temp <= 4'h0;
					data_EN_temp <= 1'b1;
				end
			S1: begin
					ss_tready_temp <= 1'b1;
					sm_tvalid_temp <= 1'b0;
					sm_fvalid_temp <= 1'b0;
					data_WE_temp <= 4'hf;
					data_EN_temp <= 1'b1;
					data_A_temp <= tb_A;
					data_Di_temp <= ss_tdata;
				end
			S2: begin
					ss_tready_temp <= 1'b0;
					sm_tvalid_temp <= 1'b1;
					sm_fvalid_temp <= 1'b0;
					data_WE_temp <= 4'h0; 
					data_EN_temp <= 1'b1;
					data_A_temp <= tb_A;
					sm_tdata_temp <= data_Do;
				end
			S3: begin
					ss_tready_temp <= 1'b0;
					sm_tvalid_temp <= 1'b0;
					sm_fvalid_temp <= 1'b1;
					data_WE_temp <= 4'h0;
					data_EN_temp <= 1'b1;
					data_A_temp <= fir_A;
				end
			S5: begin
					ss_tready_temp <= 1'b0;
					sm_tvalid_temp <= 1'b1;
					sm_fvalid_temp <= 1'b0;
					data_WE_temp <= 4'h0;
					data_EN_temp <= 1'b0;
					sm_tdata_temp <= result_Y;
				end
			default: begin
					ss_tready_temp <= 1'b0;
					sm_tvalid_temp <= 1'b0;
					sm_fvalid_temp <= 1'b0;
					data_WE_temp <= 4'h0;
					data_EN_temp <= 1'b1;
				end
		endcase
	end

endmodule



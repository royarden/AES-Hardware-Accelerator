module Key_Preparation(input clk, input rst_n, input start, input[1:0] AES_mode, input[3:0] key_round, input[255:0] Key_Preparation_key_in, output reg key_preparation_out_valid, output reg key_preparation_ready, output reg[127:0] Key_Preparation_key_out);

	localparam Mode_128 = 2'd1,
		   Mode_192 = 2'd2,
		   Mode_256 = 2'd3;

	localparam IDLE = 2'd0,
		   LOAD_KEY = 2'd1,
		   KEY_PREPARATION = 2'd2,
		   READY = 2'd3;

	reg[31:0] words[59:0]; // 60 words, 32 bits each word

	reg[255:0] current_key_in, next_key_in;

	reg[1:0] current_state, next_state;
	reg[1:0] current_mode, next_mode;
	reg[3:0] current_key_preparation_iteration_counter, next_key_preparation_iteration_counter;

	wire [127:0] key_expansion_128_in;
	wire [127:0] key_expansion_128_out;

	wire [191:0] key_expansion_192_in;
	wire [191:0] key_expansion_192_out;

	wire [255:0] key_expansion_256_in;
	wire [255:0] key_expansion_256_out;

	integer i;

	assign key_expansion_128_in = {
    					words[4*current_key_preparation_iteration_counter],
    					words[4*current_key_preparation_iteration_counter + 1],
    					words[4*current_key_preparation_iteration_counter + 2],
    					words[4*current_key_preparation_iteration_counter + 3]
					};

	assign key_expansion_192_in = {
   					words[6*current_key_preparation_iteration_counter],
    					words[6*current_key_preparation_iteration_counter + 1],
    					words[6*current_key_preparation_iteration_counter + 2],
    					words[6*current_key_preparation_iteration_counter + 3],
    					words[6*current_key_preparation_iteration_counter + 4],
    					words[6*current_key_preparation_iteration_counter + 5]
					};

	assign key_expansion_256_in = {
    					words[8*current_key_preparation_iteration_counter],
    					words[8*current_key_preparation_iteration_counter + 1],
    					words[8*current_key_preparation_iteration_counter + 2],
    					words[8*current_key_preparation_iteration_counter + 3],
    					words[8*current_key_preparation_iteration_counter + 4],
    					words[8*current_key_preparation_iteration_counter + 5],
    					words[8*current_key_preparation_iteration_counter + 6],
    					words[8*current_key_preparation_iteration_counter + 7]
					};

	//instantations
	Key_Expansion_128_Enc key_expansion_128 (.Key_Expansion_Enc_key_in(key_expansion_128_in),
						 .Key_Expansion_Enc_Current_round(current_key_preparation_iteration_counter),
    						 .Key_Expansion_Enc_key_out(key_expansion_128_out)
						);
	Key_Expansion_192_Enc key_expansion_192 (.Key_Expansion_Enc_key_in(key_expansion_192_in),
						 .Key_Expansion_Enc_Current_round(current_key_preparation_iteration_counter[2:0]),
    						 .Key_Expansion_Enc_key_out(key_expansion_192_out)
						);
	Key_Expansion_256_Enc key_expansion_256 (.Key_Expansion_Enc_key_in(key_expansion_256_in),
						 .Key_Expansion_Enc_Current_round(current_key_preparation_iteration_counter[2:0]),
    						 .Key_Expansion_Enc_key_out(key_expansion_256_out)
						);
	
	always @(*) begin
		// defaults assignments
		key_preparation_out_valid = 1'b0;
		key_preparation_ready = 1'b0;
		Key_Preparation_key_out = 128'd0;

		next_key_in = current_key_in;
		next_state = current_state;
		next_mode = current_mode;
		next_key_preparation_iteration_counter = current_key_preparation_iteration_counter;
		
		case(current_state)
			IDLE: begin
				if(start) begin
					next_key_in = Key_Preparation_key_in;
					next_mode = AES_mode;
					next_state = LOAD_KEY;
				end
			end

			LOAD_KEY: begin
				
				next_key_preparation_iteration_counter = 4'd0;
				next_state = KEY_PREPARATION;
			end

			KEY_PREPARATION: begin
				case(current_mode)
					Mode_128: begin
						if(current_key_preparation_iteration_counter == 4'd9)
              						next_state = READY;
            					else
                					next_key_preparation_iteration_counter = current_key_preparation_iteration_counter + 1'b1;
			 		end
					Mode_192: begin
						if(current_key_preparation_iteration_counter == 4'd7)
              						next_state = READY;
            					else
                					next_key_preparation_iteration_counter = current_key_preparation_iteration_counter + 1'b1;
					end
					Mode_256: begin
						if(current_key_preparation_iteration_counter == 4'd6)
              						next_state = READY;
            					else
                					next_key_preparation_iteration_counter = current_key_preparation_iteration_counter + 1'b1;
					end
					default: begin
						next_state = IDLE;
					end
				endcase
			end

			READY: begin
				key_preparation_ready = 1'b1;
				case(current_mode)
					Mode_128: begin
						if(key_round <= 4'd10) begin
							key_preparation_out_valid = 1'b1;
							Key_Preparation_key_out = {words[4*key_round],
										   words[4*key_round + 1],
										   words[4*key_round + 2],
										   words[4*key_round + 3]};
						end
			 		end
					Mode_192: begin
						if(key_round <= 4'd12) begin
							key_preparation_out_valid = 1'b1;
							Key_Preparation_key_out = {words[4*key_round],
										   words[4*key_round + 1],
										   words[4*key_round + 2],
										   words[4*key_round + 3]};
						end	
					end
					Mode_256: begin
						if(key_round <= 4'd14) begin
							key_preparation_out_valid = 1'b1;
							Key_Preparation_key_out = {words[4*key_round],
										   words[4*key_round + 1],
										   words[4*key_round + 2],
										   words[4*key_round + 3]};
						end
					end
					default: begin
						key_preparation_out_valid = 1'b0;
						Key_Preparation_key_out = 128'd0;
					end
				endcase

				if(start) begin
					next_key_in = Key_Preparation_key_in;
					next_mode = AES_mode;
					next_state = LOAD_KEY;
				end
			end

			default: begin

			end
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= IDLE;
			current_key_in <= 256'd0;
			current_mode <= 2'd0;
			current_key_preparation_iteration_counter <= 4'd0;

			for(i = 0; i < 60; i = i + 1)
            			words[i] <= 32'd0;

		end
		else begin
			current_state <= next_state;
			current_key_in <= next_key_in;
			current_mode <= next_mode;
			current_key_preparation_iteration_counter <= next_key_preparation_iteration_counter;
			
			if(current_state == LOAD_KEY) begin
				case(current_mode)
					Mode_128: begin
						words[0] <= current_key_in[127:96];
						words[1] <= current_key_in[95:64];
						words[2] <= current_key_in[63:32];
						words[3] <= current_key_in[31:0];
					end
					Mode_192: begin
						words[0] <= current_key_in[191:160];
						words[1] <= current_key_in[159:128];
						words[2] <= current_key_in[127:96];
						words[3] <= current_key_in[95:64];
						words[4] <= current_key_in[63:32];
						words[5] <= current_key_in[31:0];
					end
					Mode_256: begin
						words[0] <= current_key_in[255:224];
						words[1] <= current_key_in[223:192];
						words[2] <= current_key_in[191:160];
						words[3] <= current_key_in[159:128];
						words[4] <= current_key_in[127:96];
						words[5] <= current_key_in[95:64];
						words[6] <= current_key_in[63:32];
						words[7] <= current_key_in[31:0];
					end
					default: begin
						words[0] <= 32'd0;
						words[1] <= 32'd0;
						words[2] <= 32'd0;
						words[3] <= 32'd0;
						words[4] <= 32'd0;
						words[5] <= 32'd0;
						words[6] <= 32'd0;
						words[7] <= 32'd0;
					end
				endcase
			end

			if(current_state == KEY_PREPARATION) begin
				case(current_mode)
					Mode_128: begin
						words[4*current_key_preparation_iteration_counter + 4] <= key_expansion_128_out[127:96];
						words[4*current_key_preparation_iteration_counter + 5] <= key_expansion_128_out[95:64];
						words[4*current_key_preparation_iteration_counter + 6] <= key_expansion_128_out[63:32];
						words[4*current_key_preparation_iteration_counter + 7] <= key_expansion_128_out[31:0];
					end
					Mode_192: begin
						words[6*current_key_preparation_iteration_counter + 6] <= key_expansion_192_out[191:160];
						words[6*current_key_preparation_iteration_counter + 7] <= key_expansion_192_out[159:128];
						words[6*current_key_preparation_iteration_counter + 8] <= key_expansion_192_out[127:96];
						words[6*current_key_preparation_iteration_counter + 9] <= key_expansion_192_out[95:64];
						
						if(current_key_preparation_iteration_counter < 4'd7) begin
							words[6*current_key_preparation_iteration_counter + 10] <= key_expansion_192_out[63:32];
							words[6*current_key_preparation_iteration_counter + 11] <= key_expansion_192_out[31:0];
						end
					end
					Mode_256: begin
						words[8*current_key_preparation_iteration_counter + 8] <= key_expansion_256_out[255:224];
						words[8*current_key_preparation_iteration_counter + 9] <= key_expansion_256_out[223:192];
						words[8*current_key_preparation_iteration_counter + 10] <= key_expansion_256_out[191:160];
						words[8*current_key_preparation_iteration_counter + 11] <= key_expansion_256_out[159:128];

						if(current_key_preparation_iteration_counter < 4'd6) begin
							words[8*current_key_preparation_iteration_counter + 12] <= key_expansion_256_out[127:96];
							words[8*current_key_preparation_iteration_counter + 13] <= key_expansion_256_out[95:64];
							words[8*current_key_preparation_iteration_counter + 14] <= key_expansion_256_out[63:32];
							words[8*current_key_preparation_iteration_counter + 15] <= key_expansion_256_out[31:0];
						end
					end
					default: begin
						next_state = IDLE;
    						next_mode = 2'd0;
    						next_key_preparation_iteration_counter = 4'd0;
					end
				endcase
			end
		end
	end
endmodule

module AES_Encryption_Module(input clk, 
				input rst_n, 
				input[1:0] AES_Enc_mode, 
				input AES_Enc_valid, 
				input[127:0] AES_Enc_data_in, 
				input [127:0] AES_Enc_round_key,
				input AES_Enc_round_key_valid, 

				output reg[3:0] AES_Enc_key_round,
				output reg[127:0] AES_Enc_data_out, 
				output reg AES_Enc_busy,
				output reg AES_Enc_done);
	
	localparam Enc_128 = 2'd1,
		   Enc_192 = 2'd2,
		   Enc_256 = 2'd3;

	localparam IDLE = 3'd0,
		   INITIAL_ROUND = 3'd1, 
	 	   MIDDLE_ROUND = 3'd2,
		   FINAL_ROUND = 3'd3, 
		   DONE = 3'd4;

	reg [2:0] current_state, next_state;
	reg[1:0] AES_Encryption_current_mode, AES_Encryption_next_mode;
	reg[127:0] current_data, next_data;
	reg[3:0] data_round_counter, next_data_round_counter;

	reg[127:0] Sub_Bytes_in;
	reg[127:0] Shift_Rows_in;
	reg[127:0] Mix_Columns_in;
	reg[127:0] Add_Round_Key_data_in, Add_Round_key_key_in;

	wire[127:0] Sub_Bytes_out;
	wire[127:0] Shift_Rows_out;
	wire[127:0] Mix_Columns_out;
	wire[127:0] Add_Round_Key_out;	
	
	// Sub-Modules Instantations
	Sub_Bytes_Enc Sub_Bytes(.Sub_Bytes_Enc_data_in(Sub_Bytes_in), .Sub_Bytes_Enc_data_out(Sub_Bytes_out));
	Shift_Rows_Enc Shift_Rows(.Shift_Rows_Enc_data_in(Shift_Rows_in), .Shift_Rows_Enc_data_out(Shift_Rows_out));
	Mix_Columns_Enc Mix_Columns(.Mix_Columns_Enc_data_in(Mix_Columns_in), .Mix_Columns_Enc_data_out(Mix_Columns_out));
	Add_Round_Key_Enc Add_Round_Key(.Add_Round_Key_Enc_data_in(Add_Round_Key_data_in), .Add_Round_Key_Enc_key_in(Add_Round_key_key_in), .Add_Round_Key_Enc_data_out(Add_Round_Key_out));
	
	always @(*) begin
		// default values
		next_state = current_state;
		next_data = current_data;
		next_data_round_counter = data_round_counter;
		AES_Encryption_next_mode = AES_Encryption_current_mode;

		Sub_Bytes_in = 128'h0;
		Shift_Rows_in = 128'h0;
		Mix_Columns_in = 128'h0;
		Add_Round_Key_data_in = 128'h0;
		Add_Round_key_key_in = 128'h0;
	
		AES_Enc_key_round = 4'd0;
		AES_Enc_busy = 1'b0;
		AES_Enc_done = 1'b0;
		
		case(current_state)
			IDLE: begin
				if((AES_Enc_valid) && (AES_Enc_mode != 2'b00)) begin
					next_state = INITIAL_ROUND;
					next_data = AES_Enc_data_in;
					next_data_round_counter = 4'd0; 
					AES_Encryption_next_mode = AES_Enc_mode;
				end
			end

			INITIAL_ROUND: begin
				AES_Enc_busy = 1'b1;
				AES_Enc_key_round = 4'd0;

				if(AES_Enc_round_key_valid) begin
					Add_Round_Key_data_in = current_data;
					Add_Round_key_key_in = AES_Enc_round_key;
					next_data = Add_Round_Key_out;
					next_data_round_counter = 4'd1;
					next_state = MIDDLE_ROUND;
				end
			end

			MIDDLE_ROUND: begin
				AES_Enc_busy = 1'b1;
				AES_Enc_key_round = data_round_counter;

				if(AES_Enc_round_key_valid) begin
        				Sub_Bytes_in = current_data;
        				Shift_Rows_in = Sub_Bytes_out;
        				Mix_Columns_in = Shift_Rows_out;
        				Add_Round_Key_data_in = Mix_Columns_out;
        				Add_Round_key_key_in = AES_Enc_round_key;

        				next_data = Add_Round_Key_out;

        				case(AES_Encryption_current_mode)
            					Enc_128: begin
                					if(data_round_counter == 4'd9) begin
								next_data_round_counter = 4'd10;
                   						next_state = FINAL_ROUND;
							end
                					else
                    						next_data_round_counter = data_round_counter + 1'b1;
            					end

            					Enc_192: begin
                					if(data_round_counter == 4'd11) begin
								next_data_round_counter = 4'd12;
                    						next_state = FINAL_ROUND;
							end
                					else
                    						next_data_round_counter = data_round_counter + 1'b1;
            					end

            					Enc_256: begin
                					if(data_round_counter == 4'd13) begin
								next_data_round_counter = 4'd14;
                    						next_state = FINAL_ROUND;
							end
                					else
                    						next_data_round_counter = data_round_counter + 1'b1;
            					end

            					default: begin
                					next_state = IDLE;
            					end

        				endcase
    				end
			end

			FINAL_ROUND: begin
				AES_Enc_busy = 1'b1;
				AES_Enc_key_round = data_round_counter;

				if(AES_Enc_round_key_valid) begin
					Sub_Bytes_in = current_data;
        				Shift_Rows_in = Sub_Bytes_out;
        				Add_Round_Key_data_in = Shift_Rows_out;
        				Add_Round_key_key_in = AES_Enc_round_key;

        				next_data = Add_Round_Key_out;
        				next_state = DONE;
				end
			end

			DONE: begin
				AES_Enc_done = 1'b1;
				
				next_data_round_counter = 4'd0;
				AES_Encryption_next_mode = 2'd0;
				
				next_state = IDLE;
			end

			default: begin
				next_state = IDLE;
				next_data = 128'h0;
    				next_data_round_counter = 4'd0;
    				AES_Encryption_next_mode = 2'd0;
			end
		endcase	
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= IDLE;
			current_data <= 128'h0;
			AES_Enc_data_out <= 128'h0;
			data_round_counter <= 4'd0;
			AES_Encryption_current_mode <= 2'd0;
		end
		else begin
			current_state <= next_state;
			current_data <= next_data;
			data_round_counter <= next_data_round_counter;
			AES_Encryption_current_mode <= AES_Encryption_next_mode;

			if(current_state == FINAL_ROUND && AES_Enc_round_key_valid)
				AES_Enc_data_out <=  next_data;
		end
	end
endmodule	

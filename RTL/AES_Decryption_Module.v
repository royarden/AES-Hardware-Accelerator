module AES_Decryption_Module(input clk, 
				input rst_n, 
				input[1:0] AES_Dec_mode, 
				input AES_Dec_valid, 
				input[127:0] AES_Dec_data_in, 
				input [127:0] AES_Dec_round_key,
				input AES_Dec_round_key_valid, 

				output reg[3:0] AES_Dec_key_round,
				output reg[127:0] AES_Dec_data_out, 
				output reg AES_Dec_busy,
				output reg AES_Dec_done);
	
	localparam Dec_128 = 2'd1,
		   Dec_192 = 2'd2,
		   Dec_256 = 2'd3;

	localparam IDLE = 3'd0,
		   INITIAL_ROUND = 3'd1, 
	 	   MIDDLE_ROUND = 3'd2,
		   FINAL_ROUND = 3'd3, 
		   DONE = 3'd4;

	reg[2:0] current_state, next_state;
	reg[1:0] AES_Decryption_current_mode, AES_Decryption_next_mode;
	reg[127:0] current_data, next_data;
	reg[3:0] data_round_counter, next_data_round_counter;

	reg[127:0] Inv_Sub_Bytes_in;
	reg[127:0] Inv_Shift_Rows_in;
	reg[127:0] Inv_Mix_Columns_in;
	reg[127:0] Add_Round_Key_data_in, Add_Round_Key_key_in;

	wire[127:0] Inv_Sub_Bytes_out;
	wire[127:0] Inv_Shift_Rows_out;
	wire[127:0] Inv_Mix_Columns_out;
	wire[127:0] Add_Round_Key_out;	
	
	// Sub-Modules Instantations
	Sub_Bytes_Dec Inv_Sub_Bytes(.Sub_Bytes_Dec_data_in(Inv_Sub_Bytes_in), .Sub_Bytes_Dec_data_out(Inv_Sub_Bytes_out));
	Shift_Rows_Dec Inv_Shift_Rows(.Shift_Rows_Dec_data_in(Inv_Shift_Rows_in), .Shift_Rows_Dec_data_out(Inv_Shift_Rows_out));
	Mix_Columns_Dec Inv_Mix_Columns(.Mix_Columns_Dec_data_in(Inv_Mix_Columns_in), .Mix_Columns_Dec_data_out(Inv_Mix_Columns_out));
	Add_Round_Key_Dec Inv_Add_Round_Key(.Add_Round_Key_Dec_data_in(Add_Round_Key_data_in), .Add_Round_Key_Dec_key_in(Add_Round_Key_key_in), .Add_Round_Key_Dec_data_out(Add_Round_Key_out));
	
	always @(*) begin
		// default values
		next_state = current_state;
		next_data = current_data;
		next_data_round_counter = data_round_counter;
		AES_Decryption_next_mode = AES_Decryption_current_mode;

		Inv_Sub_Bytes_in = 128'h0;
		Inv_Shift_Rows_in = 128'h0;
		Inv_Mix_Columns_in = 128'h0;
		Add_Round_Key_data_in = 128'h0;
		Add_Round_Key_key_in = 128'h0;
	
		AES_Dec_key_round = 4'd0;
		AES_Dec_busy = 1'b0;
		AES_Dec_done = 1'b0;
		
		case(current_state)
			IDLE: begin
				if(AES_Dec_valid) begin
					case(AES_Dec_mode)
						Dec_128: begin
							next_data = AES_Dec_data_in;
					                next_data_round_counter = 4'd10;
					                AES_Decryption_next_mode = Dec_128;
					                next_state = INITIAL_ROUND;
						end
						Dec_192: begin
							next_data = AES_Dec_data_in;
					                next_data_round_counter = 4'd12;
					                AES_Decryption_next_mode = Dec_192;
					                next_state = INITIAL_ROUND;
						end
						Dec_256: begin
							next_data = AES_Dec_data_in;
					                next_data_round_counter = 4'd14;
					                AES_Decryption_next_mode = Dec_256;
					                next_state = INITIAL_ROUND;
						end
						default: begin
						end
					endcase
				end
			end

			INITIAL_ROUND: begin
				AES_Dec_busy = 1'b1;
				AES_Dec_key_round = data_round_counter;

				if(AES_Dec_round_key_valid) begin
        				Add_Round_Key_data_in = current_data;
        				Add_Round_Key_key_in = AES_Dec_round_key;

        				next_data = Add_Round_Key_out;

        				next_data_round_counter = data_round_counter - 1'b1;
        				next_state = MIDDLE_ROUND;
    				end
			end

			MIDDLE_ROUND: begin
				AES_Dec_busy = 1'b1;
				AES_Dec_key_round = data_round_counter;

				if(AES_Dec_round_key_valid) begin
        				Inv_Shift_Rows_in = current_data;
					Inv_Sub_Bytes_in = Inv_Shift_Rows_out;

					Add_Round_Key_data_in = Inv_Sub_Bytes_out;
        				Add_Round_Key_key_in = AES_Dec_round_key;

        				Inv_Mix_Columns_in = Add_Round_Key_out;
					next_data = Inv_Mix_Columns_out;
						
					if(data_round_counter == 4'd1) begin
						next_data_round_counter = 4'd0;
						next_state = FINAL_ROUND;
					end
					else
        					next_data_round_counter = data_round_counter - 1'b1;
    				end
			end

			FINAL_ROUND: begin
				AES_Dec_busy = 1'b1;
				AES_Dec_key_round = 4'd0;

				if(AES_Dec_round_key_valid) begin
        				Inv_Shift_Rows_in = current_data;
					Inv_Sub_Bytes_in = Inv_Shift_Rows_out;

					Add_Round_Key_data_in = Inv_Sub_Bytes_out;
        				Add_Round_Key_key_in = AES_Dec_round_key;

 
        				next_data = Add_Round_Key_out;
        				next_state = DONE;
				end
			end

			DONE: begin
				AES_Dec_done = 1'b1;
				
				next_data_round_counter = 4'd0;
				AES_Decryption_next_mode = 2'd0;
				
				next_state = IDLE;
			end

			default: begin
				next_state = IDLE;
				next_data = 128'h0;
    				next_data_round_counter = 4'd0;
    				AES_Decryption_next_mode = 2'd0;
			end
		endcase	
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= IDLE;
			current_data <= 128'h0;
			AES_Dec_data_out <= 128'h0;
			data_round_counter <= 4'd0;
			AES_Decryption_current_mode <= 2'd0;
		end
		else begin
			current_state <= next_state;
			current_data <= next_data;
			data_round_counter <= next_data_round_counter;
			AES_Decryption_current_mode <= AES_Decryption_next_mode;

			if(current_state == FINAL_ROUND && AES_Dec_round_key_valid)
				AES_Dec_data_out <=  next_data;
		end
	end
endmodule	

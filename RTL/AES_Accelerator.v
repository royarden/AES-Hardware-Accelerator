module AES_Accelerator(input clk, 
				input rst_n, 
				input start,
				input operation,
				input[1:0] AES_mode,

				input[127:0] AES_data_in,
				input[255:0] AES_key_in,

				output reg[127:0] AES_data_out, 
				output reg AES_busy,
				output reg AES_done);
	
	localparam ENCRYPT = 1'b0,
		   DECRYPT = 1'b1;

	localparam AES_128 = 2'd1,
		   AES_192 = 2'd2,
		   AES_256 = 2'd3;

	localparam IDLE = 3'd0,
		   START_KEY_PREPARE = 3'd1,
		   PREPARE_KEY = 3'd2, 
	 	   START_PROCESS = 3'd3,
		   PROCESS = 3'd4, 
		   DONE = 3'd5;

	reg[2:0] current_state, next_state;
	reg current_operation, next_operation;
	reg[1:0] current_mode, next_mode;
	reg[127:0] current_data, next_data;
	reg[255:0] current_key, next_key;

	reg key_preparation_start;
	reg[3:0] key_preparation_round;
	reg AES_Enc_valid;
	reg AES_Dec_valid;
	
	wire[127:0] key_preparation_key_out;
	wire key_preparation_out_valid;
	wire key_preparation_ready;
	wire[3:0] AES_Enc_key_round;
	wire[127:0] AES_Enc_data_out;
	wire AES_Enc_busy;
	wire AES_Enc_done;
	wire[3:0] AES_Dec_key_round;
	wire[127:0] AES_Dec_data_out;
	wire AES_Dec_busy;
	wire AES_Dec_done;
	
	// Sub-Modules Instantations
	Key_Preparation Key_Preparation (.clk(clk),
					 .rst_n(rst_n),
					 .start(key_preparation_start),
					 .AES_mode(current_mode),
					 .key_round(key_preparation_round),
					 .Key_Preparation_key_in(current_key),
					 .key_preparation_out_valid(key_preparation_out_valid),
					 .key_preparation_ready(key_preparation_ready),
					 .Key_Preparation_key_out(key_preparation_key_out));

	AES_Encryption_Module Encryption (.clk(clk),
					  .rst_n(rst_n),
					  .AES_Enc_mode(current_mode),
					  .AES_Enc_valid(AES_Enc_valid),
					  .AES_Enc_data_in(current_data),
					  .AES_Enc_round_key(key_preparation_key_out),
					  .AES_Enc_round_key_valid(key_preparation_out_valid),
					  .AES_Enc_key_round(AES_Enc_key_round),
					  .AES_Enc_data_out(AES_Enc_data_out),
					  .AES_Enc_busy(AES_Enc_busy),
					  .AES_Enc_done(AES_Enc_done));

	AES_Decryption_Module Decryption (.clk(clk),
					  .rst_n(rst_n),
					  .AES_Dec_mode(current_mode),
					  .AES_Dec_valid(AES_Dec_valid),
					  .AES_Dec_data_in(current_data),
					  .AES_Dec_round_key(key_preparation_key_out),
					  .AES_Dec_round_key_valid(key_preparation_out_valid),
					  .AES_Dec_key_round(AES_Dec_key_round),
					  .AES_Dec_data_out(AES_Dec_data_out),
					  .AES_Dec_busy(AES_Dec_busy),
					  .AES_Dec_done(AES_Dec_done));
	


	always @(*) begin
		// default values
		next_state = current_state;
		next_operation = current_operation;
		next_mode = current_mode;
		next_data = current_data;
		next_key = current_key;

		key_preparation_start = 1'b0;
    		key_preparation_round = 4'd0;

    		AES_Enc_valid = 1'b0;
    		AES_Dec_valid = 1'b0;

    		AES_data_out = 128'h0;
    		AES_busy = 1'b0;
    		AES_done = 1'b0;

		if(current_operation == ENCRYPT)
			key_preparation_round = AES_Enc_key_round;
		else
			key_preparation_round = AES_Dec_key_round;
		
		case(current_state)
			IDLE: begin
				if(start) begin
					case(AES_mode)
						AES_128, AES_192, AES_256: begin
							next_operation = operation;
							next_mode = AES_mode;
							next_data = AES_data_in;
							next_key = AES_key_in;

							next_state = START_KEY_PREPARE;
						end
						default: begin
							next_state = IDLE;
						end
					endcase
				end
			end

			START_KEY_PREPARE: begin
				AES_busy = 1'b1;
				key_preparation_start = 1'b1;
				next_state = PREPARE_KEY;
			end

			PREPARE_KEY: begin
				AES_busy = 1'b1;
				if(key_preparation_ready) 
					next_state = START_PROCESS;
			end

			START_PROCESS: begin
				AES_busy = 1'b1;

				if(current_operation == ENCRYPT)
					AES_Enc_valid = 1'b1;
				else
					AES_Dec_valid = 1'b1;
				next_state = PROCESS;
			end

			PROCESS: begin
				AES_busy = 1'b1;
				if(current_operation == ENCRYPT) begin
					if(AES_Enc_done)
						next_state = DONE;
				end
				else begin
					if(AES_Dec_done)
						next_state = DONE;
				end
			end
			
			DONE: begin
				AES_done = 1'b1;
				if(current_operation == ENCRYPT)
					AES_data_out = AES_Enc_data_out;
				else
					AES_data_out = AES_Dec_data_out;
				next_state = IDLE;
			end
			default: begin
				next_state = IDLE;
				next_operation = ENCRYPT;
				next_mode = 2'd0;
				next_data = 128'd0;
				next_key = 256'd0;
			end
		endcase	
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= IDLE;
			current_operation <= ENCRYPT;
			current_mode <= 2'd0;
			current_data <= 128'd0;
			current_key <= 256'd0;
		end
		else begin
			current_state <= next_state;
			current_operation <= next_operation;
			current_mode <= next_mode;
			current_data <= next_data;
			current_key <= next_key;
		end
	end
endmodule	

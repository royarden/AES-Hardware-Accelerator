module Key_Expansion_128_Enc(input[127:0] Key_Expansion_Enc_key_in, input[3:0] Key_Expansion_Enc_Current_round, output reg[127:0] Key_Expansion_Enc_key_out);

	reg[31:0] first_word_in, second_word_in, third_word_in, fourth_word_in;
	reg[31:0] first_word_out, second_word_out, third_word_out, fourth_word_out;
	wire[31:0] fourth_word_rotated;
	wire[31:0] Sub_Word;
	reg[31:0] Rcon;
	reg[31:0] temp;

	Sbox_Enc key_sbox0 (.a(fourth_word_rotated[31:24]), .c(Sub_Word[31:24]));
	Sbox_Enc key_sbox1 (.a(fourth_word_rotated[23:16]), .c(Sub_Word[23:16]));
	Sbox_Enc key_sbox2 (.a(fourth_word_rotated[15:8]), .c(Sub_Word[15:8]));
	Sbox_Enc key_sbox3 (.a(fourth_word_rotated[7:0]), .c(Sub_Word[7:0]));

	assign fourth_word_rotated = {Key_Expansion_Enc_key_in[23:0], Key_Expansion_Enc_key_in[31:24]};

	always @(*) begin
		case(Key_Expansion_Enc_Current_round)
			4'd0: Rcon = 32'h01000000;
			4'd1: Rcon = 32'h02000000;
			4'd2: Rcon = 32'h04000000;
			4'd3: Rcon = 32'h08000000;
			4'd4: Rcon = 32'h10000000;
			4'd5: Rcon = 32'h20000000;
			4'd6: Rcon = 32'h40000000;
			4'd7: Rcon = 32'h80000000;
			4'd8: Rcon = 32'h1B000000;
			4'd9: Rcon = 32'h36000000;
			4'd10: Rcon = 32'h6C000000;
			4'd11: Rcon = 32'hD8000000;
			4'd12: Rcon = 32'hAB000000;
			4'd13: Rcon = 32'h4D000000;
			default: Rcon = 32'h00000000;
		endcase 

		first_word_in = Key_Expansion_Enc_key_in[127:96];
		second_word_in = Key_Expansion_Enc_key_in[95:64];
		third_word_in = Key_Expansion_Enc_key_in[63:32];
		fourth_word_in = Key_Expansion_Enc_key_in[31:0];

		temp = Sub_Word ^ Rcon;

		first_word_out = first_word_in ^ temp;
		second_word_out = second_word_in ^ first_word_out;
		third_word_out = third_word_in ^ second_word_out;
		fourth_word_out = fourth_word_in ^ third_word_out;

		Key_Expansion_Enc_key_out = {first_word_out, second_word_out, third_word_out, fourth_word_out};
	end
endmodule
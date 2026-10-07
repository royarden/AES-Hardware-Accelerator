module Key_Expansion_192_Enc(input[191:0] Key_Expansion_Enc_key_in, input[2:0] Key_Expansion_Enc_Current_round, output reg[191:0] Key_Expansion_Enc_key_out);

	reg[31:0] first_word_in, second_word_in, third_word_in, fourth_word_in, fifth_word_in, sixth_word_in;
	reg[31:0] first_word_out, second_word_out, third_word_out, fourth_word_out, fifth_word_out, sixth_word_out;
	wire[31:0] sixth_word_rotated;
	wire[31:0] Sub_Word;
	reg[31:0] Rcon;
	reg[31:0] temp;

	Sbox_Enc key_sbox0 (.a(sixth_word_rotated[31:24]), .c(Sub_Word[31:24]));
	Sbox_Enc key_sbox1 (.a(sixth_word_rotated[23:16]), .c(Sub_Word[23:16]));
	Sbox_Enc key_sbox2 (.a(sixth_word_rotated[15:8]), .c(Sub_Word[15:8]));
	Sbox_Enc key_sbox3 (.a(sixth_word_rotated[7:0]), .c(Sub_Word[7:0]));

	assign sixth_word_rotated = {Key_Expansion_Enc_key_in[23:0], Key_Expansion_Enc_key_in[31:24]};

	always @(*) begin
		case(Key_Expansion_Enc_Current_round)
			3'd0: Rcon = 32'h01000000;
			3'd1: Rcon = 32'h02000000;
			3'd2: Rcon = 32'h04000000;
			3'd3: Rcon = 32'h08000000;
			3'd4: Rcon = 32'h10000000;
			3'd5: Rcon = 32'h20000000;
			3'd6: Rcon = 32'h40000000;
			3'd7: Rcon = 32'h80000000;
			default: Rcon = 32'h00000000;
		endcase 

		first_word_in = Key_Expansion_Enc_key_in[191:160];
		second_word_in = Key_Expansion_Enc_key_in[159:128];
		third_word_in = Key_Expansion_Enc_key_in[127:96];
		fourth_word_in = Key_Expansion_Enc_key_in[95:64];
		fifth_word_in = Key_Expansion_Enc_key_in[63:32];
		sixth_word_in = Key_Expansion_Enc_key_in[31:0];

		temp = Sub_Word ^ Rcon;

		first_word_out = first_word_in ^ temp;
		second_word_out = second_word_in ^ first_word_out;
		third_word_out = third_word_in ^ second_word_out;
		fourth_word_out = fourth_word_in ^ third_word_out;
		fifth_word_out = fifth_word_in ^ fourth_word_out;
		sixth_word_out = sixth_word_in ^ fifth_word_out;

		Key_Expansion_Enc_key_out = {first_word_out, second_word_out, third_word_out, fourth_word_out, fifth_word_out, sixth_word_out};
	end
endmodule
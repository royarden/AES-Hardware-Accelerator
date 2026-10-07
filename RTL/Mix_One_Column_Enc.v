module Mix_One_Column_Enc(input[31:0] Mix_One_Column_Enc_data_in, output reg[31:0] Mix_One_Column_Enc_data_out);

	reg[7:0] first_byte_times_two, second_byte_times_two, third_byte_times_two, fourth_byte_times_two;
	reg[7:0] first_byte_times_three, second_byte_times_three, third_byte_times_three, fourth_byte_times_three;

	always @(*) begin
		first_byte_times_two = Mix_One_Column_Enc_data_in[31] ? ((Mix_One_Column_Enc_data_in[31:24] << 1) ^ 8'h1B) : (Mix_One_Column_Enc_data_in[31:24] << 1);
		second_byte_times_two = Mix_One_Column_Enc_data_in[23] ? ((Mix_One_Column_Enc_data_in[23:16] << 1) ^ 8'h1B) : (Mix_One_Column_Enc_data_in[23:16] << 1);
		third_byte_times_two = Mix_One_Column_Enc_data_in[15] ? ((Mix_One_Column_Enc_data_in[15:8] << 1) ^ 8'h1B) : (Mix_One_Column_Enc_data_in[15:8] << 1);
		fourth_byte_times_two = Mix_One_Column_Enc_data_in[7] ? ((Mix_One_Column_Enc_data_in[7:0] << 1) ^ 8'h1B) : (Mix_One_Column_Enc_data_in[7:0] << 1);

		first_byte_times_three = Mix_One_Column_Enc_data_in[31:24] ^ first_byte_times_two;
		second_byte_times_three = Mix_One_Column_Enc_data_in[23:16] ^ second_byte_times_two;
		third_byte_times_three = Mix_One_Column_Enc_data_in[15:8] ^ third_byte_times_two;
		fourth_byte_times_three = Mix_One_Column_Enc_data_in[7:0] ^ fourth_byte_times_two;

		Mix_One_Column_Enc_data_out[31:24] = first_byte_times_two ^ second_byte_times_three ^ Mix_One_Column_Enc_data_in[15:8] ^ Mix_One_Column_Enc_data_in[7:0];
		Mix_One_Column_Enc_data_out[23:16] = Mix_One_Column_Enc_data_in[31:24] ^ second_byte_times_two ^ third_byte_times_three ^ Mix_One_Column_Enc_data_in[7:0];
		Mix_One_Column_Enc_data_out[15:8] = Mix_One_Column_Enc_data_in[31:24] ^ Mix_One_Column_Enc_data_in[23:16] ^ third_byte_times_two ^ fourth_byte_times_three;
		Mix_One_Column_Enc_data_out[7:0] = first_byte_times_three ^ Mix_One_Column_Enc_data_in[23:16] ^ Mix_One_Column_Enc_data_in[15:8] ^ fourth_byte_times_two;
	end
endmodule
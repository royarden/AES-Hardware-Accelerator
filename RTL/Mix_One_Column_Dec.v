module Mix_One_Column_Dec(input[31:0] Mix_One_Column_Dec_data_in, output reg[31:0] Mix_One_Column_Dec_data_out);

	reg[7:0] first_byte_times_two, second_byte_times_two, third_byte_times_two, fourth_byte_times_two;
	reg[7:0] first_byte_times_four, second_byte_times_four, third_byte_times_four, fourth_byte_times_four;
	reg[7:0] first_byte_times_eight, second_byte_times_eight, third_byte_times_eight, fourth_byte_times_eight;
	reg[7:0] first_byte_times_nine, second_byte_times_nine, third_byte_times_nine, fourth_byte_times_nine;
	reg[7:0] first_byte_times_eleven, second_byte_times_eleven, third_byte_times_eleven, fourth_byte_times_eleven;
	reg[7:0] first_byte_times_thirteen, second_byte_times_thirteen, third_byte_times_thirteen, fourth_byte_times_thirteen;
	reg[7:0] first_byte_times_fourteen, second_byte_times_fourteen, third_byte_times_fourteen, fourth_byte_times_fourteen;

	always @(*) begin
		first_byte_times_two = Mix_One_Column_Dec_data_in[31] ? ((Mix_One_Column_Dec_data_in[31:24] << 1) ^ 8'h1B) : (Mix_One_Column_Dec_data_in[31:24] << 1);
		second_byte_times_two = Mix_One_Column_Dec_data_in[23] ? ((Mix_One_Column_Dec_data_in[23:16] << 1) ^ 8'h1B) : (Mix_One_Column_Dec_data_in[23:16] << 1);
		third_byte_times_two = Mix_One_Column_Dec_data_in[15] ? ((Mix_One_Column_Dec_data_in[15:8] << 1) ^ 8'h1B) : (Mix_One_Column_Dec_data_in[15:8] << 1);
		fourth_byte_times_two = Mix_One_Column_Dec_data_in[7] ? ((Mix_One_Column_Dec_data_in[7:0] << 1) ^ 8'h1B) : (Mix_One_Column_Dec_data_in[7:0] << 1);

		first_byte_times_four = first_byte_times_two[7] ? ((first_byte_times_two << 1) ^ 8'h1B) : (first_byte_times_two << 1);
		second_byte_times_four = second_byte_times_two[7] ? ((second_byte_times_two << 1) ^ 8'h1B) : (second_byte_times_two << 1);
		third_byte_times_four = third_byte_times_two[7] ? ((third_byte_times_two << 1) ^ 8'h1B) : (third_byte_times_two << 1);
		fourth_byte_times_four = fourth_byte_times_two[7] ? ((fourth_byte_times_two << 1) ^ 8'h1B) : (fourth_byte_times_two << 1);

		first_byte_times_eight = first_byte_times_four[7] ? ((first_byte_times_four << 1) ^ 8'h1B) : (first_byte_times_four << 1);
		second_byte_times_eight = second_byte_times_four[7] ? ((second_byte_times_four << 1) ^ 8'h1B) : (second_byte_times_four << 1);
		third_byte_times_eight = third_byte_times_four[7] ? ((third_byte_times_four << 1) ^ 8'h1B) : (third_byte_times_four << 1);
		fourth_byte_times_eight = fourth_byte_times_four[7] ? ((fourth_byte_times_four << 1) ^ 8'h1B) : (fourth_byte_times_four << 1);

		first_byte_times_nine = Mix_One_Column_Dec_data_in[31:24] ^ first_byte_times_eight;
		second_byte_times_nine = Mix_One_Column_Dec_data_in[23:16] ^ second_byte_times_eight;
		third_byte_times_nine = Mix_One_Column_Dec_data_in[15:8] ^ third_byte_times_eight;
		fourth_byte_times_nine = Mix_One_Column_Dec_data_in[7:0] ^ fourth_byte_times_eight;

		first_byte_times_eleven = first_byte_times_nine ^ first_byte_times_two;
		second_byte_times_eleven = second_byte_times_nine ^ second_byte_times_two;
		third_byte_times_eleven = third_byte_times_nine ^ third_byte_times_two;
		fourth_byte_times_eleven = fourth_byte_times_nine ^ fourth_byte_times_two;

		first_byte_times_thirteen = first_byte_times_nine ^ first_byte_times_four;
		second_byte_times_thirteen = second_byte_times_nine ^ second_byte_times_four;
		third_byte_times_thirteen = third_byte_times_nine ^ third_byte_times_four;
		fourth_byte_times_thirteen = fourth_byte_times_nine ^ fourth_byte_times_four;

		first_byte_times_fourteen = first_byte_times_eight ^ first_byte_times_four ^ first_byte_times_two;
		second_byte_times_fourteen = second_byte_times_eight ^ second_byte_times_four ^ second_byte_times_two;
		third_byte_times_fourteen = third_byte_times_eight ^ third_byte_times_four ^ third_byte_times_two;
		fourth_byte_times_fourteen = fourth_byte_times_eight ^ fourth_byte_times_four ^ fourth_byte_times_two;

		Mix_One_Column_Dec_data_out[31:24] = first_byte_times_fourteen ^ second_byte_times_eleven ^ third_byte_times_thirteen ^ fourth_byte_times_nine;
		Mix_One_Column_Dec_data_out[23:16] = first_byte_times_nine ^ second_byte_times_fourteen ^ third_byte_times_eleven ^ fourth_byte_times_thirteen;
		Mix_One_Column_Dec_data_out[15:8] = first_byte_times_thirteen ^ second_byte_times_nine ^ third_byte_times_fourteen ^ fourth_byte_times_eleven;
		Mix_One_Column_Dec_data_out[7:0] = first_byte_times_eleven ^ second_byte_times_thirteen ^ third_byte_times_nine ^ fourth_byte_times_fourteen;
	end
endmodule
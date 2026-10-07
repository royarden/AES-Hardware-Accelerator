module Shift_Rows_Enc(input[127:0] Shift_Rows_Enc_data_in, output reg[127:0] Shift_Rows_Enc_data_out);

	reg[31:0] first_row_in, second_row_in, third_row_in, fourth_row_in;
	reg[31:0] second_row_shifted, third_row_shifted, fourth_row_shifted;
	reg[31:0] first_column_out, second_column_out, third_column_out, fourth_column_out;

	always @(*) begin
		first_row_in = {Shift_Rows_Enc_data_in[127:120], Shift_Rows_Enc_data_in[95:88], Shift_Rows_Enc_data_in[63:56], Shift_Rows_Enc_data_in[31:24]};
		second_row_in = {Shift_Rows_Enc_data_in[119:112], Shift_Rows_Enc_data_in[87:80], Shift_Rows_Enc_data_in[55:48], Shift_Rows_Enc_data_in[23:16]};
		third_row_in = {Shift_Rows_Enc_data_in[111:104], Shift_Rows_Enc_data_in[79:72], Shift_Rows_Enc_data_in[47:40], Shift_Rows_Enc_data_in[15:8]};
		fourth_row_in = {Shift_Rows_Enc_data_in[103:96], Shift_Rows_Enc_data_in[71:64], Shift_Rows_Enc_data_in[39:32], Shift_Rows_Enc_data_in[7:0]};

		second_row_shifted = {second_row_in[23:0], second_row_in[31:24]};
		third_row_shifted = {third_row_in[15:0], third_row_in[31:16]};
		fourth_row_shifted = {fourth_row_in[7:0], fourth_row_in[31:8]};

		first_column_out = {first_row_in[31:24], second_row_shifted[31:24], third_row_shifted[31:24], fourth_row_shifted[31:24]};
		second_column_out = {first_row_in[23:16], second_row_shifted[23:16], third_row_shifted[23:16], fourth_row_shifted[23:16]};
		third_column_out = {first_row_in[15:8], second_row_shifted[15:8], third_row_shifted[15:8], fourth_row_shifted[15:8]};
		fourth_column_out = {first_row_in[7:0], second_row_shifted[7:0], third_row_shifted[7:0], fourth_row_shifted[7:0]};

		Shift_Rows_Enc_data_out = {first_column_out, second_column_out, third_column_out, fourth_column_out};
	end
endmodule
	
module Mix_Columns_Enc(input[127:0] Mix_Columns_Enc_data_in, output[127:0] Mix_Columns_Enc_data_out);

	Mix_One_Column_Enc First_Column(.Mix_One_Column_Enc_data_in(Mix_Columns_Enc_data_in[127:96]), .Mix_One_Column_Enc_data_out(Mix_Columns_Enc_data_out[127:96]));
	Mix_One_Column_Enc Second_Column(.Mix_One_Column_Enc_data_in(Mix_Columns_Enc_data_in[95:64]), .Mix_One_Column_Enc_data_out(Mix_Columns_Enc_data_out[95:64]));
	Mix_One_Column_Enc Third_Column(.Mix_One_Column_Enc_data_in(Mix_Columns_Enc_data_in[63:32]), .Mix_One_Column_Enc_data_out(Mix_Columns_Enc_data_out[63:32]));
	Mix_One_Column_Enc Fourth_Column(.Mix_One_Column_Enc_data_in(Mix_Columns_Enc_data_in[31:0]), .Mix_One_Column_Enc_data_out(Mix_Columns_Enc_data_out[31:0]));

endmodule

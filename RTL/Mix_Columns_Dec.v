module Mix_Columns_Dec(input[127:0] Mix_Columns_Dec_data_in, output[127:0] Mix_Columns_Dec_data_out);

	Mix_One_Column_Dec First_Column(.Mix_One_Column_Dec_data_in(Mix_Columns_Dec_data_in[127:96]), .Mix_One_Column_Dec_data_out(Mix_Columns_Dec_data_out[127:96]));
	Mix_One_Column_Dec Second_Column(.Mix_One_Column_Dec_data_in(Mix_Columns_Dec_data_in[95:64]), .Mix_One_Column_Dec_data_out(Mix_Columns_Dec_data_out[95:64]));
	Mix_One_Column_Dec Third_Column(.Mix_One_Column_Dec_data_in(Mix_Columns_Dec_data_in[63:32]), .Mix_One_Column_Dec_data_out(Mix_Columns_Dec_data_out[63:32]));
	Mix_One_Column_Dec Fourth_Column(.Mix_One_Column_Dec_data_in(Mix_Columns_Dec_data_in[31:0]), .Mix_One_Column_Dec_data_out(Mix_Columns_Dec_data_out[31:0]));

endmodule

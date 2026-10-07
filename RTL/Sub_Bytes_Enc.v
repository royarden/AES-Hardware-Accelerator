module Sub_Bytes_Enc(input[127:0] Sub_Bytes_Enc_data_in, output[127:0] Sub_Bytes_Enc_data_out);

	Sbox_Enc s0(.a(Sub_Bytes_Enc_data_in[127:120]), .c(Sub_Bytes_Enc_data_out[127:120]));
	Sbox_Enc s1(.a(Sub_Bytes_Enc_data_in[119:112]), .c(Sub_Bytes_Enc_data_out[119:112]));
	Sbox_Enc s2(.a(Sub_Bytes_Enc_data_in[111:104]), .c(Sub_Bytes_Enc_data_out[111:104]));
	Sbox_Enc s3(.a(Sub_Bytes_Enc_data_in[103:96]), .c(Sub_Bytes_Enc_data_out[103:96]));

	Sbox_Enc s4(.a(Sub_Bytes_Enc_data_in[95:88]), .c(Sub_Bytes_Enc_data_out[95:88]));
	Sbox_Enc s5(.a(Sub_Bytes_Enc_data_in[87:80]), .c(Sub_Bytes_Enc_data_out[87:80]));
	Sbox_Enc s6(.a(Sub_Bytes_Enc_data_in[79:72]), .c(Sub_Bytes_Enc_data_out[79:72]));
	Sbox_Enc s7(.a(Sub_Bytes_Enc_data_in[71:64]), .c(Sub_Bytes_Enc_data_out[71:64]));

	Sbox_Enc s8(.a(Sub_Bytes_Enc_data_in[63:56]), .c(Sub_Bytes_Enc_data_out[63:56]));
	Sbox_Enc s9(.a(Sub_Bytes_Enc_data_in[55:48]), .c(Sub_Bytes_Enc_data_out[55:48]));
	Sbox_Enc s10(.a(Sub_Bytes_Enc_data_in[47:40]), .c(Sub_Bytes_Enc_data_out[47:40]));
	Sbox_Enc s11(.a(Sub_Bytes_Enc_data_in[39:32]), .c(Sub_Bytes_Enc_data_out[39:32]));

	Sbox_Enc s12(.a(Sub_Bytes_Enc_data_in[31:24]), .c(Sub_Bytes_Enc_data_out[31:24]));
	Sbox_Enc s13(.a(Sub_Bytes_Enc_data_in[23:16]), .c(Sub_Bytes_Enc_data_out[23:16]));
	Sbox_Enc s14(.a(Sub_Bytes_Enc_data_in[15:8]), .c(Sub_Bytes_Enc_data_out[15:8]));
	Sbox_Enc s15(.a(Sub_Bytes_Enc_data_in[7:0]), .c(Sub_Bytes_Enc_data_out[7:0]));

endmodule

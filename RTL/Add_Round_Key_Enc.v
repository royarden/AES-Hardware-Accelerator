module Add_Round_Key_Enc(input[127:0] Add_Round_Key_Enc_data_in, input[127:0] Add_Round_Key_Enc_key_in, output[127:0] Add_Round_Key_Enc_data_out);

	assign Add_Round_Key_Enc_data_out = Add_Round_Key_Enc_data_in ^ Add_Round_Key_Enc_key_in;

endmodule
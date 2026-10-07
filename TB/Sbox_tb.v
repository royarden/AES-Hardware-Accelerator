`timescale 1ns/1ps

module Sbox_tb;

    reg  [7:0] data_in;

    wire [7:0] enc_out;
    wire [7:0] dec_out;
    wire [7:0] inverse_out;

    integer i;
    integer errors;


    // ------------------------------------------------------------
    // DUT 1: Encryption S-box
    // ------------------------------------------------------------
    Sbox_Enc DUT_Sbox_Enc (
        .a  (data_in),
        .c (enc_out)
    );


    // ------------------------------------------------------------
    // DUT 2: Decryption S-box
    // ------------------------------------------------------------
    Sbox_Dec DUT_Sbox_Dec (
        .a  (data_in),
        .c (dec_out)
    );


    // ------------------------------------------------------------
    // DUT 3:
    // Feed encryption result into inverse S-box.
    //
    // This allows us to verify:
    // Sbox_Dec(Sbox_Enc(x)) = x
    // ------------------------------------------------------------
    Sbox_Dec DUT_Inverse_Check (
        .a  (enc_out),
        .c (inverse_out)
    );


    initial begin

        errors = 0;
        data_in = 8'h00;

        #10;


        // ========================================================
        // Known AES S-box values
        // ========================================================

        $display("--------------------------------------------");
        $display("Testing known AES S-box values");
        $display("--------------------------------------------");


        data_in = 8'h00;
        #1;

        if (enc_out !== 8'h63) begin
            $display("FAIL: Sbox_Enc(00) = %h, expected 63",
                     enc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Enc(00) = 63");
        end


        data_in = 8'h53;
        #1;

        if (enc_out !== 8'hED) begin
            $display("FAIL: Sbox_Enc(53) = %h, expected ED",
                     enc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Enc(53) = ED");
        end


        data_in = 8'h7C;
        #1;

        if (enc_out !== 8'h10) begin
            $display("FAIL: Sbox_Enc(7C) = %h, expected 10",
                     enc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Enc(7C) = 10");
        end


        // ========================================================
        // Known AES inverse S-box values
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("Testing known AES inverse S-box values");
        $display("--------------------------------------------");


        data_in = 8'h63;
        #1;

        if (dec_out !== 8'h00) begin
            $display("FAIL: Sbox_Dec(63) = %h, expected 00",
                     dec_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Dec(63) = 00");
        end


        data_in = 8'hED;
        #1;

        if (dec_out !== 8'h53) begin
            $display("FAIL: Sbox_Dec(ED) = %h, expected 53",
                     dec_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Dec(ED) = 53");
        end


        data_in = 8'h10;
        #1;

        if (dec_out !== 8'h7C) begin
            $display("FAIL: Sbox_Dec(10) = %h, expected 7C",
                     dec_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sbox_Dec(10) = 7C");
        end


        // ========================================================
        // Exhaustive inverse test
        //
        // Test every possible byte:
        // Sbox_Dec(Sbox_Enc(x)) == x
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("Testing all 256 possible input values");
        $display("--------------------------------------------");


        for (i = 0; i < 256; i = i + 1) begin

            data_in = i[7:0];

            #1;

            if (inverse_out !== i[7:0]) begin

                $display(
                    "FAIL: input=%h enc=%h inverse=%h",
                    data_in,
                    enc_out,
                    inverse_out
                );

                errors = errors + 1;

            end

        end


        // ========================================================
        // Final result
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin
            $display("SBOX TEST PASSED");
            $display("All tests completed successfully.");
        end
        else begin
            $display("SBOX TEST FAILED");
            $display("Number of errors: %0d", errors);
        end

        $display("============================================");

        $stop;

    end

endmodule
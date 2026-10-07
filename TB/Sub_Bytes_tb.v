`timescale 1ns/1ps

module Sub_Bytes_tb;

    reg  [127:0] data_in;

    wire [127:0] enc_out;
    wire [127:0] dec_out;
    wire [127:0] inverse_out;

    integer errors;


    // ============================================================
    // DUT 1: Encryption SubBytes
    // ============================================================

    Sub_Bytes_Enc DUT_Sub_Bytes_Enc (
        .Sub_Bytes_Enc_data_in  (data_in),
        .Sub_Bytes_Enc_data_out (enc_out)
    );


    // ============================================================
    // DUT 2: Decryption SubBytes
    // ============================================================

    Sub_Bytes_Dec DUT_Sub_Bytes_Dec (
        .Sub_Bytes_Dec_data_in  (data_in),
        .Sub_Bytes_Dec_data_out (dec_out)
    );


    // ============================================================
    // DUT 3:
    // InvSubBytes(SubBytes(x))
    // ============================================================

    Sub_Bytes_Dec DUT_Inverse_Check (
        .Sub_Bytes_Dec_data_in  (enc_out),
        .Sub_Bytes_Dec_data_out (inverse_out)
    );


    initial begin

        errors  = 0;
        data_in = 128'h0;

        #10;


        // ========================================================
        // TEST 1
        // Known AES SubBytes example
        //
        // Input:
        // 19 a0 9a e9 3d f4 c6 f8
        // e3 e2 8d 48 be 2b 2a 08
        //
        // Expected:
        // d4 e0 b8 1e 27 bf b4 41
        // 11 98 5d 52 ae f1 e5 30
        // ========================================================

        $display("--------------------------------------------");
        $display("TEST 1: Known AES SubBytes vector");
        $display("--------------------------------------------");

        data_in =
            128'h19a09ae93df4c6f8e3e28d48be2b2a08;

        #1;

        if (enc_out !==
            128'hd4e0b81e27bfb44111985d52aef1e530) begin

            $display("FAIL: Sub_Bytes_Enc");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'hd4e0b81e27bfb44111985d52aef1e530);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES SubBytes vector");
        end


        // ========================================================
        // TEST 2
        // Known AES inverse SubBytes example
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 2: Known AES InvSubBytes vector");
        $display("--------------------------------------------");

        data_in =
            128'hd4e0b81e27bfb44111985d52aef1e530;

        #1;

        if (dec_out !==
            128'h19a09ae93df4c6f8e3e28d48be2b2a08) begin

            $display("FAIL: Sub_Bytes_Dec");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", dec_out);
            $display("Expected = %h",
                128'h19a09ae93df4c6f8e3e28d48be2b2a08);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES InvSubBytes vector");
        end


        // ========================================================
        // TEST 3
        // Inverse property with AES state
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 3: Inverse property - AES state");
        $display("--------------------------------------------");

        data_in =
            128'h00112233445566778899aabbccddeeff;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: InvSubBytes(SubBytes(x)) != x");
            $display("Input   = %h", data_in);
            $display("Enc     = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: InvSubBytes(SubBytes(x)) = x");
        end


        // ========================================================
        // TEST 4
        // All zero state
        //
        // AES S-box:
        // Sbox(00) = 63
        //
        // Therefore all 16 bytes should become 63.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 4: All-zero state");
        $display("--------------------------------------------");

        data_in = 128'h00000000000000000000000000000000;

        #1;

        if (enc_out !==
            128'h63636363636363636363636363636363) begin

            $display("FAIL: All-zero state");
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'h63636363636363636363636363636363);

            errors = errors + 1;

        end
        else begin
            $display("PASS: All-zero state");
        end


        // ========================================================
        // TEST 5
        // Another arbitrary 128-bit state - inverse property
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 5: Inverse property - arbitrary state");
        $display("--------------------------------------------");

        data_in =
            128'h0123456789abcdeffedcba9876543210;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: Arbitrary state inverse test");
            $display("Input   = %h", data_in);
            $display("Enc     = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Arbitrary state inverse test");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("SUB_BYTES TEST PASSED");
            $display("All tests completed successfully.");

        end
        else begin

            $display("SUB_BYTES TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
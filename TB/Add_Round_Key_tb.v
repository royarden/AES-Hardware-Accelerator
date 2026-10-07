`timescale 1ns/1ps

module Add_Round_Key_tb;

    reg  [127:0] data_in;
    reg  [127:0] round_key;

    wire [127:0] enc_out;
    wire [127:0] dec_out;

    integer errors;


    // ============================================================
    // DUT 1: Encryption AddRoundKey
    // ============================================================

    Add_Round_Key_Enc DUT_Add_Round_Key_Enc (
        .Add_Round_Key_Enc_data_in  (data_in),
        .Add_Round_Key_Enc_key_in   (round_key),
        .Add_Round_Key_Enc_data_out (enc_out)
    );


    // ============================================================
    // DUT 2: Decryption AddRoundKey
    // ============================================================

    Add_Round_Key_Dec DUT_Add_Round_Key_Dec (
        .Add_Round_Key_Dec_data_in  (data_in),
        .Add_Round_Key_Dec_key_in   (round_key),
        .Add_Round_Key_Dec_data_out (dec_out)
    );


    initial begin

        errors    = 0;
        data_in   = 128'h0;
        round_key = 128'h0;

        #10;


        // ========================================================
        // TEST 1
        // Known AES initial AddRoundKey vector
        //
        // Plaintext:
        // 00112233445566778899aabbccddeeff
        //
        // Key:
        // 000102030405060708090a0b0c0d0e0f
        //
        // Result:
        // 00102030405060708090a0b0c0d0e0f0
        // ========================================================

        $display("--------------------------------------------");
        $display("TEST 1: Known AES AddRoundKey vector");
        $display("--------------------------------------------");

        data_in =
            128'h00112233445566778899aabbccddeeff;

        round_key =
            128'h000102030405060708090a0b0c0d0e0f;

        #1;

        if (enc_out !==
            128'h00102030405060708090a0b0c0d0e0f0) begin

            $display("FAIL: Add_Round_Key_Enc");
            $display("Data     = %h", data_in);
            $display("Key      = %h", round_key);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'h00102030405060708090a0b0c0d0e0f0);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES AddRoundKey vector");
        end


        // ========================================================
        // TEST 2
        // Same known vector through Dec module
        //
        // AddRoundKey is XOR, therefore encryption and
        // decryption perform exactly the same operation.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 2: Decryption AddRoundKey");
        $display("--------------------------------------------");

        data_in =
            128'h00102030405060708090a0b0c0d0e0f0;

        round_key =
            128'h000102030405060708090a0b0c0d0e0f;

        #1;

        if (dec_out !==
            128'h00112233445566778899aabbccddeeff) begin

            $display("FAIL: Add_Round_Key_Dec");
            $display("Data     = %h", data_in);
            $display("Key      = %h", round_key);
            $display("Actual   = %h", dec_out);
            $display("Expected = %h",
                128'h00112233445566778899aabbccddeeff);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Decryption AddRoundKey");
        end


        // ========================================================
        // TEST 3
        // Zero key
        //
        // x XOR 0 = x
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 3: Zero key");
        $display("--------------------------------------------");

        data_in =
            128'h0123456789abcdeffedcba9876543210;

        round_key =
            128'h00000000000000000000000000000000;

        #1;

        if (enc_out !== data_in) begin

            $display("FAIL: Zero-key test");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h", data_in);

            errors = errors + 1;

        end
        else begin
            $display("PASS: x XOR 0 = x");
        end


        // ========================================================
        // TEST 4
        // Identical state and key
        //
        // x XOR x = 0
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 4: Identical state and key");
        $display("--------------------------------------------");

        data_in =
            128'hdeadbeef0123456789abcdeffedcba98;

        round_key =
            128'hdeadbeef0123456789abcdeffedcba98;

        #1;

        if (enc_out !==
            128'h00000000000000000000000000000000) begin

            $display("FAIL: x XOR x test");
            $display("Actual   = %h", enc_out);
            $display("Expected = 00000000000000000000000000000000");

            errors = errors + 1;

        end
        else begin
            $display("PASS: x XOR x = 0");
        end


        // ========================================================
        // TEST 5
        // Complement with all-one key
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 5: All-one key");
        $display("--------------------------------------------");

        data_in =
            128'h00112233445566778899aabbccddeeff;

        round_key =
            128'hffffffffffffffffffffffffffffffff;

        #1;

        if (enc_out !==
            128'hffeeddccbbaa99887766554433221100) begin

            $display("FAIL: All-one key test");
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'hffeeddccbbaa99887766554433221100);

            errors = errors + 1;

        end
        else begin
            $display("PASS: All-one key test");
        end


        // ========================================================
        // TEST 6
        // Enc and Dec modules must give identical results
        // because both implement XOR.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 6: Enc/Dec equivalence");
        $display("--------------------------------------------");

        data_in =
            128'h123456789abcdef00123456789abcdef;

        round_key =
            128'h0f1e2d3c4b5a69788796a5b4c3d2e1f0;

        #1;

        if (enc_out !== dec_out) begin

            $display("FAIL: Enc and Dec outputs differ");
            $display("Enc = %h", enc_out);
            $display("Dec = %h", dec_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Enc and Dec produce identical XOR");
        end


        // ========================================================
        // TEST 7
        // Explicit arbitrary XOR check
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 7: Arbitrary XOR check");
        $display("--------------------------------------------");

        data_in =
            128'h0123456789abcdeffedcba9876543210;

        round_key =
            128'h11111111111111111111111111111111;

        #1;

        if (enc_out !== (data_in ^ round_key)) begin

            $display("FAIL: Arbitrary XOR check");
            $display("Data     = %h", data_in);
            $display("Key      = %h", round_key);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                (data_in ^ round_key));

            errors = errors + 1;

        end
        else begin
            $display("PASS: Arbitrary XOR check");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("ADD_ROUND_KEY TEST PASSED");
            $display("All tests completed successfully.");

        end
        else begin

            $display("ADD_ROUND_KEY TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
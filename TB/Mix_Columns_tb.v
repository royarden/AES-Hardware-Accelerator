`timescale 1ns/1ps

module Mix_Columns_tb;

    reg  [127:0] data_in;

    wire [127:0] enc_out;
    wire [127:0] dec_out;
    wire [127:0] inverse_out;

    integer errors;


    // ============================================================
    // DUT 1: Encryption MixColumns
    // ============================================================

    Mix_Columns_Enc DUT_Mix_Columns_Enc (
        .Mix_Columns_Enc_data_in  (data_in),
        .Mix_Columns_Enc_data_out (enc_out)
    );


    // ============================================================
    // DUT 2: Decryption InvMixColumns
    // ============================================================

    Mix_Columns_Dec DUT_Mix_Columns_Dec (
        .Mix_Columns_Dec_data_in  (data_in),
        .Mix_Columns_Dec_data_out (dec_out)
    );


    // ============================================================
    // DUT 3:
    // InvMixColumns(MixColumns(x))
    // ============================================================

    Mix_Columns_Dec DUT_Inverse_Check (
        .Mix_Columns_Dec_data_in  (enc_out),
        .Mix_Columns_Dec_data_out (inverse_out)
    );


    initial begin

        errors  = 0;
        data_in = 128'h0;

        #10;


        // ========================================================
        // TEST 1
        // Known AES full-state MixColumns vector
        //
        // This is the state immediately after ShiftRows
        // from the standard AES example.
        // ========================================================

        $display("--------------------------------------------");
        $display("TEST 1: Known AES MixColumns state");
        $display("--------------------------------------------");

        data_in =
            128'hd4bf5d302798e51e11f1b841aee0b452;

        #1;

        if (enc_out !==
            128'h046681e506264c28d37a48f89ae0cb19) begin

            $display("FAIL: Mix_Columns_Enc");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'h046681e506264c28d37a48f89ae0cb19);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES MixColumns state");
        end


        // ========================================================
        // TEST 2
        // Known AES inverse MixColumns
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 2: Known AES InvMixColumns state");
        $display("--------------------------------------------");

        data_in =
            128'h046681e506264c28d37a48f89ae0cb19;

        #1;

        if (dec_out !==
            128'hd4bf5d302798e51e11f1b841aee0b452) begin

            $display("FAIL: Mix_Columns_Dec");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", dec_out);
            $display("Expected = %h",
                128'hd4bf5d302798e51e11f1b841aee0b452);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES InvMixColumns state");
        end


        // ========================================================
        // TEST 3
        // Four independently known columns
        //
        // db135345 -> 8e4da1bc
        // f20a225c -> 9fdc589d
        // 01010101 -> 01010101
        // 00000000 -> 00000000
        //
        // This test is especially useful for checking the
        // 128-bit column wiring.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 3: Four-column wiring test");
        $display("--------------------------------------------");

        data_in =
            128'hdb135345f20a225c0101010100000000;

        #1;

        if (enc_out !==
            128'h8e4da1bc9fdc589d0101010100000000) begin

            $display("FAIL: Four-column wiring test");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'h8e4da1bc9fdc589d0101010100000000);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Four-column wiring test");
        end


        // ========================================================
        // TEST 4
        // Zero state
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 4: Zero state");
        $display("--------------------------------------------");

        data_in =
            128'h00000000000000000000000000000000;

        #1;

        if (enc_out !==
            128'h00000000000000000000000000000000) begin

            $display("FAIL: Zero state");
            $display("Actual   = %h", enc_out);
            $display("Expected = 00000000000000000000000000000000");

            errors = errors + 1;

        end
        else begin
            $display("PASS: Zero state");
        end


        // ========================================================
        // TEST 5
        // Equal-byte columns
        //
        // Each column contains four identical bytes.
        // Such a column is unchanged by MixColumns.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 5: Equal-byte columns");
        $display("--------------------------------------------");

        data_in =
            128'h010101012323232345454545ffffffff;

        #1;

        if (enc_out !== data_in) begin

            $display("FAIL: Equal-byte columns");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h", data_in);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Equal-byte columns unchanged");
        end


        // ========================================================
        // TEST 6
        // Inverse property
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 6: MixColumns inverse property");
        $display("--------------------------------------------");

        data_in =
            128'h00112233445566778899aabbccddeeff;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: InvMixColumns(MixColumns(x)) != x");
            $display("Input   = %h", data_in);
            $display("Mixed   = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: InvMixColumns(MixColumns(x)) = x");
        end


        // ========================================================
        // TEST 7
        // Second inverse test
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 7: Second inverse property test");
        $display("--------------------------------------------");

        data_in =
            128'hdeadbeef0123456789abcdeffedcba98;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: Second inverse test");
            $display("Input   = %h", data_in);
            $display("Mixed   = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Second inverse property test");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("MIX_COLUMNS TEST PASSED");
            $display("All tests completed successfully.");

        end
        else begin

            $display("MIX_COLUMNS TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
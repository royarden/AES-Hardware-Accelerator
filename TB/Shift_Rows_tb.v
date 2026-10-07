`timescale 1ns/1ps

module Shift_Rows_tb;

    reg  [127:0] data_in;

    wire [127:0] enc_out;
    wire [127:0] dec_out;
    wire [127:0] inverse_out;

    integer errors;


    // ============================================================
    // DUT 1: Encryption ShiftRows
    // ============================================================

    Shift_Rows_Enc DUT_Shift_Rows_Enc (
        .Shift_Rows_Enc_data_in  (data_in),
        .Shift_Rows_Enc_data_out (enc_out)
    );


    // ============================================================
    // DUT 2: Decryption InvShiftRows
    // ============================================================

    Shift_Rows_Dec DUT_Shift_Rows_Dec (
        .Shift_Rows_Dec_data_in  (data_in),
        .Shift_Rows_Dec_data_out (dec_out)
    );


    // ============================================================
    // DUT 3:
    // InvShiftRows(ShiftRows(x))
    // ============================================================

    Shift_Rows_Dec DUT_Inverse_Check (
        .Shift_Rows_Dec_data_in  (enc_out),
        .Shift_Rows_Dec_data_out (inverse_out)
    );


    initial begin

        errors  = 0;
        data_in = 128'h0;

        #10;


        // ========================================================
        // TEST 1
        // Known AES ShiftRows vector
        // ========================================================

        $display("--------------------------------------------");
        $display("TEST 1: Known AES ShiftRows vector");
        $display("--------------------------------------------");

        data_in =
            128'hd4e0b81e27bfb44111985d52aef1e530;

        #1;

        if (enc_out !==
            128'hd4bf5d302798e51e11f1b841aee0b452) begin

            $display("FAIL: Shift_Rows_Enc");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'hd4bf5d302798e51e11f1b841aee0b452);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES ShiftRows vector");
        end


        // ========================================================
        // TEST 2
        // Known AES InvShiftRows vector
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 2: Known AES InvShiftRows vector");
        $display("--------------------------------------------");

        data_in =
            128'hd4bf5d302798e51e11f1b841aee0b452;

        #1;

        if (dec_out !==
            128'hd4e0b81e27bfb44111985d52aef1e530) begin

            $display("FAIL: Shift_Rows_Dec");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", dec_out);
            $display("Expected = %h",
                128'hd4e0b81e27bfb44111985d52aef1e530);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Known AES InvShiftRows vector");
        end


        // ========================================================
        // TEST 3
        // Easy-to-read byte ordering test
        //
        // Input bytes:
        // 00 11 22 33 44 55 66 77
        // 88 99 aa bb cc dd ee ff
        //
        // This makes byte movement very easy to see.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 3: Byte ordering test");
        $display("--------------------------------------------");

        data_in =
            128'h00112233445566778899aabbccddeeff;

        #1;

        if (enc_out !==
            128'h0055aaff4499ee3388dd2277cc1166bb) begin

            $display("FAIL: Byte ordering test");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = %h",
                128'h0055aaff4499ee3388dd2277cc1166bb);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Byte ordering test");
        end


        // ========================================================
        // TEST 4
        // Inverse property
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 4: ShiftRows inverse property");
        $display("--------------------------------------------");

        data_in =
            128'h0123456789abcdeffedcba9876543210;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: InvShiftRows(ShiftRows(x)) != x");
            $display("Input   = %h", data_in);
            $display("Shift   = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: InvShiftRows(ShiftRows(x)) = x");
        end


        // ========================================================
        // TEST 5
        // All-zero state
        //
        // ShiftRows only changes byte positions,
        // therefore zero must remain zero.
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 5: All-zero state");
        $display("--------------------------------------------");

        data_in =
            128'h00000000000000000000000000000000;

        #1;

        if (enc_out !==
            128'h00000000000000000000000000000000) begin

            $display("FAIL: All-zero ShiftRows test");
            $display("Actual   = %h", enc_out);
            $display("Expected = 00000000000000000000000000000000");

            errors = errors + 1;

        end
        else begin
            $display("PASS: All-zero state");
        end


        // ========================================================
        // TEST 6
        // Another inverse check
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 6: Second inverse test");
        $display("--------------------------------------------");

        data_in =
            128'hdeadbeef0123456789abcdef76543210;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: Second inverse test");
            $display("Input   = %h", data_in);
            $display("Shift   = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: Second inverse test");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("SHIFT_ROWS TEST PASSED");
            $display("All tests completed successfully.");

        end
        else begin

            $display("SHIFT_ROWS TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
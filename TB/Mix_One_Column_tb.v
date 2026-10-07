`timescale 1ns/1ps

module Mix_One_Column_tb;

    reg  [31:0] data_in;

    wire [31:0] enc_out;
    wire [31:0] dec_out;
    wire [31:0] inverse_out;

    integer errors;


    // ============================================================
    // DUT 1: MixColumn
    // ============================================================

    Mix_One_Column_Enc DUT_Mix_One_Column_Enc (
        .Mix_One_Column_Enc_data_in  (data_in),
        .Mix_One_Column_Enc_data_out (enc_out)
    );


    // ============================================================
    // DUT 2: InvMixColumn
    // ============================================================

    Mix_One_Column_Dec DUT_Mix_One_Column_Dec (
        .Mix_One_Column_Dec_data_in  (data_in),
        .Mix_One_Column_Dec_data_out (dec_out)
    );


    // ============================================================
    // DUT 3:
    // InvMixColumn(MixColumn(x))
    // ============================================================

    Mix_One_Column_Dec DUT_Inverse_Check (
        .Mix_One_Column_Dec_data_in  (enc_out),
        .Mix_One_Column_Dec_data_out (inverse_out)
    );


    initial begin

        errors  = 0;
        data_in = 32'h00000000;

        #10;


        // ========================================================
        // TEST 1
        //
        // Standard AES MixColumns example:
        //
        // db
        // 13
        // 53
        // 45
        //
        // becomes:
        //
        // 8e
        // 4d
        // a1
        // bc
        // ========================================================

        $display("--------------------------------------------");
        $display("TEST 1: Known AES MixColumn vector");
        $display("--------------------------------------------");

        data_in = 32'hdb135345;

        #1;

        if (enc_out !== 32'h8e4da1bc) begin

            $display("FAIL: Mix_One_Column_Enc");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = 8e4da1bc");

            errors = errors + 1;

        end
        else begin
            $display("PASS: db135345 -> 8e4da1bc");
        end


        // ========================================================
        // TEST 2
        // Inverse of TEST 1
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 2: Known AES InvMixColumn vector");
        $display("--------------------------------------------");

        data_in = 32'h8e4da1bc;

        #1;

        if (dec_out !== 32'hdb135345) begin

            $display("FAIL: Mix_One_Column_Dec");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", dec_out);
            $display("Expected = db135345");

            errors = errors + 1;

        end
        else begin
            $display("PASS: 8e4da1bc -> db135345");
        end


        // ========================================================
        // TEST 3
        //
        // Another standard AES MixColumns example:
        //
        // f2
        // 0a
        // 22
        // 5c
        //
        // becomes:
        //
        // 9f
        // dc
        // 58
        // 9d
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 3: Second known AES MixColumn vector");
        $display("--------------------------------------------");

        data_in = 32'hf20a225c;

        #1;

        if (enc_out !== 32'h9fdc589d) begin

            $display("FAIL: Second MixColumn vector");
            $display("Input    = %h", data_in);
            $display("Actual   = %h", enc_out);
            $display("Expected = 9fdc589d");

            errors = errors + 1;

        end
        else begin
            $display("PASS: f20a225c -> 9fdc589d");
        end


        // ========================================================
        // TEST 4
        // Another known example
        //
        // 01 01 01 01 -> 01 01 01 01
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 4: Equal-byte column");
        $display("--------------------------------------------");

        data_in = 32'h01010101;

        #1;

        if (enc_out !== 32'h01010101) begin

            $display("FAIL: Equal-byte column");
            $display("Actual   = %h", enc_out);
            $display("Expected = 01010101");

            errors = errors + 1;

        end
        else begin
            $display("PASS: 01010101 -> 01010101");
        end


        // ========================================================
        // TEST 5
        // Zero column
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 5: Zero column");
        $display("--------------------------------------------");

        data_in = 32'h00000000;

        #1;

        if (enc_out !== 32'h00000000) begin

            $display("FAIL: Zero column");
            $display("Actual   = %h", enc_out);
            $display("Expected = 00000000");

            errors = errors + 1;

        end
        else begin
            $display("PASS: Zero column");
        end


        // ========================================================
        // TEST 6
        // Inverse property
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 6: MixColumn inverse property");
        $display("--------------------------------------------");

        data_in = 32'h01234567;

        #1;

        if (inverse_out !== data_in) begin

            $display("FAIL: InvMixColumn(MixColumn(x)) != x");
            $display("Input   = %h", data_in);
            $display("Mixed   = %h", enc_out);
            $display("Inverse = %h", inverse_out);

            errors = errors + 1;

        end
        else begin
            $display("PASS: InvMixColumn(MixColumn(x)) = x");
        end


        // ========================================================
        // TEST 7
        // Another inverse property test
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("TEST 7: Second inverse property test");
        $display("--------------------------------------------");

        data_in = 32'hdeadbeef;

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

            $display("MIX_ONE_COLUMN TEST PASSED");
            $display("All tests completed successfully.");

        end
        else begin

            $display("MIX_ONE_COLUMN TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
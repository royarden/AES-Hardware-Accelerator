`timescale 1ns/1ps

module Key_Expansion_192_Enc_tb;

    reg  [191:0] key_in;
    reg  [2:0]   current_round;
    wire [191:0] key_out;

    integer errors;


    // ============================================================
    // DUT
    // ============================================================

    Key_Expansion_192_Enc DUT (
        .Key_Expansion_Enc_key_in        (key_in),
        .Key_Expansion_Enc_Current_round (current_round),
        .Key_Expansion_Enc_key_out       (key_out)
    );


    // ============================================================
    // Check one 192-bit expansion step
    // ============================================================

    task check_round;

        input [2:0]   round;
        input [191:0] input_key;
        input [191:0] expected_key;

        begin

            current_round = round;
            key_in        = input_key;

            #1;

            if (key_out !== expected_key) begin

                $display("FAIL: Expansion %0d", round);
                $display("Input    = %h", input_key);
                $display("Actual   = %h", key_out);
                $display("Expected = %h", expected_key);

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: Expansion %0d -> %h",
                    round,
                    key_out
                );

            end

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================

    initial begin

        errors        = 0;
        key_in        = 192'h0;
        current_round = 3'd0;

        #10;

        $display("============================================");
        $display("AES-192 KEY EXPANSION TEST");
        $display("============================================");
        $display("");


        // ========================================================
        // Initial AES-192 key = W0..W5
        //
        // W0 = 00010203
        // W1 = 04050607
        // W2 = 08090a0b
        // W3 = 0c0d0e0f
        // W4 = 10111213
        // W5 = 14151617
        //
        // Expansion 0 produces W6..W11
        // ========================================================

        check_round(
            3'd0,

            192'h000102030405060708090a0b0c0d0e0f1011121314151617,

            192'h5846f2f95c43f4fe544afef55847f0fa4856e2e95c43f4fe
        );


        // ========================================================
        // Expansion 1
        // W6..W11 -> W12..W17
        // ========================================================

        check_round(
            3'd1,

            192'h5846f2f95c43f4fe544afef55847f0fa4856e2e95c43f4fe,

            192'h40f949b31cbabd4d48f043b810b7b34258e151ab04a2a555
        );


        // ========================================================
        // Expansion 2
        // W12..W17 -> W18..W23
        // ========================================================

        check_round(
            3'd2,

            192'h40f949b31cbabd4d48f043b810b7b34258e151ab04a2a555,

            192'h7effb5416245080c2ab54bb43a02f8f662e3a95d66410c08
        );


        // ========================================================
        // Expansion 3
        // W18..W23 -> W24..W29
        // ========================================================

        check_round(
            3'd3,

            192'h7effb5416245080c2ab54bb43a02f8f662e3a95d66410c08,

            192'hf501857297448d7ebdf1c6ca87f33e3ce510976183519b69
        );


        // ========================================================
        // Expansion 4
        // W24..W29 -> W30..W35
        // ========================================================

        check_round(
            3'd4,

            192'hf501857297448d7ebdf1c6ca87f33e3ce510976183519b69,

            192'h34157c9ea351f1e01ea0372a995309167c439e77ff12051e
        );


        // ========================================================
        // Expansion 5
        // W30..W35 -> W36..W41
        // ========================================================

        check_round(
            3'd5,

            192'h34157c9ea351f1e01ea0372a995309167c439e77ff12051e,

            192'hdd7e0e887e2fff68608fc842f9dcc154859f5f237a8d5a3d
        );


        // ========================================================
        // Expansion 6
        // W36..W41 -> W42..W47
        // ========================================================

        check_round(
            3'd6,

            192'hdd7e0e887e2fff68608fc842f9dcc154859f5f237a8d5a3d,

            192'hc0c02952beefd63ade601e7827bcdf2ca223800fd8aeda32
        );


        // ========================================================
        // Expansion 7
        // W42..W47 -> W48..W53
        //
        // AES-192 itself only needs through W51.
        // W52/W53 are still checked here because this module
        // produces a complete 192-bit group.
        // ========================================================

        check_round(
            3'd7,

            192'hc0c02952beefd63ade601e7827bcdf2ca223800fd8aeda32,

            192'ha4970a331a78dc09c418c271e3a41d5d41879d5299294760
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("KEY_EXPANSION_192 TEST PASSED");
            $display("All 8 expansion groups are correct.");

        end
        else begin

            $display("KEY_EXPANSION_192 TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
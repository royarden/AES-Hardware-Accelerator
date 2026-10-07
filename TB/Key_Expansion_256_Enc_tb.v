`timescale 1ns/1ps

module Key_Expansion_256_Enc_tb;

    reg  [255:0] key_in;
    reg  [2:0]   current_round;
    wire [255:0] key_out;

    integer errors;


    // ============================================================
    // DUT
    // ============================================================

    Key_Expansion_256_Enc DUT (
        .Key_Expansion_Enc_key_in        (key_in),
        .Key_Expansion_Enc_Current_round (current_round),
        .Key_Expansion_Enc_key_out       (key_out)
    );


    // ============================================================
    // Check one 256-bit expansion group
    // ============================================================

    task check_round;

        input [2:0]   round;
        input [255:0] input_key;
        input [255:0] expected_key;

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
        key_in        = 256'h0;
        current_round = 3'd0;

        #10;

        $display("============================================");
        $display("AES-256 KEY EXPANSION TEST");
        $display("============================================");
        $display("");


        // ========================================================
        // Expansion 0
        // W0..W7 -> W8..W15
        // ========================================================

        check_round(
            3'd0,
            256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f,
            256'ha573c29fa176c498a97fce93a572c09c1651a8cd0244beda1a5da4c10640bade
        );


        // ========================================================
        // Expansion 1
        // W8..W15 -> W16..W23
        // ========================================================

        check_round(
            3'd1,
            256'ha573c29fa176c498a97fce93a572c09c1651a8cd0244beda1a5da4c10640bade,
            256'hae87dff00ff11b68a68ed5fb03fc15676de1f1486fa54f9275f8eb5373b8518d
        );


        // ========================================================
        // Expansion 2
        // W16..W23 -> W24..W31
        // ========================================================

        check_round(
            3'd2,
            256'hae87dff00ff11b68a68ed5fb03fc15676de1f1486fa54f9275f8eb5373b8518d,
            256'hc656827fc9a799176f294cec6cd5598b3de23a75524775e727bf9eb45407cf39
        );


        // ========================================================
        // Expansion 3
        // W24..W31 -> W32..W39
        // ========================================================

        check_round(
            3'd3,
            256'hc656827fc9a799176f294cec6cd5598b3de23a75524775e727bf9eb45407cf39,
            256'h0bdc905fc27b0948ad5245a4c1871c2f45f5a66017b2d387300d4d33640a820a
        );


        // ========================================================
        // Expansion 4
        // W32..W39 -> W40..W47
        // ========================================================

        check_round(
            3'd4,
            256'h0bdc905fc27b0948ad5245a4c1871c2f45f5a66017b2d387300d4d33640a820a,
            256'h7ccff71cbeb4fe5413e6bbf0d261a7dff01afafee7a82979d7a5644ab3afe640
        );


        // ========================================================
        // Expansion 5
        // W40..W47 -> W48..W55
        // ========================================================

        check_round(
            3'd5,
            256'h7ccff71cbeb4fe5413e6bbf0d261a7dff01afafee7a82979d7a5644ab3afe640,
            256'h2541fe719bf500258813bbd55a721c0a4e5a6699a9f24fe07e572baacdf8cdea
        );


        // ========================================================
        // Expansion 6
        // W48..W55 -> W56..W63
        //
        // AES-256 requires W56..W59.
        // W60..W63 are additional outputs of this block.
        // ========================================================

        check_round(
            3'd6,
            256'h2541fe719bf500258813bbd55a721c0a4e5a6699a9f24fe07e572baacdf8cdea,
            256'h24fc79ccbf0979e9371ac23c6d68de36721f7b9cdbed347ca5ba1fd66842d23c
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("KEY_EXPANSION_256 TEST PASSED");
            $display("All 7 expansion groups are correct.");

        end
        else begin

            $display("KEY_EXPANSION_256 TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
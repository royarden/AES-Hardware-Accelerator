`timescale 1ns/1ps

module Key_Expansion_128_Enc_tb;

    reg  [127:0] key_in;
    reg  [3:0]   current_round;
    wire [127:0] key_out;

    integer errors;


    // ============================================================
    // DUT
    // ============================================================

    Key_Expansion_128_Enc DUT (
        .Key_Expansion_Enc_key_in       (key_in),
        .Key_Expansion_Enc_Current_round(current_round),
        .Key_Expansion_Enc_key_out      (key_out)
    );


    // ============================================================
    // Test task
    // ============================================================

    task check_round;

        input [3:0]   round;
        input [127:0] input_key;
        input [127:0] expected_key;

        begin

            current_round = round;
            key_in        = input_key;

            #1;

            if (key_out !== expected_key) begin

                $display("FAIL: Round %0d", round);
                $display("Input key = %h", input_key);
                $display("Actual    = %h", key_out);
                $display("Expected  = %h", expected_key);

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: Round %0d -> %h",
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
        key_in        = 128'h0;
        current_round = 4'h0;

        #10;

        $display("============================================");
        $display("AES-128 KEY EXPANSION TEST");
        $display("============================================");
        $display("");


        // ========================================================
        // K0 -> K1
        // ========================================================

        check_round(
            4'd0,
            128'h000102030405060708090a0b0c0d0e0f,
            128'hd6aa74fdd2af72fadaa678f1d6ab76fe
        );


        // ========================================================
        // K1 -> K2
        // ========================================================

        check_round(
            4'd1,
            128'hd6aa74fdd2af72fadaa678f1d6ab76fe,
            128'hb692cf0b643dbdf1be9bc5006830b3fe
        );


        // ========================================================
        // K2 -> K3
        // ========================================================

        check_round(
            4'd2,
            128'hb692cf0b643dbdf1be9bc5006830b3fe,
            128'hb6ff744ed2c2c9bf6c590cbf0469bf41
        );


        // ========================================================
        // K3 -> K4
        // ========================================================

        check_round(
            4'd3,
            128'hb6ff744ed2c2c9bf6c590cbf0469bf41,
            128'h47f7f7bc95353e03f96c32bcfd058dfd
        );


        // ========================================================
        // K4 -> K5
        // ========================================================

        check_round(
            4'd4,
            128'h47f7f7bc95353e03f96c32bcfd058dfd,
            128'h3caaa3e8a99f9deb50f3af57adf622aa
        );


        // ========================================================
        // K5 -> K6
        // ========================================================

        check_round(
            4'd5,
            128'h3caaa3e8a99f9deb50f3af57adf622aa,
            128'h5e390f7df7a69296a7553dc10aa31f6b
        );


        // ========================================================
        // K6 -> K7
        // ========================================================

        check_round(
            4'd6,
            128'h5e390f7df7a69296a7553dc10aa31f6b,
            128'h14f9701ae35fe28c440adf4d4ea9c026
        );


        // ========================================================
        // K7 -> K8
        // ========================================================

        check_round(
            4'd7,
            128'h14f9701ae35fe28c440adf4d4ea9c026,
            128'h47438735a41c65b9e016baf4aebf7ad2
        );


        // ========================================================
        // K8 -> K9
        // ========================================================

        check_round(
            4'd8,
            128'h47438735a41c65b9e016baf4aebf7ad2,
            128'h549932d1f08557681093ed9cbe2c974e
        );


        // ========================================================
        // K9 -> K10
        // ========================================================

        check_round(
            4'd9,
            128'h549932d1f08557681093ed9cbe2c974e,
            128'h13111d7fe3944a17f307a78b4d2b30c5
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("KEY_EXPANSION_128 TEST PASSED");
            $display("All 10 round-key expansions are correct.");

        end
        else begin

            $display("KEY_EXPANSION_128 TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
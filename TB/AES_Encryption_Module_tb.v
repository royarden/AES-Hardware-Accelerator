`timescale 1ns/1ps

module AES_Encryption_Module_tb;

    localparam Enc_128 = 2'd1;
    localparam Enc_192 = 2'd2;
    localparam Enc_256 = 2'd3;

    reg clk;
    reg rst_n;

    reg [1:0]   AES_Enc_mode;
    reg         AES_Enc_valid;
    reg [127:0] AES_Enc_data_in;

    reg [127:0] AES_Enc_round_key;
    reg         AES_Enc_round_key_valid;

    wire [3:0]   AES_Enc_key_round;
    wire [127:0] AES_Enc_data_out;
    wire         AES_Enc_busy;
    wire         AES_Enc_done;

    integer errors;
    integer timeout;

    reg [127:0] round_keys [0:14];


    // ============================================================
    // DUT
    // ============================================================

    AES_Encryption_Module DUT (
        .clk                     (clk),
        .rst_n                   (rst_n),
        .AES_Enc_mode            (AES_Enc_mode),
        .AES_Enc_valid           (AES_Enc_valid),
        .AES_Enc_data_in         (AES_Enc_data_in),
        .AES_Enc_round_key       (AES_Enc_round_key),
        .AES_Enc_round_key_valid (AES_Enc_round_key_valid),

        .AES_Enc_key_round       (AES_Enc_key_round),
        .AES_Enc_data_out        (AES_Enc_data_out),
        .AES_Enc_busy            (AES_Enc_busy),
        .AES_Enc_done            (AES_Enc_done)
    );


    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // Key responder
    //
    // Models the behavior seen by AES_Encryption_Module after
    // Key_Preparation has completed.
    // ============================================================

    always @(*) begin

        AES_Enc_round_key       = 128'h0;
        AES_Enc_round_key_valid = 1'b0;

        if (AES_Enc_busy) begin

            AES_Enc_round_key       = round_keys[AES_Enc_key_round];
            AES_Enc_round_key_valid = 1'b1;

        end

    end


    // ============================================================
    // Start encryption
    // ============================================================

    task start_encryption;

        input [1:0]   mode;
        input [127:0] plaintext;

        begin

            @(negedge clk);

            AES_Enc_mode    = mode;
            AES_Enc_data_in = plaintext;
            AES_Enc_valid   = 1'b1;

            @(negedge clk);

            AES_Enc_valid = 1'b0;

        end

    endtask


    // ============================================================
    // Wait for DONE and compare result
    // ============================================================

    task wait_and_check;

        input [127:0] expected_ciphertext;

        begin

            timeout = 0;

            while ((AES_Enc_done !== 1'b1) &&
                   (timeout < 40)) begin

                @(negedge clk);
                timeout = timeout + 1;

            end

            if (AES_Enc_done !== 1'b1) begin

                $display("FAIL: Timeout waiting for AES_Enc_done");
                errors = errors + 1;

            end
            else if (AES_Enc_data_out !== expected_ciphertext) begin

                $display("FAIL: Ciphertext mismatch");
                $display("Actual   = %h", AES_Enc_data_out);
                $display("Expected = %h", expected_ciphertext);

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: Ciphertext = %h",
                    AES_Enc_data_out
                );

                $display(
                    "PASS: AES_Enc_done asserted after %0d cycles",
                    timeout
                );

            end

            // Allow DUT to return from DONE to IDLE
            @(negedge clk);

        end

    endtask


    // ============================================================
    // Load AES-128 round keys
    // ============================================================

    task load_keys_128;

        begin

            round_keys[0]  = 128'h000102030405060708090a0b0c0d0e0f;
            round_keys[1]  = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
            round_keys[2]  = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
            round_keys[3]  = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
            round_keys[4]  = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
            round_keys[5]  = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
            round_keys[6]  = 128'h5e390f7df7a69296a7553dc10aa31f6b;
            round_keys[7]  = 128'h14f9701ae35fe28c440adf4d4ea9c026;
            round_keys[8]  = 128'h47438735a41c65b9e016baf4aebf7ad2;
            round_keys[9]  = 128'h549932d1f08557681093ed9cbe2c974e;
            round_keys[10] = 128'h13111d7fe3944a17f307a78b4d2b30c5;

        end

    endtask


    // ============================================================
    // Load AES-192 round keys
    // ============================================================

    task load_keys_192;

        begin

            round_keys[0]  = 128'h000102030405060708090a0b0c0d0e0f;
            round_keys[1]  = 128'h10111213141516175846f2f95c43f4fe;
            round_keys[2]  = 128'h544afef55847f0fa4856e2e95c43f4fe;
            round_keys[3]  = 128'h40f949b31cbabd4d48f043b810b7b342;
            round_keys[4]  = 128'h58e151ab04a2a5557effb5416245080c;
            round_keys[5]  = 128'h2ab54bb43a02f8f662e3a95d66410c08;
            round_keys[6]  = 128'hf501857297448d7ebdf1c6ca87f33e3c;
            round_keys[7]  = 128'he510976183519b6934157c9ea351f1e0;
            round_keys[8]  = 128'h1ea0372a995309167c439e77ff12051e;
            round_keys[9]  = 128'hdd7e0e887e2fff68608fc842f9dcc154;
            round_keys[10] = 128'h859f5f237a8d5a3dc0c02952beefd63a;
            round_keys[11] = 128'hde601e7827bcdf2ca223800fd8aeda32;
            round_keys[12] = 128'ha4970a331a78dc09c418c271e3a41d5d;

        end

    endtask


    // ============================================================
    // Load AES-256 round keys
    // ============================================================

    task load_keys_256;

        begin

            round_keys[0]  = 128'h000102030405060708090a0b0c0d0e0f;
            round_keys[1]  = 128'h101112131415161718191a1b1c1d1e1f;
            round_keys[2]  = 128'ha573c29fa176c498a97fce93a572c09c;
            round_keys[3]  = 128'h1651a8cd0244beda1a5da4c10640bade;
            round_keys[4]  = 128'hae87dff00ff11b68a68ed5fb03fc1567;
            round_keys[5]  = 128'h6de1f1486fa54f9275f8eb5373b8518d;
            round_keys[6]  = 128'hc656827fc9a799176f294cec6cd5598b;
            round_keys[7]  = 128'h3de23a75524775e727bf9eb45407cf39;
            round_keys[8]  = 128'h0bdc905fc27b0948ad5245a4c1871c2f;
            round_keys[9]  = 128'h45f5a66017b2d387300d4d33640a820a;
            round_keys[10] = 128'h7ccff71cbeb4fe5413e6bbf0d261a7df;
            round_keys[11] = 128'hf01afafee7a82979d7a5644ab3afe640;
            round_keys[12] = 128'h2541fe719bf500258813bbd55a721c0a;
            round_keys[13] = 128'h4e5a6699a9f24fe07e572baacdf8cdea;
            round_keys[14] = 128'h24fc79ccbf0979e9371ac23c6d68de36;

        end

    endtask


    // ============================================================
    // Main
    // ============================================================

    initial begin

        errors          = 0;

        rst_n           = 1'b0;
        AES_Enc_mode    = 2'd0;
        AES_Enc_valid   = 1'b0;
        AES_Enc_data_in = 128'h0;

        // Initialize key array
        round_keys[0]  = 128'h0;
        round_keys[1]  = 128'h0;
        round_keys[2]  = 128'h0;
        round_keys[3]  = 128'h0;
        round_keys[4]  = 128'h0;
        round_keys[5]  = 128'h0;
        round_keys[6]  = 128'h0;
        round_keys[7]  = 128'h0;
        round_keys[8]  = 128'h0;
        round_keys[9]  = 128'h0;
        round_keys[10] = 128'h0;
        round_keys[11] = 128'h0;
        round_keys[12] = 128'h0;
        round_keys[13] = 128'h0;
        round_keys[14] = 128'h0;


        // ========================================================
        // RESET
        // ========================================================

        repeat (2)
            @(negedge clk);

        rst_n = 1'b1;

        @(negedge clk);


        // ========================================================
        // TEST 1: AES-128
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 1: AES-128 ENCRYPTION");
        $display("============================================");

        load_keys_128();

        start_encryption(
            Enc_128,
            128'h00112233445566778899aabbccddeeff
        );

        wait_and_check(
            128'h69c4e0d86a7b0430d8cdb78070b4c55a
        );


        // ========================================================
        // TEST 2: AES-192
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 2: AES-192 ENCRYPTION");
        $display("============================================");

        load_keys_192();

        start_encryption(
            Enc_192,
            128'h00112233445566778899aabbccddeeff
        );

        wait_and_check(
            128'hdda97ca4864cdfe06eaf70a0ec0d7191
        );


        // ========================================================
        // TEST 3: AES-256
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 3: AES-256 ENCRYPTION");
        $display("============================================");

        load_keys_256();

        start_encryption(
            Enc_256,
            128'h00112233445566778899aabbccddeeff
        );

        wait_and_check(
            128'h8ea2b7ca516745bfeafc49904b496089
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("AES_ENCRYPTION_MODULE TEST PASSED");
            $display("AES-128 / AES-192 / AES-256 all passed.");

        end
        else begin

            $display("AES_ENCRYPTION_MODULE TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
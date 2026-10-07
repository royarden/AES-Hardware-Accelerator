`timescale 1ns/1ps

module Key_Preparation_tb;

    localparam Mode_128 = 2'd1;
    localparam Mode_192 = 2'd2;
    localparam Mode_256 = 2'd3;

    reg clk;
    reg rst_n;
    reg start;

    reg [1:0]   AES_mode;
    reg [3:0]   key_round;
    reg [255:0] key_in;

    wire         out_valid;
    wire         ready;
    wire [127:0] key_out;

    integer errors;
    integer r;

    reg [127:0] expected_128 [0:10];
    reg [127:0] expected_192 [0:12];
    reg [127:0] expected_256 [0:14];


    // ============================================================
    // DUT
    // ============================================================

    Key_Preparation DUT (
        .clk                       (clk),
        .rst_n                     (rst_n),
        .start                     (start),
        .AES_mode                  (AES_mode),
        .key_round                 (key_round),
        .Key_Preparation_key_in    (key_in),
        .key_preparation_out_valid (out_valid),
        .key_preparation_ready     (ready),
        .Key_Preparation_key_out   (key_out)
    );


    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // Start one key preparation
    // ============================================================

    task start_key_preparation;

        input [1:0]   mode;
        input [255:0] key;

        begin

            @(negedge clk);

            AES_mode = mode;
            key_in   = key;
            start    = 1'b1;

            @(negedge clk);

            start = 1'b0;

        end

    endtask


    // ============================================================
    // Wait until ready
    // ============================================================

    task wait_for_ready;

        integer timeout;

        begin

            timeout = 0;

            while ((ready !== 1'b1) && (timeout < 40)) begin
                @(negedge clk);
                timeout = timeout + 1;
            end

            if (ready !== 1'b1) begin

                $display("FAIL: Timeout waiting for key_preparation_ready");
                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: key_preparation_ready asserted after %0d cycles",
                    timeout
                );

            end

        end

    endtask


    // ============================================================
    // Check one round key
    // ============================================================

    task check_key;

        input [3:0]   round_number;
        input [127:0] expected;

        begin

            key_round = round_number;

            #1;

            if (out_valid !== 1'b1) begin

                $display(
                    "FAIL: Round %0d - out_valid is not asserted",
                    round_number
                );

                errors = errors + 1;

            end
            else if (key_out !== expected) begin

                $display("FAIL: Round key %0d", round_number);
                $display("Actual   = %h", key_out);
                $display("Expected = %h", expected);

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: K%0d = %h",
                    round_number,
                    key_out
                );

            end

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================

    initial begin

        errors    = 0;
        rst_n     = 1'b0;
        start     = 1'b0;
        AES_mode  = 2'd0;
        key_round = 4'd0;
        key_in    = 256'd0;


        // ========================================================
        // Expected AES-128 round keys
        // ========================================================

        expected_128[0]  = 128'h000102030405060708090a0b0c0d0e0f;
        expected_128[1]  = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
        expected_128[2]  = 128'hb692cf0b643dbdf1be9bc5006830b3fe;
        expected_128[3]  = 128'hb6ff744ed2c2c9bf6c590cbf0469bf41;
        expected_128[4]  = 128'h47f7f7bc95353e03f96c32bcfd058dfd;
        expected_128[5]  = 128'h3caaa3e8a99f9deb50f3af57adf622aa;
        expected_128[6]  = 128'h5e390f7df7a69296a7553dc10aa31f6b;
        expected_128[7]  = 128'h14f9701ae35fe28c440adf4d4ea9c026;
        expected_128[8]  = 128'h47438735a41c65b9e016baf4aebf7ad2;
        expected_128[9]  = 128'h549932d1f08557681093ed9cbe2c974e;
        expected_128[10] = 128'h13111d7fe3944a17f307a78b4d2b30c5;


        // ========================================================
        // Expected AES-192 round keys
        // ========================================================

        expected_192[0]  = 128'h000102030405060708090a0b0c0d0e0f;
        expected_192[1]  = 128'h10111213141516175846f2f95c43f4fe;
        expected_192[2]  = 128'h544afef55847f0fa4856e2e95c43f4fe;
        expected_192[3]  = 128'h40f949b31cbabd4d48f043b810b7b342;
        expected_192[4]  = 128'h58e151ab04a2a5557effb5416245080c;
        expected_192[5]  = 128'h2ab54bb43a02f8f662e3a95d66410c08;
        expected_192[6]  = 128'hf501857297448d7ebdf1c6ca87f33e3c;
        expected_192[7]  = 128'he510976183519b6934157c9ea351f1e0;
        expected_192[8]  = 128'h1ea0372a995309167c439e77ff12051e;
        expected_192[9]  = 128'hdd7e0e887e2fff68608fc842f9dcc154;
        expected_192[10] = 128'h859f5f237a8d5a3dc0c02952beefd63a;
        expected_192[11] = 128'hde601e7827bcdf2ca223800fd8aeda32;
        expected_192[12] = 128'ha4970a331a78dc09c418c271e3a41d5d;


        // ========================================================
        // Expected AES-256 round keys
        // ========================================================

        expected_256[0]  = 128'h000102030405060708090a0b0c0d0e0f;
        expected_256[1]  = 128'h101112131415161718191a1b1c1d1e1f;

        expected_256[2]  = 128'ha573c29fa176c498a97fce93a572c09c;
        expected_256[3]  = 128'h1651a8cd0244beda1a5da4c10640bade;

        expected_256[4]  = 128'hae87dff00ff11b68a68ed5fb03fc1567;
        expected_256[5]  = 128'h6de1f1486fa54f9275f8eb5373b8518d;

        expected_256[6]  = 128'hc656827fc9a799176f294cec6cd5598b;
        expected_256[7]  = 128'h3de23a75524775e727bf9eb45407cf39;

        expected_256[8]  = 128'h0bdc905fc27b0948ad5245a4c1871c2f;
        expected_256[9]  = 128'h45f5a66017b2d387300d4d33640a820a;

        expected_256[10] = 128'h7ccff71cbeb4fe5413e6bbf0d261a7df;
        expected_256[11] = 128'hf01afafee7a82979d7a5644ab3afe640;

        expected_256[12] = 128'h2541fe719bf500258813bbd55a721c0a;
        expected_256[13] = 128'h4e5a6699a9f24fe07e572baacdf8cdea;

        expected_256[14] = 128'h24fc79ccbf0979e9371ac23c6d68de36;


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
        $display("TEST 1: AES-128 KEY PREPARATION");
        $display("============================================");

        start_key_preparation(
            Mode_128,
            256'h00000000000000000000000000000000000102030405060708090a0b0c0d0e0f
        );

        wait_for_ready();

        for (r = 0; r <= 10; r = r + 1)
            check_key(r, expected_128[r]);


        // Invalid round for AES-128
        key_round = 4'd11;
        #1;

        if (out_valid !== 1'b0) begin
            $display("FAIL: AES-128 K11 should be invalid");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AES-128 K11 correctly rejected");
        end


        // ========================================================
        // TEST 2: AES-192
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 2: AES-192 KEY PREPARATION");
        $display("============================================");

        start_key_preparation(
            Mode_192,
            256'h0000000000000000000102030405060708090a0b0c0d0e0f1011121314151617
        );

        wait_for_ready();

        for (r = 0; r <= 12; r = r + 1)
            check_key(r, expected_192[r]);


        // Invalid round for AES-192
        key_round = 4'd13;
        #1;

        if (out_valid !== 1'b0) begin
            $display("FAIL: AES-192 K13 should be invalid");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AES-192 K13 correctly rejected");
        end


        // ========================================================
        // TEST 3: AES-256
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 3: AES-256 KEY PREPARATION");
        $display("============================================");

        start_key_preparation(
            Mode_256,
            256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
        );

        wait_for_ready();

        for (r = 0; r <= 14; r = r + 1)
            check_key(r, expected_256[r]);


        // Invalid round for AES-256
        key_round = 4'd15;
        #1;

        if (out_valid !== 1'b0) begin
            $display("FAIL: AES-256 K15 should be invalid");
            errors = errors + 1;
        end
        else begin
            $display("PASS: AES-256 K15 correctly rejected");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("KEY_PREPARATION TEST PASSED");
            $display("AES-128 / AES-192 / AES-256 all passed.");

        end
        else begin

            $display("KEY_PREPARATION TEST FAILED");
            $display("Number of errors: %0d", errors);

        end

        $display("============================================");

        $stop;

    end

endmodule
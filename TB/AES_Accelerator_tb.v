`timescale 1ns/1ps

module AES_Accelerator_tb;

    // ============================================================
    // Constants
    // ============================================================

    localparam ENCRYPT = 1'b0;
    localparam DECRYPT = 1'b1;

    localparam AES_128 = 2'd1;
    localparam AES_192 = 2'd2;
    localparam AES_256 = 2'd3;


    // ============================================================
    // DUT signals
    // ============================================================

    reg clk;
    reg rst_n;
    reg start;
    reg operation;
    reg [1:0] AES_mode;

    reg [127:0] AES_data_in;
    reg [255:0] AES_key_in;

    wire [127:0] AES_data_out;
    wire AES_busy;
    wire AES_done;


    // ============================================================
    // Test variables
    // ============================================================

    integer errors;
    integer timeout;


    // ============================================================
    // DUT
    // ============================================================

    AES_Accelerator DUT (
        .clk          (clk),
        .rst_n        (rst_n),
        .start        (start),
        .operation    (operation),
        .AES_mode     (AES_mode),

        .AES_data_in  (AES_data_in),
        .AES_key_in   (AES_key_in),

        .AES_data_out (AES_data_out),
        .AES_busy     (AES_busy),
        .AES_done     (AES_done)
    );


    // ============================================================
    // Clock
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // Start operation
    //
    // key must already be correctly aligned:
    //
    // AES-128 -> key in [127:0]
    // AES-192 -> key in [191:0]
    // AES-256 -> key in [255:0]
    // ============================================================

    task start_operation;

        input op;
        input [1:0] mode;
        input [127:0] data;
        input [255:0] key;

        begin

            @(negedge clk);

            operation   = op;
            AES_mode    = mode;
            AES_data_in = data;
            AES_key_in  = key;
            start       = 1'b1;

            @(negedge clk);

            start = 1'b0;

        end

    endtask


    // ============================================================
    // Wait for AES_done and check result
    // ============================================================

    task wait_and_check;

        input [127:0] expected_result;

        begin

            timeout = 0;

            while ((AES_done !== 1'b1) &&
                   (timeout < 100)) begin

                @(negedge clk);
                timeout = timeout + 1;

            end

            if (AES_done !== 1'b1) begin

                $display("FAIL: Timeout waiting for AES_done");
                errors = errors + 1;

            end
            else if (AES_data_out !== expected_result) begin

                $display("FAIL: Output mismatch");
                $display("Actual   = %h", AES_data_out);
                $display("Expected = %h", expected_result);

                errors = errors + 1;

            end
            else begin

                $display("PASS: Output = %h", AES_data_out);
                $display(
                    "PASS: AES_done asserted after %0d cycles",
                    timeout
                );

            end

            // DONE lasts for one cycle.
            // Allow DUT to return to IDLE before next test.
            @(negedge clk);

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================

    initial begin

        errors = 0;

        rst_n       = 1'b0;
        start       = 1'b0;
        operation   = ENCRYPT;
        AES_mode    = 2'd0;
        AES_data_in = 128'h0;
        AES_key_in  = 256'h0;


        // ========================================================
        // RESET
        // ========================================================

        repeat (2)
            @(negedge clk);

        rst_n = 1'b1;

        @(negedge clk);


        // ========================================================
        // TEST 1: AES-128 ENCRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 1: AES-128 ENCRYPTION");
        $display("============================================");

        start_operation(
            ENCRYPT,
            AES_128,
            128'h00112233445566778899aabbccddeeff,
            256'h00000000000000000000000000000000000102030405060708090a0b0c0d0e0f
        );

        wait_and_check(
            128'h69c4e0d86a7b0430d8cdb78070b4c55a
        );


        // ========================================================
        // TEST 2: AES-128 DECRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 2: AES-128 DECRYPTION");
        $display("============================================");

        start_operation(
            DECRYPT,
            AES_128,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            256'h00000000000000000000000000000000000102030405060708090a0b0c0d0e0f
        );

        wait_and_check(
            128'h00112233445566778899aabbccddeeff
        );


        // ========================================================
        // TEST 3: AES-192 ENCRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 3: AES-192 ENCRYPTION");
        $display("============================================");

        start_operation(
            ENCRYPT,
            AES_192,
            128'h00112233445566778899aabbccddeeff,
            256'h0000000000000000000102030405060708090a0b0c0d0e0f1011121314151617
        );

        wait_and_check(
            128'hdda97ca4864cdfe06eaf70a0ec0d7191
        );


        // ========================================================
        // TEST 4: AES-192 DECRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 4: AES-192 DECRYPTION");
        $display("============================================");

        start_operation(
            DECRYPT,
            AES_192,
            128'hdda97ca4864cdfe06eaf70a0ec0d7191,
            256'h0000000000000000000102030405060708090a0b0c0d0e0f1011121314151617
        );

        wait_and_check(
            128'h00112233445566778899aabbccddeeff
        );


        // ========================================================
        // TEST 5: AES-256 ENCRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 5: AES-256 ENCRYPTION");
        $display("============================================");

        start_operation(
            ENCRYPT,
            AES_256,
            128'h00112233445566778899aabbccddeeff,
            256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
        );

        wait_and_check(
            128'h8ea2b7ca516745bfeafc49904b496089
        );


        // ========================================================
        // TEST 6: AES-256 DECRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("TEST 6: AES-256 DECRYPTION");
        $display("============================================");

        start_operation(
            DECRYPT,
            AES_256,
            128'h8ea2b7ca516745bfeafc49904b496089,
            256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
        );

        wait_and_check(
            128'h00112233445566778899aabbccddeeff
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("AES_ACCELERATOR TEST PASSED");
            $display(
                "AES-128 / AES-192 / AES-256"
            );
            $display(
                "Encryption + Decryption all passed."
            );

        end
        else begin

            $display("AES_ACCELERATOR TEST FAILED");
            $display(
                "Number of errors: %0d",
                errors
            );

        end

        $display("============================================");

        $stop;

    end

endmodule
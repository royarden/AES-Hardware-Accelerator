# AES Hardware Accelerator

A synthesizable Verilog hardware accelerator implementing AES-128, AES-192, and AES-256 encryption and decryption.

The project provides a unified RTL interface for key preparation, encryption, and decryption, together with a self-checking verification environment and automated ModelSim regression flow.

## Highlights

- AES-128, AES-192, and AES-256 support
- Encryption and decryption
- Synthesizable Verilog RTL
- Unified top-level accelerator interface
- AES key expansion for 128-, 192-, and 256-bit keys
- Forward round keys reused in reverse order for decryption
- Self-checking verification environment
- Standard AES known-answer tests
- 13 Verilog testbenches
- Automated ModelSim regression flow
- Clean separation between reusable RTL, verification, documentation, and simulation scripts

## Repository Structure

```text
AES_Hardware_Accelerator/
├── RTL/        # Synthesizable Verilog RTL
├── TB/         # Self-checking testbenches
├── DOCS/       # Architecture and verification documentation
├── Scripts/    # ModelSim simulation and regression scripts
├── LICENSE
├── README.md
└── .gitignore
```

## Documentation

- [Architecture](DOCS/architecture.md) — RTL architecture, datapath organization, key preparation, and top-level interface.
- [Verification](DOCS/verification.md) — Testbench coverage, known-answer tests, regression flow, and observed simulation latency.

## Architecture Overview

The accelerator is organized around three primary functional blocks:

```text
                    +----------------------+
AES_key_in -------->|                      |
AES_mode ---------->|   Key_Preparation    |---- Round Keys
                    |                      |         |
                    +----------------------+         |
                                                     |
                                                     v
AES_data_in ---> +-----------------------+     +-----------------------+
                 |                       |     |                       |
                 | AES_Encryption_Module |     | AES_Decryption_Module |
                 |                       |     |                       |
                 +-----------------------+     +-----------------------+
                           |                           |
                           +-------------+-------------+
                                         |
                                         v
                                  AES_data_out
```

### Key Preparation

`Key_Preparation` generates and stores the AES round keys using dedicated key-expansion logic for each supported key size:

- `Key_Expansion_128_Enc`
- `Key_Expansion_192_Enc`
- `Key_Expansion_256_Enc`

Forward-generated round keys are reused in reverse order during decryption, so a separate decryption key-expansion datapath is not required.

### Encryption Datapath

`AES_Encryption_Module` implements the AES encryption transformations using:

- SubBytes
- ShiftRows
- MixColumns
- AddRoundKey

The final AES round omits MixColumns as required by the AES algorithm.

### Decryption Datapath

`AES_Decryption_Module` implements the corresponding inverse transformations:

- InvSubBytes
- InvShiftRows
- InvMixColumns
- AddRoundKey

For additional design details, see [DOCS/architecture.md](DOCS/architecture.md).

## Top-Level Interface

```verilog
module AES_Accelerator(
    input              clk,
    input              rst_n,
    input              start,
    input              operation,
    input      [1:0]   AES_mode,
    input      [127:0] AES_data_in,
    input      [255:0] AES_key_in,
    output reg [127:0] AES_data_out,
    output reg         AES_busy,
    output reg         AES_done
);
```

### AES Modes

| Mode | `AES_mode` | Key Width | AES Rounds |
|------|------------|-----------|------------|
| AES-128 | `2'd1` | 128 bits | 10 |
| AES-192 | `2'd2` | 192 bits | 12 |
| AES-256 | `2'd3` | 256 bits | 14 |

### Operation Selection

| Operation | `operation` |
|-----------|-------------|
| Encryption | `1'b0` |
| Decryption | `1'b1` |

### Key Placement

The key is supplied through the 256-bit `AES_key_in` input.

| Mode | Active Key Bits |
|------|-----------------|
| AES-128 | `AES_key_in[127:0]` |
| AES-192 | `AES_key_in[191:0]` |
| AES-256 | `AES_key_in[255:0]` |

For AES-128 and AES-192, unused most-significant key bits are set to zero.

### Transaction Interface

A transaction is initiated by asserting `start`.

`AES_busy` indicates that the accelerator is processing the current operation.

`AES_done` indicates completion. `AES_data_out` is valid during the `AES_done` indication.

## Verification

The project contains 13 self-checking Verilog testbenches covering the design from individual AES transformations through complete end-to-end accelerator operation.

Verification includes:

- Forward and inverse S-box
- SubBytes and InvSubBytes
- ShiftRows and InvShiftRows
- MixColumns and InvMixColumns
- AddRoundKey
- AES-128 key expansion
- AES-192 key expansion
- AES-256 key expansion
- Key preparation and round-key selection
- Encryption datapath
- Decryption datapath
- Complete AES accelerator

The full RTL regression compiles and executes with zero ModelSim compilation errors and zero compilation warnings.

### End-to-End Known-Answer Tests

Plaintext:

```text
00112233445566778899aabbccddeeff
```

| AES Mode | Expected Ciphertext |
|----------|---------------------|
| AES-128 | `69c4e0d86a7b0430d8cdb78070b4c55a` |
| AES-192 | `dda97ca4864cdfe06eaf70a0ec0d7191` |
| AES-256 | `8ea2b7ca516745bfeafc49904b496089` |

Encryption is verified against the expected ciphertext for each supported key size. Decryption is also verified to recover the original plaintext.

### Observed Simulation Latency

End-to-end latency observed at the `AES_Accelerator` interface:

| AES Mode | Encryption | Decryption |
|----------|------------|------------|
| AES-128 | 26 cycles | 26 cycles |
| AES-192 | 26 cycles | 26 cycles |
| AES-256 | 27 cycles | 27 cycles |

These values represent RTL simulation latency. They are not FPGA timing or Fmax results.

Additional datapath and key-preparation verification results are documented in [DOCS/verification.md](DOCS/verification.md).

## Running the Simulation

### Requirements

The current verification flow has been tested with:

```text
ModelSim Intel FPGA Edition 2020.1
```

### Full Regression

From the ModelSim command prompt:

```tcl
cd C:/path/to/AES_Hardware_Accelerator/Scripts
do run_regression.do
```

The regression script:

1. Creates a clean ModelSim work library.
2. Compiles all synthesizable RTL.
3. Compiles all 13 self-checking testbenches.
4. Executes each testbench sequentially.
5. Writes the complete simulator transcript to `regression.log`.

Generated simulator files, work libraries, and regression logs are excluded from version control.

### Top-Level Accelerator Simulation

To run only the end-to-end accelerator testbench:

```tcl
cd C:/path/to/AES_Hardware_Accelerator/Scripts
do run_aes_accelerator.do
```

## FPGA Status

The reusable RTL core and simulation verification environment are complete.

The intended FPGA target is the Terasic DE10-Nano development board based on an Intel Cyclone V device.

The following implementation-stage results are intentionally not claimed yet:

- FPGA resource utilization
- Maximum clock frequency (Fmax)
- Static timing analysis
- Board-level hardware validation

These results will be added after the FPGA implementation and hardware-validation stage is completed.

## Project Status

**Completed:**

- AES-128/192/256 RTL implementation
- Encryption and decryption datapaths
- Key expansion and key preparation
- Self-checking module-level verification
- End-to-end known-answer testing
- Automated 13-testbench regression
- Architecture and verification documentation

**Next:**

- Intel Quartus FPGA synthesis
- Resource-utilization analysis
- Static timing and Fmax analysis
- DE10-Nano integration
- Physical hardware validation

## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Yarden Rosenblum

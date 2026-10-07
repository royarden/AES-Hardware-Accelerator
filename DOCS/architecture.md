# AES Hardware Accelerator Architecture

## Overview

The AES Hardware Accelerator is a synthesizable Verilog implementation supporting
AES-128, AES-192, and AES-256 encryption and decryption.

The design is organized as a reusable hardware core with a unified top-level
interface. The `AES_Accelerator` module coordinates key preparation and the
encryption or decryption datapath.

## Top-Level Architecture

The design consists of three primary functional blocks:

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

The top-level controller selects the appropriate datapath according to the
`operation` input and coordinates the transaction using `start`, `AES_busy`,
and `AES_done`.

## Key Preparation

`Key_Preparation` generates and stores the round keys required by the selected
AES mode.

Three key-expansion modules are provided:

- `Key_Expansion_128_Enc`
- `Key_Expansion_192_Enc`
- `Key_Expansion_256_Enc`

The generated forward round keys are also used during decryption in reverse
round order. Therefore, the architecture does not require a separate
decryption key-expansion datapath.

The supported number of AES rounds is:

| Mode | Key Size | AES Rounds |
|------|----------|------------|
| AES-128 | 128 bits | 10 |
| AES-192 | 192 bits | 12 |
| AES-256 | 256 bits | 14 |

## Encryption Datapath

`AES_Encryption_Module` implements the AES encryption sequence using the
following transformations:

1. AddRoundKey
2. SubBytes
3. ShiftRows
4. MixColumns
5. AddRoundKey

The final AES round omits the MixColumns transformation, as required by the
AES algorithm.

The encryption datapath uses the following RTL blocks:

- `Sbox_Enc`
- `Sub_Bytes_Enc`
- `Shift_Rows_Enc`
- `Mix_One_Column_Enc`
- `Mix_Columns_Enc`
- `Add_Round_Key_Enc`

## Decryption Datapath

`AES_Decryption_Module` performs the inverse AES transformations.

The decryption datapath uses:

- `Sbox_Dec`
- `Sub_Bytes_Dec`
- `Shift_Rows_Dec`
- `Mix_One_Column_Dec`
- `Mix_Columns_Dec`
- `Add_Round_Key_Dec`

Forward-generated round keys are selected in reverse order during decryption.

## AES State Representation

AES operates on a 128-bit state containing 16 bytes.

The RTL uses the AES column-major state organization so that byte ordering is
consistent across the SubBytes, ShiftRows, MixColumns, and AddRoundKey
transformations.

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

### Mode Encoding

| AES Mode | `AES_mode` |
|----------|------------|
| AES-128 | `2'd1` |
| AES-192 | `2'd2` |
| AES-256 | `2'd3` |

### Operation Encoding

| Operation | `operation` |
|-----------|-------------|
| Encryption | `1'b0` |
| Decryption | `1'b1` |

### Key Placement

The key is supplied through the 256-bit `AES_key_in` interface:

| Mode | Active Key Bits |
|------|-----------------|
| AES-128 | `AES_key_in[127:0]` |
| AES-192 | `AES_key_in[191:0]` |
| AES-256 | `AES_key_in[255:0]` |

Unused most-significant bits are set to zero for AES-128 and AES-192.

## Transaction Interface

A transaction is initiated using `start`.

`AES_busy` indicates that the accelerator is processing the current operation.

`AES_done` indicates completion. `AES_data_out` is valid during the
`AES_done` indication.

## Current Implementation Status

The RTL architecture and simulation behavior have been verified using
self-checking ModelSim testbenches for AES-128, AES-192, and AES-256
encryption and decryption.

FPGA synthesis, timing analysis, resource utilization, and board-level
validation are planned as a separate implementation stage.

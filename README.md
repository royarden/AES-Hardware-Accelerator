\# AES Hardware Accelerator



A synthesizable Verilog implementation of an AES hardware accelerator supporting

AES-128, AES-192, and AES-256 encryption and decryption.



The design provides a unified top-level interface for key preparation, encryption,

and decryption, together with a self-checking verification environment.



## Features



\- AES-128, AES-192, and AES-256 support

\- Encryption and decryption

\- Synthesizable Verilog RTL

\- Unified top-level accelerator interface

\- AES key expansion for 128-, 192-, and 256-bit keys

\- Forward round keys reused in reverse order for decryption

\- Self-checking testbenches

\- Known-answer testing using standard AES test vectors

\- Automated ModelSim regression script

\- 13 RTL testbenches covering individual transformations through full

&#x20; end-to-end accelerator operation



## Repository Structure

```text
AES_Hardware_Accelerator/
├── RTL/        # Synthesizable Verilog RTL
├── TB/         # Self-checking testbenches
├── DOCS/       # Architecture and verification documentation
├── Scripts/    # Simulation and regression scripts
├── README.md
└── .gitignore
```


## Architecture



The accelerator is organized around three main blocks:



\- `Key\_Preparation`

&#x20; - Generates and stores the AES round keys.

&#x20; - Supports AES-128, AES-192, and AES-256 key schedules.



\- `AES\_Encryption\_Module`

&#x20; - Performs the AES encryption rounds using:

&#x20;   - SubBytes

&#x20;   - ShiftRows

&#x20;   - MixColumns

&#x20;   - AddRoundKey



\- `AES\_Decryption\_Module`

&#x20; - Performs the inverse AES transformations:

&#x20;   - InvSubBytes

&#x20;   - InvShiftRows

&#x20;   - InvMixColumns

&#x20;   - AddRoundKey



The top-level `AES\_Accelerator` coordinates key preparation and the selected

encryption or decryption operation.



Decryption reuses the forward-generated round keys in reverse order; a separate

decryption key-expansion datapath is not required.



## Top-Level Interface



The reusable accelerator core is instantiated as:



```verilog

module AES\_Accelerator(

&#x20;   input              clk,

&#x20;   input              rst\_n,

&#x20;   input              start,

&#x20;   input              operation,

&#x20;   input      \[1:0]   AES\_mode,

&#x20;   input      \[127:0] AES\_data\_in,

&#x20;   input      \[255:0] AES\_key\_in,

&#x20;   output reg \[127:0] AES\_data\_out,

&#x20;   output reg         AES\_busy,

&#x20;   output reg         AES\_done

);

```



### AES Modes



| Mode | `AES\_mode` | Key Width |

|------|------------|-----------|

| AES-128 | `2'd1` | 128 bits |

| AES-192 | `2'd2` | 192 bits |

| AES-256 | `2'd3` | 256 bits |



### Operation Selection



| Operation | `operation` |

|-----------|-------------|

| Encrypt | `1'b0` |

| Decrypt | `1'b1` |



For AES-128 and AES-192, the key is placed in the least-significant portion of

`AES\_key\_in`, with unused most-significant bits set to zero.



`AES\_data\_out` is valid when `AES\_done` is asserted.



## Verification



The project contains 13 self-checking testbenches covering:



\- S-box and inverse S-box

\- SubBytes / InvSubBytes

\- ShiftRows / InvShiftRows

\- MixColumns / InvMixColumns

\- AddRoundKey

\- AES-128 key expansion

\- AES-192 key expansion

\- AES-256 key expansion

\- Key preparation

\- Encryption datapath

\- Decryption datapath

\- Complete AES accelerator



The current regression passes all 13 testbenches with no ModelSim compilation

warnings or errors.



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



Both encryption and reverse decryption are verified.



### Observed Simulation Latency



Measured at the `AES\_Accelerator` interface:



| AES Mode | Encryption | Decryption |

|----------|------------|------------|

| AES-128 | 26 cycles | 26 cycles |

| AES-192 | 26 cycles | 26 cycles |

| AES-256 | 27 cycles | 27 cycles |



These values describe the current RTL simulation behavior and are not FPGA

timing or performance results.



## Running the Simulation



The verification environment has been tested with ModelSim Intel FPGA Edition

2020.1.



From ModelSim:



```tcl

cd C:/path/to/AES\_Hardware\_Accelerator/Scripts

do run\_regression.do

```



The script compiles the RTL and all testbenches and then executes the complete

regression suite.



A simulation transcript is generated as:

```text
Scripts/regression.log
```


Generated logs, simulator work libraries, and other build artifacts are excluded

from version control.



For a top-level-only simulation, use:



```tcl

do run\_aes\_accelerator.do

```



## FPGA Status



The RTL and simulation environment are currently verified in ModelSim.



FPGA implementation work is planned for an Intel/Altera Cyclone V device using

the DE10-Nano development board.



The following results are intentionally not reported yet:



\- FPGA resource utilization

\- Maximum clock frequency (Fmax)

\- Static timing analysis

\- Board-level hardware validation



These results will be added after synthesis, timing analysis, and hardware

testing have been completed.



## Project Status



\*\*Current:\*\* RTL design and simulation verification complete.



\*\*Next:\*\* FPGA synthesis, timing analysis, resource analysis, and DE10-Nano

hardware integration.



## License



A project license has not yet been selected.


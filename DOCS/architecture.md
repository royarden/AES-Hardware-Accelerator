\# AES Hardware Accelerator Architecture



\## Overview



The AES Hardware Accelerator is a synthesizable Verilog implementation supporting

AES-128, AES-192, and AES-256 encryption and decryption.



The design is organized as a reusable hardware core with a unified top-level

interface. The `AES\_Accelerator` module coordinates key preparation and the

encryption or decryption datapath.



\## Top-Level Architecture



The design consists of three primary functional blocks:



```text

&#x20;                   +----------------------+

AES\_key\_in -------->|                      |

AES\_mode ---------->|   Key\_Preparation    |---- Round Keys

&#x20;                   |                      |         |

&#x20;                   +----------------------+         |

&#x20;                                                    |

&#x20;                                                    v

AES\_data\_in ---> +-----------------------+     +-----------------------+

&#x20;                |                       |     |                       |

&#x20;                | AES\_Encryption\_Module |     | AES\_Decryption\_Module |

&#x20;                |                       |     |                       |

&#x20;                +-----------------------+     +-----------------------+

&#x20;                          |                           |

&#x20;                          +-------------+-------------+

&#x20;                                        |

&#x20;                                        v

&#x20;                                 AES\_data\_out

```



The top-level controller selects the appropriate datapath according to the

`operation` input and coordinates the transaction using `start`, `AES\_busy`,

and `AES\_done`.



\## Key Preparation



`Key\_Preparation` generates and stores the round keys required by the selected

AES mode.



Three key-expansion modules are provided:



\- `Key\_Expansion\_128\_Enc`

\- `Key\_Expansion\_192\_Enc`

\- `Key\_Expansion\_256\_Enc`



The generated forward round keys are also used during decryption in reverse

round order. Therefore, the architecture does not require a separate

decryption key-expansion datapath.



The supported number of AES rounds is:



| Mode | Key Size | AES Rounds |

|------|----------|------------|

| AES-128 | 128 bits | 10 |

| AES-192 | 192 bits | 12 |

| AES-256 | 256 bits | 14 |



\## Encryption Datapath



`AES\_Encryption\_Module` implements the AES encryption sequence using the

following transformations:



1\. AddRoundKey

2\. SubBytes

3\. ShiftRows

4\. MixColumns

5\. AddRoundKey



The final AES round omits the MixColumns transformation, as required by the

AES algorithm.



The encryption datapath uses the following RTL blocks:



\- `Sbox\_Enc`

\- `Sub\_Bytes\_Enc`

\- `Shift\_Rows\_Enc`

\- `Mix\_One\_Column\_Enc`

\- `Mix\_Columns\_Enc`

\- `Add\_Round\_Key\_Enc`



\## Decryption Datapath



`AES\_Decryption\_Module` performs the inverse AES transformations.



The decryption datapath uses:



\- `Sbox\_Dec`

\- `Sub\_Bytes\_Dec`

\- `Shift\_Rows\_Dec`

\- `Mix\_One\_Column\_Dec`

\- `Mix\_Columns\_Dec`

\- `Add\_Round\_Key\_Dec`



Forward-generated round keys are selected in reverse order during decryption.



\## AES State Representation



AES operates on a 128-bit state containing 16 bytes.



The RTL uses the AES column-major state organization so that byte ordering is

consistent across the SubBytes, ShiftRows, MixColumns, and AddRoundKey

transformations.



\## Top-Level Interface



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



\### Mode Encoding



| AES Mode | `AES\_mode` |

|----------|------------|

| AES-128 | `2'd1` |

| AES-192 | `2'd2` |

| AES-256 | `2'd3` |



\### Operation Encoding



| Operation | `operation` |

|-----------|-------------|

| Encryption | `1'b0` |

| Decryption | `1'b1` |



\### Key Placement



The key is supplied through the 256-bit `AES\_key\_in` interface:



| Mode | Active Key Bits |

|------|-----------------|

| AES-128 | `AES\_key\_in\[127:0]` |

| AES-192 | `AES\_key\_in\[191:0]` |

| AES-256 | `AES\_key\_in\[255:0]` |



Unused most-significant bits are set to zero for AES-128 and AES-192.



\## Transaction Interface



A transaction is initiated using `start`.



`AES\_busy` indicates that the accelerator is processing the current operation.



`AES\_done` indicates completion. `AES\_data\_out` is valid during the

`AES\_done` indication.



\## Current Implementation Status



The RTL architecture and simulation behavior have been verified using

self-checking ModelSim testbenches for AES-128, AES-192, and AES-256

encryption and decryption.



FPGA synthesis, timing analysis, resource utilization, and board-level

validation are planned as a separate implementation stage.


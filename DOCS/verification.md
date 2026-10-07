\# AES Hardware Accelerator Verification



\## Overview



The AES Hardware Accelerator is verified using a set of self-checking Verilog

testbenches executed with ModelSim Intel FPGA Edition 2020.1.



The verification environment covers individual AES transformations, key

expansion and preparation, encryption and decryption datapaths, and complete

end-to-end accelerator operation.



A full regression script is provided in:



```text

Scripts/run\_regression.do

```



The current regression consists of 13 testbenches and completes with no

ModelSim compilation errors or warnings.



\## Testbench Suite



| Testbench | Verification Scope |

|-----------|--------------------|

| `Sbox\_tb.v` | Forward and inverse AES S-box |

| `Sub\_Bytes\_tb.v` | SubBytes and InvSubBytes |

| `Shift\_Rows\_tb.v` | ShiftRows and InvShiftRows |

| `Mix\_One\_Column\_tb.v` | Single-column MixColumns and inverse |

| `Mix\_Columns\_tb.v` | Full-state MixColumns and inverse |

| `Add\_Round\_Key\_tb.v` | AddRoundKey transformation |

| `Key\_Expansion\_128\_Enc\_tb.v` | AES-128 key expansion |

| `Key\_Expansion\_192\_Enc\_tb.v` | AES-192 key expansion |

| `Key\_Expansion\_256\_Enc\_tb.v` | AES-256 key expansion |

| `Key\_Preparation\_tb.v` | Round-key generation and selection |

| `AES\_Encryption\_Module\_tb.v` | AES-128/192/256 encryption datapath |

| `AES\_Decryption\_Module\_tb.v` | AES-128/192/256 decryption datapath |

| `AES\_Accelerator\_tb.v` | Complete end-to-end accelerator |



\## Known-Answer Tests



The end-to-end accelerator verification uses the following plaintext:



```text

00112233445566778899aabbccddeeff

```



\### AES-128



Key:



```text

000102030405060708090a0b0c0d0e0f

```



Expected ciphertext:



```text

69c4e0d86a7b0430d8cdb78070b4c55a

```



\### AES-192



Key:



```text

000102030405060708090a0b0c0d0e0f1011121314151617

```



Expected ciphertext:



```text

dda97ca4864cdfe06eaf70a0ec0d7191

```



\### AES-256



Key:



```text

000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f

```



Expected ciphertext:



```text

8ea2b7ca516745bfeafc49904b496089

```



For each mode, decryption is also verified to recover the original plaintext.



\## End-to-End Simulation Latency



Latency measured by the top-level `AES\_Accelerator\_tb`:



| AES Mode | Encryption | Decryption |

|----------|------------|------------|

| AES-128 | 26 cycles | 26 cycles |

| AES-192 | 26 cycles | 26 cycles |

| AES-256 | 27 cycles | 27 cycles |



These values represent observed RTL simulation latency at the accelerator

interface. They are not FPGA timing or Fmax results.



\## Datapath Verification



The encryption datapath is independently verified for all three AES modes.



Observed completion latency inside `AES\_Encryption\_Module`:



| AES Mode | Latency |

|----------|---------|

| AES-128 | 11 cycles |

| AES-192 | 13 cycles |

| AES-256 | 15 cycles |



The decryption datapath is independently verified with the same corresponding

round-processing latencies.



\## Key Preparation Verification



`Key\_Preparation\_tb` verifies key generation for all supported AES modes.



Observed key-preparation completion:



| AES Mode | Latency |

|----------|---------|

| AES-128 | 11 cycles |

| AES-192 | 9 cycles |

| AES-256 | 8 cycles |



The testbench also verifies valid round-key selection and rejection of

out-of-range round-key requests.



\## Full Regression



To execute the complete verification suite from ModelSim:



```tcl

cd C:/path/to/AES\_Hardware\_Accelerator/Scripts

do run\_regression.do

```



The regression script:



1\. Creates a clean ModelSim work library.

2\. Compiles all synthesizable RTL.

3\. Compiles all 13 self-checking testbenches.

4\. Executes each testbench sequentially.

5\. Writes the complete simulator transcript to `regression.log`.



Generated simulator files and regression logs are excluded from version

control.



\## Current Verification Status



Current RTL regression status:



```text

RTL compilation:        PASS

Compilation warnings:   0

Compilation errors:     0

Testbenches executed:   13

Testbenches passed:     13

End-to-end AES-128:     PASS

End-to-end AES-192:     PASS

End-to-end AES-256:     PASS

```



Encryption and decryption are verified for all three supported AES key sizes.



\## FPGA Validation



The current verification results apply to RTL simulation.



FPGA synthesis, static timing analysis, resource utilization, and physical

DE10-Nano board validation have not yet been completed and are intentionally

not claimed by this document.


# ML-KEM + ML-DSA Unified IP — Codex Handoff

## 1. Project Goal

Thiết kế **một hardware IP duy nhất** hỗ trợ cả:

- **ML-KEM** theo NIST FIPS 203
- **ML-DSA** theo NIST FIPS 204

Mục tiêu chính là đạt **PPA tốt nhất có thể** (Power, Performance, Area), ưu tiên kiến trúc dùng chung datapath thay vì ghép hai accelerator độc lập.

### Core design philosophy

Không thiết kế:

```text
mlkem_core + mldsa_core
```

rồi đặt chung dưới một top.

Thay vào đó, xem ML-KEM và ML-DSA như hai luồng thuật toán sử dụng chung một tập hardware primitive:

```text
ML-KEM ──┐
         ├── Shared crypto datapath
ML-DSA ──┘
```

Các block đắt giá cần ưu tiên chia sẻ:

- Keccak-f[1600] / SHA3 / SHAKE
- NTT / INTT
- Polynomial modular arithmetic
- Pointwise multiplication
- Polynomial memory / SRAM
- Twiddle storage
- Address generation
- Một phần sampler / packing / control

ML-DSA vẫn cần một số block riêng như:

- Power2Round
- Decompose
- MakeHint
- UseHint
- NormCheck

---

# 2. Standards / Golden Specification

Nguồn chuẩn tuyệt đối phải là:

- **NIST FIPS 203 — ML-KEM**
- **NIST FIPS 204 — ML-DSA**

Các implementation Kyber/Dilithium cũ chỉ dùng để nghiên cứu kiến trúc, không dùng làm specification cuối vì có thể khác bản FIPS final.

Golden software candidates:

- `pq-code-package/mlkem-native`
- `pq-code-package/mldsa-native`

Mục tiêu của golden model:

```text
FIPS 203 / FIPS 204
        │
        ▼
 Golden C implementation
        │
        ├───────────────┐
        ▼               ▼
 Python HW model       RTL
        │               │
        └──── compare ──┘
```

Golden model phải cho phép dump intermediate values để verify từng RTL block, không chỉ compare output cuối.

---

# 3. Reference Papers / Repositories Identified

## 3.1 Highest-priority unified architecture paper

### High-Performance Unified Hardware Architecture for ML-DSA and ML-KEM PQC Standards
- IEEE Access, 2025
- Authors previously identified: Quang Dang Truong, Yunseong Jang, Hanho Lee
- Đây là academic baseline sát đề tài nhất.
- Điểm cần nghiên cứu:
  - Unified polynomial arithmetic
  - Runtime ML-KEM / ML-DSA mode switching
  - Folding-pipelined NTT
  - Unified hash
  - Resource / latency / ATP comparison

**Priority: 10/10**

---

## 3.2 Adams Bridge / Caliptra

Repository:

```text
chipsalliance/adams-bridge
```

Đây là industrial-quality RTL baseline rất quan trọng.

Đã thấy các module/function đáng nghiên cứu như:

```text
abr_top
abr_sha3
ntt_top
abr_sampler_top
decompose
exp_mask
makehint
norm_check
pk_decode
power2round
rej_bounded
rej_sampler
sample_in_ball
sig_decode_z
sig_encode_z
sk_decode
sk_encode
```

Adams Bridge hỗ trợ ML-DSA và ML-KEM trong Caliptra.

Dùng repo này để học:

- top-level partition
- production-style RTL
- SHA3 integration
- NTT controller
- sampler
- memory organization
- zeroization
- key handling
- verification
- lint
- CDC/RDC
- formal
- integration into Root of Trust

**Priority: 10/10**

---

## 3.3 PQC OpenTitan

Repository:

```text
PQC-OpenTitan/improving-ml-kem-and-ml-dsa-on-opentitan
```

Đáng chú ý cho shared arithmetic / architecture exploration.

Các block được nhắc tới:

```text
unified_mul.sv
otbn_mul.sv
brent_kung.sv
kogge_stone.sv
sklansky.sv
vector arithmetic
```

Có workflow hữu ích cho:

- RTL simulation
- RTL/ISS comparison
- Verilator
- Vivado synthesis
- Cadence Genus
- OpenROAD
- FPGA

Đặc biệt phù hợp để nghiên cứu **unified multiplier** và design-space exploration.

**Priority: 9.5/10**

---

## 3.4 KiD unified NTT

Paper:

### KiD: A Hardware Design Framework Targeting Unified NTT Multiplication for CRYSTALS-Kyber and CRYSTALS-Dilithium

Điểm cần nghiên cứu:

- Unified NTT cho hai modulus khác nhau
- Radix-2 butterfly count exploration
- Conflict-free memory mapping
- Pipelining
- NTT schedule
- Twiddle handling

**Priority: 10/10 cho NTT subsystem**

---

## 3.5 Efficient Polynomial Arithmetic and Hash Modules for ML-DSA and ML-KEM Standards

Paper tiền thân/related work của unified architecture.

Điểm chính:

```text
ML-KEM ──┐
         ├── Polynomial arithmetic
ML-DSA ──┘

ML-KEM ──┐
         ├── Unified Keccak/SHAKE
ML-DSA ──┘
```

**Priority: 9/10**

---

## 3.6 KaLi

Paper:

### KaLi: A Crystal for Post-Quantum Security Using Kyber and Dilithium

Dùng để nghiên cứu:

- resource sharing
- programmable crypto architecture
- NTT
- multiplier
- memory architecture

Lưu ý: Kyber/Dilithium pre-FIPS final, không dùng làm final spec.

**Priority: 8.5/10**

---

## 3.7 GMU CERG Dilithium RTL

Repository:

```text
GMUCERG/Dilithium
```

Full Verilog cho:

- KeyGen
- Sign
- Verify

Có NTT 2×2 và testbench.

Dùng để nghiên cứu performance-oriented ML-DSA datapath và BFU scaling:

```text
1 BFU
2 BFU
4 BFU
8 BFU
```

**Priority: 8.5/10**

---

## 3.8 HOPE-MLKEM

Repository:

```text
HWSec-CSIC/hope-mlkem
```

Dùng để nghiên cứu riêng ML-KEM và PPA flow.

Có hỗ trợ:

- RTL simulation
- FPGA synthesis
- ASIC synthesis
- STA
- power
- TVLA
- side-channel analysis

Có parameter hóa butterfly unit:

```text
N_BU = 1
N_BU = 2
N_BU = 4
```

**Priority: 8.5/10**

---

## 3.9 RISC-V SoC Kyber + Dilithium co-design

Artifact:

### Optimized Hardware-Software Co-Design for Kyber and Dilithium on RISC-V SoC FPGA

Dùng để xác định operation nào đáng accelerator hóa và hiểu HW/SW boundary.

**Priority: 7.5/10**

---

# 4. Current Architectural Direction

Kiến trúc hiện tại là **candidate architecture**, chưa phải final RTL architecture.

```text
                     ┌─────────────────────────┐
                     │    MLKEM-MLDSA TOP      │
                     │ command / mode / config │
                     └────────────┬────────────┘
                                  │
                       ┌──────────▼─────────┐
                       │ Microcode / FSM    │
                       │ Controller         │
                       └──────────┬─────────┘
                                  │
      ┌───────────────────────────┼───────────────────────────┐
      │                           │                           │
      ▼                           ▼                           ▼
┌─────────────┐            ┌─────────────┐            ┌─────────────┐
│ Unified     │            │ Shared      │            │ Shared /    │
│ NTT/INTT   │            │ Keccak      │            │ partial     │
│ Engine     │            │ f[1600]     │            │ Sampler     │
└──────┬──────┘            └─────────────┘            └─────────────┘
       │
       ▼
┌──────────────────────┐
│ Unified Modular ALU  │
│ ADD / SUB / MUL      │
│ REDUCE               │
│ q=3329 / 8380417     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Polynomial SRAM      │
│ bank0 / bank1 / ...  │
│ conflict-free AGU    │
└──────────────────────┘

ML-DSA-specific lightweight units:
┌───────────────────────────────────┐
│ Power2Round / Decompose           │
│ MakeHint / UseHint / NormCheck    │
└───────────────────────────────────┘

Codec:
┌───────────────────────────────────┐
│ Pack / Unpack / Compress / Decode │
└───────────────────────────────────┘
```

---

# 5. Important Algorithm Parameters

Two key polynomial moduli:

## ML-KEM

```text
q_K = 3329
```

Approximate arithmetic width: 12 bits for coefficients/modulus representation, though internal multiplication/reduction widths are larger.

## ML-DSA

```text
q_D = 8380417
```

Approximately 23-bit modulus; implementation will generally require wider intermediate multiplication paths.

The mismatch between these widths is one of the central architectural challenges.

---

# 6. Main PPA Research Question

A naïve design could build a multiplier wide enough for ML-DSA and reuse it for ML-KEM.

Problem:

```text
wide ML-DSA multiplier
        │
        └── ML-KEM uses only a fraction of hardware width
```

This could waste area/power during ML-KEM.

A candidate design-space option discussed:

```text
ML-DSA mode:
one wide arithmetic lane

ML-KEM mode:
split available datapath into multiple narrower lanes
```

Conceptually:

```text
ML-DSA:
A[~23b] × B[~23b] -> reduce mod 8380417

ML-KEM:
lane0: A0[~12b] × B0[~12b]
lane1: A1[~12b] × B1[~12b]
-> reduce mod 3329
```

This is **NOT a final decision**.

Codex must treat it as a candidate requiring:

- RTL feasibility study
- multiplier mapping study
- FPGA DSP mapping
- ASIC synthesis comparison
- timing analysis
- energy comparison
- scheduling impact analysis

---

# 7. Hardware Sharing Matrix — Initial View

| Hardware primitive | ML-KEM | ML-DSA | Sharing expectation | Priority |
|---|---:|---:|---|---|
| Keccak-f[1600] | yes | yes | Very high | Highest |
| SHAKE128 | yes | yes | Very high | Highest |
| SHAKE256 | yes | yes | Very high | Highest |
| NTT | yes | yes | High but non-trivial | Highest |
| INTT | yes | yes | High but non-trivial | Highest |
| Pointwise multiply | yes | yes | High | Highest |
| Modular ADD/SUB | yes | yes | Very high | High |
| Modular reduction | yes | yes | High but q-dependent | Highest |
| Polynomial RAM | yes | yes | Very high | Highest |
| Twiddle memory | yes | yes | High | High |
| Address generator | yes | yes | High | High |
| Rejection sampler | yes | yes | Partial | Medium |
| Pack/unpack | yes | yes | Partial | Medium |
| Compress/decompress | yes | limited/different | Mostly KEM | Medium |
| Power2Round | no | yes | DSA only | Low area |
| Decompose | no | yes | DSA only | Low/medium |
| MakeHint/UseHint | no | yes | DSA only | Low/medium |
| NormCheck | no | yes | DSA only | Low |

---

# 8. Development Strategy Decided

Do **not** start by writing a complete ML-KEM or ML-DSA RTL core.

Recommended development order:

```text
Spec
 ↓
Golden SW
 ↓
Operation decomposition
 ↓
Python hardware models
 ↓
Modular arithmetic
 ↓
Butterfly
 ↓
Individual KEM / DSA NTT
 ↓
Unified NTT exploration
 ↓
Keccak
 ↓
Memory / sampler
 ↓
ML-KEM datapath
 ↓
ML-DSA datapath
 ↓
Unified control/top
 ↓
PPA exploration
```

PPA exploration should begin early at primitive/block level, not only after the full IP exists.

---

# 9. Recommended Initial Parameter Sets

For initial bring-up, suggested starting point:

```text
ML-KEM-768
ML-DSA-65
```

Reason:

- middle security levels
- sufficiently representative
- avoid prematurely supporting every parameter set
- architecture can later be generalized

This is a recommendation, not yet a hard requirement.

Eventually the architecture should be evaluated for whether supporting all standard parameter sets materially hurts PPA.

---

# 10. Proposed Repository Structure

```text
mlkem-mldsa-ip/
│
├── docs/
│   ├── fips203_notes.md
│   ├── fips204_notes.md
│   ├── operation_matrix.md
│   ├── architecture.md
│   ├── ppa_methodology.md
│   └── references.md
│
├── model/
│   ├── mlkem/
│   ├── mldsa/
│   ├── arithmetic/
│   ├── ntt/
│   ├── keccak/
│   └── tests/
│
├── rtl/
│   ├── arithmetic/
│   ├── ntt/
│   ├── keccak/
│   ├── sampler/
│   ├── memory/
│   ├── codec/
│   ├── mldsa_special/
│   └── top/
│
├── tb/
│   ├── unit/
│   ├── block/
│   ├── integration/
│   └── vectors/
│
├── synthesis/
│   ├── fpga/
│   ├── asic/
│   └── reports/
│
├── scripts/
│
└── README.md
```

This structure is proposed; adjust if an existing repository already has conventions.

---

# 11. Milestones

## M0 — Algorithm Understanding / Golden Environment

Deliverables:

- FIPS 203 notes
- FIPS 204 notes
- ML-KEM golden implementation running
- ML-DSA golden implementation running
- intermediate-value dump mechanism
- operation matrix
- bit-width table
- shareability analysis
- candidate PPA metrics

No top-level RTL required yet.

---

## M1 — Modular Arithmetic

Implement and verify:

```text
mod_add
mod_sub
mod_reduce
mod_mul
butterfly
```

Requirements:

- ML-KEM q=3329
- ML-DSA q=8380417
- cycle-accurate Python model
- randomized tests
- corner cases
- synthesis exploration

Candidate reduction methods to benchmark may include:

- Montgomery
- Barrett
- specialized constant-modulus reduction

Do not assume one is universally best without synthesis.

---

## M2 — NTT Engine

Order:

1. correct ML-KEM NTT
2. correct ML-KEM INTT
3. correct ML-DSA NTT
4. correct ML-DSA INTT
5. memory access analysis
6. conflict-free banking
7. unified engine exploration
8. BFU-count sweep

Candidate BFU counts:

```text
1
2
4
8
```

Compare:

- area
- Fmax
- cycles
- latency
- throughput
- Area × Time
- Area × Time²
- power/energy if available

---

## M3 — Keccak / SHAKE

Create one shared Keccak-f[1600] engine if practical.

Support modes required by FIPS algorithms.

Explore:

- iterative round architecture
- partially unrolled
- more highly unrolled if performance target demands it

Benchmark area/frequency/cycles/power.

---

## M4 — Memory + Sampler + Codec

Determine:

- polynomial memory capacity
- bank count
- port requirements
- NTT conflict-free mapping
- temporary storage
- seed/hash buffering
- KEM/DSA lifetime overlap
- whether memories can be safely aliased/shared

Then integrate:

- rejection sampling
- sample-in-ball
- packing
- unpacking
- encode/decode
- KEM compression/decompression
- DSA-specific transforms

---

## M5 — ML-KEM Datapath

Implement:

```text
KeyGen
Encaps
Decaps
```

against FIPS 203 golden vectors.

Do not duplicate shared blocks.

---

## M6 — ML-DSA Datapath

Implement:

```text
KeyGen
Sign
Verify
```

against FIPS 204 golden vectors.

Add DSA-specific units only where sharing is not sensible.

---

## M7 — Unified IP

Integrate:

```text
mlkem_mldsa_top
mode/config
controller or microsequencer
shared memory
shared NTT
shared Keccak
shared modular arithmetic
sampler/codec
zeroization/security controls
```

Evaluate whether FSM vs microcoded controller gives better area/flexibility.

Do not pick microcode automatically; benchmark/control complexity first.

---

## M8 — PPA Optimization

Run systematic design-space exploration.

Metrics:

```text
Area
Fmax
cycles/op
latency
throughput
dynamic power
leakage power if ASIC
energy/op
Area × Time
Area × Time²
```

Operations to benchmark separately:

### ML-KEM
- KeyGen
- Encaps
- Decaps

### ML-DSA
- KeyGen
- Sign
- Verify

Do not report only one aggregate score.

---

# 12. PPA Design-Space Variables

Codex should eventually automate sweeps for:

## Arithmetic
- multiplier architecture
- multiplier pipelining
- modular reduction method
- unified vs separate reduction datapaths
- ML-KEM SIMD/dual-lane mode
- DSP use vs logic implementation

## NTT
- radix
- BFU count
- pipeline stages
- DIF vs DIT where algorithmically appropriate
- forward/inverse sharing
- twiddle storage
- twiddle generation vs ROM
- memory bank count
- address generation

## Keccak
- rounds/cycle
- iterative vs unrolled
- state register organization

## Memory
- registers vs SRAM/BRAM
- single-port / simple dual-port / true dual-port
- bank count
- memory sharing across algorithms
- data layout
- double buffering

## Control
- dedicated FSM
- microcoded controller
- instruction-like sequencer

---

# 13. Verification Strategy

Every block should have:

```text
FIPS/golden SW
      ↓
Python HW model
      ↓
RTL
```

Test levels:

## Unit
- modular add/sub/mul/reduce
- butterfly
- Keccak round/permutation
- sampler primitives
- pack/unpack

## Block
- complete NTT
- complete INTT
- polynomial multiplication
- SHAKE stream generation

## Algorithm
- KEM KeyGen
- KEM Encaps
- KEM Decaps
- DSA KeyGen
- DSA Sign
- DSA Verify

## Integration
- mode switching
- parameter switching
- memory cleanup / zeroization
- back-to-back operations
- invalid/error flows

Use randomized differential testing wherever possible.

---

# 14. Security Considerations to Preserve

PPA is the primary optimization target, but implementation must not silently destroy security properties.

At minimum, architecture must leave room for:

- constant-time behavior where required
- secret-dependent control-flow review
- secret-dependent memory-access review
- zeroization
- key/state lifetime management
- fault/error handling
- side-channel countermeasures as optional/configurable design dimension

Adams Bridge and HOPE-MLKEM are useful references here.

Do not prematurely add expensive masking everywhere before a baseline PPA architecture exists, unless the project requirement explicitly demands a masked implementation.

---

# 15. What Has Been Done So Far

This project is currently at **pre-M0 / architecture research stage**.

Completed conceptually:

- Project goal defined:
  - one unified ML-KEM + ML-DSA IP
  - optimize PPA
- Key standards identified:
  - FIPS 203
  - FIPS 204
- High-value reference papers/repositories identified.
- Initial shared-block architecture proposed.
- Highest-value shared resources identified:
  - Keccak
  - NTT/INTT
  - modular arithmetic
  - polynomial memory
- Major modulus-width mismatch identified:
  - ML-KEM q=3329
  - ML-DSA q=8380417
- Candidate idea identified:
  - use wide DSA arithmetic hardware as multiple narrower KEM lanes
- Development milestone sequence proposed.
- Repository layout proposed.
- Initial PPA metrics proposed.

Not done yet:

- no repository has been created in this conversation
- no source repo has been cloned
- no FIPS pseudocode has been formally decomposed
- no operation-frequency table exists
- no cycle-accurate model exists
- no RTL exists
- no synthesis result exists
- no architecture candidate has been selected as final

---

# 16. Immediate Next Work — Highest Priority

Codex should begin with **M0**, not RTL integration.

## Task 1 — Create algorithm operation matrix

Create:

```text
docs/operation_matrix.md
```

For every top-level operation:

### ML-KEM
- KeyGen
- Encaps
- Decaps

### ML-DSA
- KeyGen
- Sign
- Verify

Break down recursively into:

```text
algorithm
→ function
→ polynomial/hash/sampler operation
→ arithmetic primitive
```

For each primitive record:

- input width
- output width
- modulus
- vector/poly length
- number of invocations
- dependencies
- memory footprint
- parallelism opportunity
- shareable between KEM/DSA?
- constant-time/security concern
- candidate architecture

This document should become the main architecture map.

---

## Task 2 — Create exact bit-width table

Create:

```text
docs/arithmetic_widths.md
```

Do not use approximate widths from this handoff as implementation truth.

Derive exact widths from FIPS/reference code for:

- coefficients
- products
- accumulated values
- Montgomery intermediates
- Barrett intermediates
- NTT butterfly inputs/outputs
- twiddle values
- compressed/encoded fields
- sampler intermediates

The objective is to avoid unnecessary wide datapaths.

---

## Task 3 — Bring up golden models

Clone/build trusted FIPS-aligned references.

Required tests:

```text
ML-KEM-768:
keygen
encaps
decaps

ML-DSA-65:
keygen
sign
verify
```

Add deterministic test-vector generation and intermediate dump support.

---

## Task 4 — Research comparison table

Create:

```text
docs/reference_architectures.md
```

Compare at least:

```text
Unified IEEE Access architecture
Adams Bridge
PQC OpenTitan
KiD
KaLi
GMUCERG/Dilithium
HOPE-MLKEM
```

Columns:

- technology / FPGA
- frequency
- LUT
- FF
- DSP
- BRAM
- ASIC area if available
- latency
- cycles
- algorithm/security level
- NTT architecture
- BFU count
- multiplier type
- reduction
- memory architecture
- Keccak architecture
- supports both KEM/DSA?
- side-channel countermeasures?
- source RTL available?

Normalize comparisons carefully; do not compare incomparable process nodes or devices without stating caveats.

---

# 17. Candidate First RTL Block

After M0 is complete, first RTL target should be the arithmetic subsystem, not the full accelerator.

Suggested path:

```text
rtl/arithmetic/mod_add.sv
rtl/arithmetic/mod_sub.sv
rtl/arithmetic/mod_reduce.sv
rtl/arithmetic/mod_mul.sv
rtl/arithmetic/butterfly.sv
```

Potential eventual interface:

```systemverilog
module pqc_mod_alu (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        mode,       // KEM / DSA
    input  logic [23:0] a,
    input  logic [23:0] b,
    input  logic [2:0]  op,

    input  logic        in_valid,
    output logic        in_ready,

    output logic [23:0] result,
    output logic        out_valid
);
```

This interface is only illustrative.

Do not freeze widths/protocol before `arithmetic_widths.md` and scheduling analysis are complete.

---

# 18. Instructions for Codex

When continuing this project:

1. **Do not invent algorithm constants.**
   Derive constants from FIPS 203/FIPS 204 or trusted FIPS-aligned reference implementations.

2. **Distinguish facts from architecture hypotheses.**
   Mark candidate ideas explicitly.

3. **Do not optimize by intuition alone.**
   For meaningful microarchitecture alternatives, synthesize or create a measurable cost model.

4. **Avoid duplicated hardware unless justified by throughput.**

5. **Preserve intermediate testability.**
   Every major block should expose enough hooks in simulation to compare against the golden model.

6. **Prefer parameterized RTL only where parameterization does not damage PPA.**
   Generic code is not automatically good silicon.

7. **Keep ML-KEM and ML-DSA schedules separately analyzable.**
   A unified datapath does not imply one giant controller.

8. **Record PPA after every architecture-changing optimization.**
   Never overwrite previous baseline reports.

9. **Use reproducible scripts.**
   Every simulation/synthesis report should be regenerable from a command/script.

10. **Do not begin full top-level implementation until the operation matrix and arithmetic/NTT design space are understood.**

---

# 19. Definition of Success

The project succeeds if it produces a standards-correct unified IP where hardware sharing yields a measurable PPA advantage versus reasonable alternatives.

At minimum compare against:

```text
A. two separate ML-KEM + ML-DSA accelerators
B. naïve fully-unified wide datapath
C. optimized unified architecture
```

Final claims should be supported by reproducible:

- functional verification
- synthesis
- timing
- power estimates
- cycle/latency measurements

The key research question is not merely:

> Can ML-KEM and ML-DSA share hardware?

It is:

> What is the most PPA-efficient degree and granularity of hardware sharing between FIPS 203 ML-KEM and FIPS 204 ML-DSA, especially for NTT, modular multiplication/reduction, Keccak, and polynomial memory?

---

# 20. Recommended Next Command for Codex

Start by creating the documentation and analysis skeleton only.

Suggested first objective:

```text
Create docs/operation_matrix.md from FIPS 203 and FIPS 204.

Requirements:
- cover ML-KEM KeyGen/Encaps/Decaps
- cover ML-DSA KeyGen/Sign/Verify
- recursively decompose each into hardware primitives
- include exact parameter/modulus/bit-width references
- identify shared vs algorithm-specific operations
- do not propose RTL until the operation matrix is complete
- cite the exact FIPS section or trusted source for each constant/operation
```

After this file is reviewed, proceed to `docs/arithmetic_widths.md` and the golden-model environment.

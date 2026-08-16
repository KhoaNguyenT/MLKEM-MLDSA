# Mydev_before legacy ML-KEM baseline

This directory contains an earlier ML-KEM hardware implementation supplied by the
project owner. It reportedly reached a completed build, but it has not yet been
reproduced or evaluated by the current harness.

## Usage policy

- Preserve this tree as a baseline; do not optimize it in place.
- Reuse blocks selectively only after functional and licensing/provenance review.
- Do not treat constants, interfaces, or behavior here as normative FIPS 203 truth.
- The unused historical `00_src/NTT_fail/` alternative was removed at the project
  owner's request; `00_src/NTT_INTT/` is the retained NTT/INTT implementation.
- Compile per target/block. The tree contains duplicate module names such as `top`,
  `test`, `NTT`, `BU`, and `Barret`, so compiling every RTL file together is invalid.

## Local EDA tools detected

- Verilator 5.032 in WSL: `/usr/bin/verilator`
- Vivado 2024.2 on Windows: `D:\vivado\Vivado\2024.2\bin\vivado.bat`

## Required before baseline implementation

- Confirm the intended top module and source list.
- Confirm the target FPGA part/board.
- Confirm the target clock period and clock/reset ports.
- Supply or reconstruct XDC constraints.
- Identify expected test vectors and pass/fail conditions.

See `docs/ppa_methodology.md` for the verification and PPA flow.

# ML-KEM and ML-DSA operation matrix

Status: in progress. This document is the active M0 research artifact and is not yet an implementation specification.

## Normative sources

- NIST FIPS 203: Module-Lattice-Based Key-Encapsulation Mechanism Standard
- NIST FIPS 204: Module-Lattice-Based Digital Signature Standard

Exact section and algorithm citations must be added while decomposing each operation. Reference implementations and architecture papers are secondary sources and must not override FIPS 203 or FIPS 204.

## Scope

### ML-KEM

- KeyGen
- Encaps
- Decaps

### ML-DSA

- KeyGen
- Sign
- Verify

## Required decomposition fields

For each operation, record:

- algorithm and function;
- polynomial, hash, sampler, or codec operation;
- arithmetic primitive;
- exact input and output widths;
- modulus and polynomial/vector dimensions;
- invocation count and dependencies;
- memory footprint and lifetime;
- available parallelism;
- ML-KEM/ML-DSA sharing potential;
- constant-time and memory-access concerns;
- candidate architecture, explicitly labeled as a hypothesis.

## Facts versus hypotheses

Normative algorithm behavior and constants belong in fact tables with exact citations. Hardware sharing, scheduling, lane splitting, memory banking, and multiplier choices are hypotheses until supported by a model, experiment, or synthesis result.

## Decomposition tables

TODO: Populate from FIPS 203 and FIPS 204 before proposing RTL.

# Vendor manifest

Vendor repositories are local shallow clones and are ignored by the parent Git
repository. Recreate them from the URL and pinned commit below. No vendor repository
is a normative replacement for FIPS 203 or FIPS 204.

## Golden implementations

| Local path | Upstream | Pinned commit | Clone mode |
|---|---|---|---|
| `golden/mlkem-native` | `https://github.com/pq-code-package/mlkem-native.git` | `69d24e37b8a04c6050ec55bc84a4228d7051bb4b` | shallow |
| `golden/mldsa-native` | `https://github.com/pq-code-package/mldsa-native.git` | `ae0c7d42a06998a0664fdae018aa255af032668c` | shallow |

## RTL and architecture references

| Local path | Upstream | Pinned commit | Clone mode |
|---|---|---|---|
| `reference/adams-bridge` | `https://github.com/chipsalliance/adams-bridge.git` | `516c78c58df04925576cec2cb1ad6bb25bd949c2` | shallow |
| `reference/pqc-opentitan-improving` | `https://github.com/PQC-OpenTitan/improving-ml-kem-and-ml-dsa-on-opentitan.git` | `a365cccc88fedc881317a1001d6b896484ca32a7` | partial + sparse (`sw/otbn/crypto`, `hw/ip/otbn`) |
| `reference/gmucerg-dilithium` | `https://github.com/GMUCERG/Dilithium.git` | `f929599178bb90fee157cb2f309b8266cdd42826` | shallow |
| `reference/hope-mlkem` | `https://github.com/HWSec-CSIC/hope-mlkem.git` | `72a90d80484d45d0bed1e0f9903bd0fb78cceb47` | shallow |

## Scope

- `mlkem-native` and `mldsa-native` are golden-model candidates for M0.
- The remaining repositories are architecture, RTL, verification, and PPA references.
- Their contents must be reviewed for version, parameter-set, license, and pre-FIPS
  differences before reuse.

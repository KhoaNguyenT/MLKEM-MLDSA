# Vendor repositories

Third-party repositories are shallow-cloned locally into:

- `golden/` for FIPS-aligned golden implementations.
- `reference/` for RTL and architecture references.

Clone contents are ignored by the parent repository. `MANIFEST.md` records upstream
URLs and checked-out commits so the environment can be reproduced.

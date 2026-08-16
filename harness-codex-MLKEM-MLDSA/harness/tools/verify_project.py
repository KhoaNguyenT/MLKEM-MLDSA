#!/usr/bin/env python3
"""Deterministic integrity checks for the pre-M0/M0 project and harness."""

from __future__ import annotations

import argparse
import json
import pathlib
import sys

REQUIRED_FEATURE_FIELDS = {
    "id", "priority", "area", "title", "user_visible_behavior",
    "status", "verification", "evidence", "notes",
}
VALID_STATUSES = {"not_started", "in_progress", "blocked", "passing"}
TOP_LEVEL_OPERATIONS = (
    "KeyGen", "Encaps", "Decaps", "Sign", "Verify",
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=pathlib.Path, required=True)
    parser.add_argument("--harness-root", type=pathlib.Path, required=True)
    parser.add_argument("--strict-active", action="store_true")
    args = parser.parse_args()

    project = args.project_root.resolve()
    harness = args.harness_root.resolve()
    errors: list[str] = []

    required_paths = [
        project / "AGENTS.md",
        project / "MLKEM_MLDSA_CODEX_HANDOFF.md",
        project / "docs" / "references" / "papers",
        harness / "AGENTS.md",
        harness / "feature_list.json",
        harness / "feature_list.schema.json",
        harness / "harness" / "config" / "harness.yaml",
    ]
    for path in required_paths:
        if not path.exists():
            errors.append(f"missing required path: {path}")

    feature_path = harness / "feature_list.json"
    features: list[dict] = []
    if feature_path.exists():
        try:
            payload = json.loads(feature_path.read_text(encoding="utf-8"))
            features = payload["features"]
            if not isinstance(features, list) or not features:
                errors.append("feature_list.json must contain a non-empty features array")
                features = []
        except (OSError, UnicodeError, json.JSONDecodeError, KeyError) as exc:
            errors.append(f"invalid feature_list.json: {exc}")

    ids: set[str] = set()
    active: list[dict] = []
    for index, feature in enumerate(features):
        missing = REQUIRED_FEATURE_FIELDS - set(feature)
        if missing:
            errors.append(f"feature[{index}] missing fields: {sorted(missing)}")
        feature_id = feature.get("id")
        if not isinstance(feature_id, str) or not feature_id:
            errors.append(f"feature[{index}] has invalid id")
        elif feature_id in ids:
            errors.append(f"duplicate feature id: {feature_id}")
        else:
            ids.add(feature_id)
        if feature.get("status") not in VALID_STATUSES:
            errors.append(f"feature {feature_id!r} has invalid status")
        if feature.get("status") == "in_progress":
            active.append(feature)
        if feature.get("status") == "passing" and not str(feature.get("evidence", "")).strip():
            errors.append(f"passing feature {feature_id!r} has no evidence")

    if len(active) != 1:
        errors.append(f"expected exactly one in_progress feature, found {len(active)}")

    if args.strict_active and active:
        doc = project / "docs" / "operation_matrix.md"
        if not doc.exists():
            errors.append(f"active feature artifact is missing: {doc}")
        else:
            text = doc.read_text(encoding="utf-8")
            for token in TOP_LEVEL_OPERATIONS:
                if token not in text:
                    errors.append(f"operation matrix missing token: {token}")
            for source in ("FIPS 203", "FIPS 204"):
                if source not in text:
                    errors.append(f"operation matrix missing normative source marker: {source}")

    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1

    print(f"PASS: harness integrity ({len(features)} features, active={active[0]['id']})")
    if args.strict_active:
        print("PASS: active feature artifact baseline")
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""gates.py — quality gates, fail-closed.

Every result runs through G1 -> G4 in order. If one fails, run_gates returns ok=False
and the orchestrator stops (fail-closed).

    computational : deterministic checks (parse, schema, test, linter)
    inferential   : semantic judgement (LLM-as-judge, see evaluator-rubric.md)

Each gate returns: {"id", "name", "type", "passed": bool, "detail": str}
Replace the gN_* bodies with your project's real checks.
"""
from __future__ import annotations


def g1_technical_validity(observation: str, action: dict) -> dict:
    passed = "OK" in observation   # TODO: real parse/compile check
    return {"id": "G1", "name": "technical_validity", "type": "computational",
            "passed": passed, "detail": "runs / parses / valid"}


def g2_structure(observation: str, action: dict) -> dict:
    return {"id": "G2", "name": "structure", "type": "computational",
            "passed": True, "detail": "correct format / schema"}


def g3_verification(observation: str, action: dict) -> dict:
    return {"id": "G3", "name": "verification", "type": "computational",
            "passed": True, "detail": "tests / checks pass"}


def g4_semantic_review(observation: str, action: dict) -> dict:
    return {"id": "G4", "name": "semantic_review", "type": "inferential",
            "passed": True, "detail": "matches intent"}


GATE_ORDER = [g1_technical_validity, g2_structure, g3_verification, g4_semantic_review]


def run_gates(observation: str, action: dict) -> tuple[bool, list[dict]]:
    """Run gates in order, fail-closed: stop at the first failure."""
    results: list[dict] = []
    for gate in GATE_ORDER:
        r = gate(observation, action)
        results.append(r)
        if not r["passed"]:
            return False, results
    return True, results


if __name__ == "__main__":
    ok, res = run_gates("[demo] tool OK", {"tool": "write_file", "args": {}})
    print("PASS" if ok else "FAIL")
    for r in res:
        mark = "ok" if r["passed"] else "x"
        print(f"  {r['id']} ({r['type']}): [{mark}] {r['detail']}")

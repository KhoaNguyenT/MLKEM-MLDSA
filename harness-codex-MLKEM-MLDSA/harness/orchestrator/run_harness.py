#!/usr/bin/env python3
"""
run_harness.py â€” Orchestrator (Captain driver) for the harness skeleton.

Location: <project-root>/harness/orchestrator/run_harness.py
Layout:
    <project-root>/
      AGENTS.md  init.sh  feature_list.json
      harness/{config,agents,tools,gates,memory,state,runs,docs}

Loop: Thought -> Action -> Observation, with gates (harness/gates/gates.py)
and human-in-the-loop approval on high-risk actions.

DEMO mode: scripted planner + mock tools. Reads feature_list.json to choose the active
feature, runs the ReAct loop (triggering one HITL approval + the gates), and writes
artifacts ONLY under harness/runs/<run_id>/ â€” it never edits the shipped memory/ or
state/ templates. Replace the TODO hooks (plan / execute_tool) with your model + tools.

    python run_harness.py     # uses the active feature from feature_list.json
"""
from __future__ import annotations
import sys, json, pathlib, datetime, fnmatch, uuid

HERE = pathlib.Path(__file__).resolve()
HARNESS_DIR = HERE.parents[1]          # .../harness-codex-MLKEM-MLDSA/harness
HARNESS_PACKAGE_ROOT = HERE.parents[2] # .../harness-codex-MLKEM-MLDSA
PROJECT_ROOT = HARNESS_PACKAGE_ROOT.parent
FEATURE_LIST_PATH = HARNESS_PACKAGE_ROOT / "feature_list.json"
sys.path.insert(0, str(HARNESS_DIR / "gates"))
import gates as gatemod                # run_gates(observation, action) -> (ok, results)

# HITL policy (mirror of config/harness.yaml; inline so the demo has no deps)
APPROVAL_PATTERNS = ["write_*", "promote_*", "delete_*", "deploy_*"]
CONF_THRESHOLD = 0.6


def now() -> str:
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def load_feature() -> dict:
    """Active feature = the one in_progress, else lowest-priority not_started."""
    try:
        feats = json.loads(FEATURE_LIST_PATH.read_text(encoding="utf-8")).get("features", [])
    except Exception:
        feats = []
    inprog = [f for f in feats if f.get("status") == "in_progress"]
    if inprog:
        return inprog[0]
    todo = sorted([f for f in feats if f.get("status") == "not_started"],
                  key=lambda f: f.get("priority", 999))
    return todo[0] if todo else {"id": "demo-feature", "title": "demo"}


def plan(feature: dict, step: int) -> dict:
    """TODO: call the model with the Captain/specialist instructions. DEMO: scripted."""
    fid = feature.get("id", "feature")
    scripted = [
        {"type": "tool", "tool": "read_spec", "args": {"feature": fid},
         "confidence": 0.9, "thought": f"Read context for feature '{fid}'."},
        {"type": "tool", "tool": "write_rtl", "args": {"feature": fid, "path": "out/artifact"},
         "confidence": 0.55, "thought": "Produce artifact â€” write action, high-risk."},
        {"type": "finish", "tool": None, "args": {},
         "confidence": 0.95, "thought": "Artifact passed gates. Done."},
    ]
    return scripted[min(step, len(scripted) - 1)]


def execute_tool(action: dict) -> str:
    """TODO: dispatch to a real tool in harness/tools/. DEMO: mock observation."""
    return f"[demo] tool '{action['tool']}' OK args={action['args']}"


def needs_approval(action: dict) -> tuple[bool, str]:
    if action["type"] != "tool":
        return False, ""
    for pat in APPROVAL_PATTERNS:
        if fnmatch.fnmatch(action["tool"], pat):
            return True, f"high-risk action matches '{pat}'"
    if action.get("confidence", 1.0) < CONF_THRESHOLD:
        return True, f"confidence {action['confidence']} < {CONF_THRESHOLD}"
    return False, ""


def run() -> dict:
    feature = load_feature()
    run_id = datetime.datetime.now().strftime("%Y%m%dT%H%M%S") + "-" + uuid.uuid4().hex[:6]
    run_dir = HARNESS_DIR / "runs" / run_id
    run_dir.mkdir(parents=True, exist_ok=True)
    logf = open(run_dir / "run.log", "w", encoding="utf-8")

    def log(m: str) -> None:
        line = f"[{now()}] {m}"
        print(line)
        logf.write(line + "\n")

    state = {"run_id": run_id, "feature": feature.get("id"), "status": "running",
             "step": 0, "hitl_log": []}
    trace = {"schema": "1.1", "run_id": run_id, "feature": feature.get("id"),
             "started": now(), "steps": []}
    log(f"START {run_id} â€” feature: {feature.get('id')} â€” {feature.get('title', '')}")

    result = "incomplete"
    for step in range(12):
        state["step"] = step
        action = plan(feature, step)                              # 1) Thought
        log(f"[{step}] THOUGHT: {action['thought']}")
        rec = {"step": step, "thought": action["thought"], "action": action,
               "hitl": None, "gates": [], "observation": None}

        if action["type"] == "finish":
            result = "success"
            log(f"[{step}] FINISH")
            trace["steps"].append(rec)
            break

        need, reason = needs_approval(action)                     # 2) HITL?
        if need:
            log(f"[{step}] HITL required: {reason}")
            decision = "approve"   # DEMO auto-approve; production: pause & wait for human
            rec["hitl"] = {"reason": reason, "decision": decision,
                           "reviewer": "demo", "tool_args": action["args"], "at": now()}
            state["hitl_log"].append(rec["hitl"])
            log(f"[{step}] HITL decision={decision} (demo auto-approve)")

        obs = execute_tool(action)                                # 3) Action -> Observation
        rec["observation"] = obs
        log(f"[{step}] ACTION {action['tool']} -> {obs}")

        ok, gres = gatemod.run_gates(obs, action)                 # 4) Gates (fail-closed)
        rec["gates"] = gres
        if not ok:
            failed = [g["id"] for g in gres if not g["passed"]]
            log(f"[{step}] GATES FAILED {failed} -> stop (fail-closed)")
            state["status"] = "gate_failed"
            trace["steps"].append(rec)
            break
        log(f"[{step}] GATES OK")
        trace["steps"].append(rec)

    state["status"] = "done" if result == "success" else state["status"]
    trace["finished"] = now()
    trace["result"] = state["status"]
    (run_dir / "trace.json").write_text(json.dumps(trace, ensure_ascii=False, indent=2), encoding="utf-8")
    (run_dir / "state.snapshot.json").write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")
    log(f"END {run_id} â€” status: {state['status']}")
    logf.close()
    print(f"\nArtifacts written under: harness/runs/{run_id}/")
    return state


if __name__ == "__main__":
    run()

"""example_tool.py — a tool stub.

A tool = SCHEMA (so the loop knows how to call it and whether it needs approval)
plus a run() function.
"""
from __future__ import annotations

SCHEMA = {
    "name": "write_file",
    "description": "Write a file to disk at `path`.",
    "category": "action",
    "params": {"path": "str", "content": "str"},
    "needs_approval": True,
}


def run(path: str, content: str) -> dict:
    # TODO: implement the real action (write file, run command, call API, ...).
    return {"ok": True, "path": path, "bytes": len(content)}


if __name__ == "__main__":
    print(run("out/example.txt", "hello"))

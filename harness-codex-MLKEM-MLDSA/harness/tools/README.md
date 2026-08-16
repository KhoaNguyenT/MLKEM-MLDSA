# Tools

Tools let agents act on the project: an agent decides, a tool executes.

## Categories
- data          — read context (files, search, DB).
- action        — change something (write files, run commands).
- orchestration — call another agent as a tool.

## Tool convention
Each tool declares a schema so the loop knows how to call it and whether it needs
approval:

    SCHEMA = {
        "name": "write_file",
        "description": "Write a file to disk.",
        "category": "action",
        "params": {"path": "str", "content": "str"},
        "needs_approval": True,
    }

## Project tools (fill in)
| Tool (path) | Category | Purpose | How to invoke |
|-------------|----------|---------|----------------|
| <path>      | data / action | <purpose> | `<command>` |

See `example_tool.py` for a stub.

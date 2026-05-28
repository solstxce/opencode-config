# opencode-config

```
    __         ___     
   / /_  ___  / (_)  __
  / __ \/ _ \/ / / |/_/
 / / / /  __/ / />  <  
/_/ /_/\___/_/_/_/|_|   
```

Personal configuration and agent definitions for [opencode](https://opencode.ai) — the AI coding assistant.

## What's inside

| Path | Purpose |
|---|---|
| `opencode.json` | Main config: agents, models, permissions, defaults |
| `prompts/` | System prompts for each agent (general, coding, plan, explore, executor) |
| `skills/` | Custom skill definitions (code-review, planning, simplify) |
| `commands/` | Custom slash commands |
| `.gitignore` | Ignored paths (node_modules, etc.) |

## Agent workflow

```
You → general (cheap orchestrator)
        │
        ├── build (mid model, coding)
        │     ├── explore (cheap, file search)
        │     ├── executor (cheap, bash/tests)
        │     ├── reviewer (mid-high, review)
        │     └── expert-reviewer (premium, deep review)
        │
        └── plan (premium, task breakdown)
```

Cheap models for orchestration and tool calls, stronger models for coding and deep analysis. Every model has a job.

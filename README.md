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
        ├── build (big-pickle, coding)
        │     ├── explore (flash-free, file search)
        │     ├── executor (flash-free, bash/tests)
        │     ├── reviewer (mimo-v2.5-free, review)
        │     └── expert-reviewer (gpt-5.5, deep review)
        │
        └── plan (gpt-5.5, task breakdown)
```

### Model map

| Agent | Model | Tier |
|---|---|---|
| `general` | opencode/deepseek-v4-flash-free | free |
| `build` | opencode/big-pickle | free |
| `plan` | openai/gpt-5.5 | premium |
| `explore` | opencode/deepseek-v4-flash-free | free |
| `executor` | opencode/deepseek-v4-flash-free | free |
| `reviewer` | opencode/mimo-v2.5-free | free |
| `expert-reviewer` | openai/gpt-5.5 | premium |

All free-tier models, with gpt-5.5 reserved for planning and expert review.

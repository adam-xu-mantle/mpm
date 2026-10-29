# mpm

A [Claude Code](https://claude.com/claude-code) skill that manages one requirement's development, stage by stage, from research to self-test.

## What it does

Each requirement gets a working directory with an `mpm.md` file at the root that tracks progress. Development runs through four stages, each with its own directory and main document:

| Stage | Directory | Outputs |
|---|---|---|
| 01-Requirements | `01-requirements/` | Industry research and requirement design, each in a detail version (for later agents) and a brief version (for humans); external data; daily research logs |
| 02-Design | `02-design/` | Technical design |
| 03-Development | `03-development/` | Code lives in the repositories and feat branches listed in `mpm.md` |
| 04-Self-Test | `04-self-test/` | Test cases and results |

How it works:

- **The main session only orchestrates.** Each stage's work goes to a dedicated stage agent. After every change, a separate review agent checks for loose ends and writes its result to `<stage dir>/reviews/`. If the review fails, the stage agent fixes the issues and the work is reviewed again.
- **A stage is done only when you confirm it.** When the agent thinks the next stage can start, it asks you first.
- **Requirement changes propagate downstream** to design, development, and self-test if those stages have started.
- **Rollback is supported.** Depending on the cause, work rolls back to requirements or to design.
- **Daily industry research** runs `claude -p` on a macOS launchd schedule. Results go only to the research log and a "Findings To Discuss" list — never directly into the requirement documents. You decide whether to change requirements after discussing them.
- **Every time you open Claude Code** in a directory with `mpm.md`, it first verifies the actual progress of each stage, reports it, then asks whether to continue with the next task.

mpm only activates when the current directory or a parent contains `mpm.md`; other projects are unaffected.

## Install

Requires Claude Code and `jq`. Daily research requires macOS.

```bash
git clone https://github.com/adam-xu-mantle/mpm.git
cd mpm
bash install.sh          # install by copying
bash install.sh --link   # or install via symlinks, so edits to this repo take effect immediately
```

`install.sh`:

1. Installs `skills/mpm` and `skills/mpm-create` into `~/.claude/skills/`. Existing directories with the same name are moved to `~/.claude/skills-backup/<timestamp>/`.
2. Adds a SessionStart hook to `~/.claude/settings.json` that checks for `mpm.md` on startup, resume, and `/clear`. The original file is backed up first; if the hook is already present, this step is skipped.

## Usage

```bash
mkdir my-feature && cd my-feature
claude
> /mpm-create
```

`/mpm-create` asks for the requirement summary, acceptance criteria, code repositories, feat branches, Lark/Feishu doc links, and the daily research time, then generates `mpm.md` and the four stage directories. From then on, whenever you open Claude Code in this directory and send any message (e.g. "continue"), you get a progress report first.

Managing the daily research job:

```bash
bash ~/.claude/skills/mpm/scripts/research-job.sh install   <working dir> [hour] [minute]
bash ~/.claude/skills/mpm/scripts/research-job.sh status    <working dir>
bash ~/.claude/skills/mpm/scripts/research-job.sh run       <working dir>   # run once now
bash ~/.claude/skills/mpm/scripts/research-job.sh uninstall <working dir>
```

## Files

```
skills/mpm/
  SKILL.md            Main workflow: session start check, stage work loop, change propagation, rollback, research rules
  stages.md           Outputs and completion criteria for each stage
  agent-prompts.md    Prompt templates for the stage, review, and progress-check agents
  daily-research.md   Instructions for the daily research agent
  scripts/
    session-start.sh  SessionStart hook: detects mpm.md
    research-job.sh   Manages the daily research launchd job
skills/mpm-create/
  SKILL.md            Initialization workflow
  templates/mpm.md    mpm.md template
  scripts/scaffold.sh Generates the directory skeleton (never overwrites existing files)
```

## Known limitations

- Claude Code can't speak before you do, so the progress report appears after your first message.
- Daily research depends on launchd and only works on macOS. When running unattended it can write only to `research-log/`, `research-data/`, and `01-requirements/README.md`.

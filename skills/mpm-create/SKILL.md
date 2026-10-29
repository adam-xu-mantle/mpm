---
name: mpm-create
description: Use when the user runs /mpm-create or asks to initialize mpm (create mpm.md and stage directories) for a new requirement in the current directory.
---

# mpm-create: Initialize an mpm Working Directory

Set up an mpm working directory in the current directory: `mpm.md`, four stage directories, and their main documents. After setup, the mpm skill takes over.

## Steps

1. **Check.** If the current directory already has `mpm.md`, stop and tell the user. Do not overwrite.
2. **Collect information.** Don't ask again for anything the user already gave. If the requirement name is missing, derive one from the summary and mention it in the step 6 report instead of asking. Ask for everything else that's missing in a single message:
   - Requirement name and a one- or two-sentence summary;
   - Acceptance criteria (a rough version is fine; stage 01 refines them);
   - Code repository directories (can be several) and what each is for;
   - Main feat branch name (may differ per repository);
   - Related Lark/Feishu document links (requirement review, design docs, etc.), or none;
   - Time for the daily research job (default 09:07 daily), or no daily research.
3. **Verify code repositories.** Confirm each directory exists and is a git repository. If a feat branch doesn't exist, note it and tell the user in step 6 — don't create branches yourself.
4. **Generate files.** Run:
   ```bash
   bash ~/.claude/skills/mpm-create/scripts/scaffold.sh <current dir>
   ```
   The script copies the templates and skips files that already exist. Then fill every `<...>` placeholder in `mpm.md` with the information from step 2, writing today's date into the 01-Requirements status and the Session Handoff Log. Write the filled-in content in the user's language.
5. **Install the daily research job** (skip if the user doesn't want it):
   ```bash
   bash ~/.claude/skills/mpm/scripts/research-job.sh install <current dir> <hour> <minute>
   ```
6. **Report and hand off to mpm.** Tell the user which files were created, the scheduled job status, and any problems found in step 3. Then load the mpm skill and ask: "Start 01-Requirements with industry research?"

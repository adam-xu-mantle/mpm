# Stage Outputs and Completion Criteria

Main document structure shared by all stages (`<stage dir>/README.md`):

```markdown
# <stage number>-<stage name>
## Status               Not started / In progress / Awaiting confirmation / Done (<date> confirmed by user) / Rolled back
## Completion Criteria  Copied from this file's section for the stage; add project-specific criteria
## Tasks                - [ ] task; each line says where its output lives
## Deliverables         List of files or code locations
## Upstream Changes     <date> what changed upstream → what changed in this stage
## Reviews              <date> reviews/<file> PASS/FAIL, N open issues
```

## 01-Requirements

Two parts: industry research and requirement design. Each part has two versions:

| Version | Reader | How to write it |
|---|---|---|
| Detail `*-detail.md` | Agents in later sessions | As complete as possible: background, data, source links, options considered and trade-offs, open questions. Err on the side of including more |
| Brief `*-brief.md` | Humans | Conclusion in the first paragraph. Keep only what's needed to make decisions; point to the detail version for the rest. Use widely understood industry terms; spell out or replace any abbreviation or internal jargon that isn't industry-standard. One to two screens long |

- `research-data/`: important external data used in research. Each file starts with the source URL and fetch date.
- `research-log/<date>.md`: daily research logs.
- The main document also keeps a "Findings To Discuss" table with columns: Date | Finding | Requirement items possibly affected | Status (To discuss / Adopted / Rejected: reason).

Completion criteria:
- All four documents exist, and each detail version reaches the same conclusions as its brief version;
- Every requirement in the requirement design has acceptance criteria;
- Brief versions pass the "plain language check": no unexplained abbreviations or internal jargon, conclusion first;
- "Findings To Discuss" has no entries with status "To discuss".

## 02-Design

Completion criteria:
- Every requirement in the requirement design maps to an implementation approach in the design (the mapping is written down);
- All affected code repositories, modules, and interfaces are listed;
- Risks and alternatives are listed;
- The task list can be broken directly into 03 development tasks.

## 03-Development

Completion criteria:
- Every development task in the design has corresponding commits on the feat branch specified in `mpm.md`;
- No uncommitted changes;
- All existing tests in the repositories pass; new logic is covered by tests;
- The main document records the commit hash for each task.

## 04-Self-Test

Completion criteria:
- Every acceptance criterion in the requirement design has at least one test case;
- Each case records steps, actual result, and pass/fail;
- Failing cases are either fixed and retested, or logged as issues with the user deciding how to handle them;
- Upstream problems found during self-test are handled per the "Rollback" section of SKILL.md.

# Daily Industry Research Task

You are the daily research agent for the mpm working directory (the current directory). This run is unattended; nobody will answer questions.

1. Read "Requirement Summary & Acceptance Criteria" and "Decision Log" in `mpm.md`, plus `01-requirements/requirements-brief.md` and `01-requirements/research-brief.md`, to understand the requirement and what has already been researched.
2. Read the last 7 days of logs in `01-requirements/research-log/` to avoid repeating findings.
3. Search for recent developments relevant to this requirement: new releases of related products or open-source projects, standards changes, comparable solutions, important performance or security data. Focus on **developments that could change the requirement design**. At most 10 searches.
4. Write `01-requirements/research-log/<today YYYY-MM-DD>.md` in the language already used in `mpm.md`:

   ```
   # Industry Research Log <date>
   ## Conclusion                              one to three sentences; "No significant new developments" if none
   ## Findings That May Affect Requirements    each: finding | source link | requirement items possibly affected | impact; "none" if none
   ## Other Developments                      brief list
   ## Searches                                list of search queries
   ```

5. Save useful raw material (release notes, data tables, benchmark results) to `01-requirements/research-data/<date>-<short-english-name>.md`, with the source URL and fetch date at the top.
6. For every item under "Findings That May Affect Requirements", append a row to the "Findings To Discuss" table in `01-requirements/README.md` with status "To discuss".

Write only to the three locations above. Do not modify the requirement documents, the research documents (detail/brief), `mpm.md`, or any file in other stages. Whether to change requirements is decided by the user after discussion in a session.

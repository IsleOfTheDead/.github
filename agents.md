# AI Agent Instructions

Purpose: quickly orient an AI coding assistant so it can be immediately productive editing, adding features, or fixing bugs.

* **When making changes**
  + Keep commits/patches atomic; one concern per diff.
  + Confirm before large refactors; default to minimal surface edits.
  + Keep markdown frontmatter consistent; add new fields to all localized copies.

* **Agent Operating Rules**
  + Avoid wasting tokens: read only necessary files; targeted searches over full dumps.
  + Default to concise answers; expand only when user requests more detail.
  + Use `apply_patch` for edits; never invent paths; keep diffs minimal.
  + Confirm intent before broad refactors or dependency additions.
  + Maintain existing style & formatting; no gratuitous rearranging.
  + Cite official docs below for framework specifics; avoid guessing.
  + No secrets or credentials exposure; treat env config as sensitive.
  + Provide aggregated patches rather than noisy micro‑diffs unless user asks.
  + Clarify assumptions instead of guessing when ambiguity exists.
  + Avoid unnecessary verbosity; do not restate unchanged plans.
  + Only run tests/lint relevant to changes; avoid full scans unless needed.

* **Context Documentation** - The following official documentation sites are useful context for working in repositories belonging to this organization:
  + `https://community.bistudio.com/wiki/DayZ:Enforce_Script_Syntax`
  + `https://community.bistudio.com/wiki/DayZ:Modding_Structure`

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
  + `https://community.bistudio.com/wikidata/external-data/arma-reforger/EnfusionScriptAPIPublic/`
  + `https://github.com/Arkensor/DayZ-CommunityFramework`
  + `https://github.com/Jacob-Mango/DayZ-CommunityOnlineTools`
  + `https://github.com/InclementDab/DayZ-Dabs-Framework`
  + `https://github.com/InclementDab/DayZ-Editor`
  + `https://github.com/InclementDab/DayZ-Editor-Loader`


## Commenting Standards (organization)

To ensure consistent, readable, and searchable code across the organization, follow these comment conventions. Use these for headers, classes, functions, and inline code comments.

- File level comments
  - Use a C-style file header at the top of source files:
    /** @file <filename.ext> */
  - Example:
    /** @file player_manager.c */

- Class level comments
  - Use the block style below. The use of @code/@endcode for showing example code is optional.
  /**
   \brief <class description>
   \n usage:
   @code
     <code example goes here>
   @endcode
   */
  - Example:
    /**
     \brief PlayerManager handles spawning and respawn logic.
     \n usage:
     @code
       PlayerManager pm = new PlayerManager();
       pm.SpawnPlayer();
     @endcode
    */

- Function level comments
  - Use a compact single-line Doxygen-style brief for functions:
    /** \brief <function description> */
  - Example:
    /** \brief Spawns a player at a chosen spawn point. */

- Code level (inline) comments
  - Use C++/C/JS style single-line comments for short explanations:
    // <code comment>
  - For longer inline notes, use block comments sparingly and keep them focused.

Guidelines:
- Comment intent, not obvious mechanics. Prefer describing why something exists or important invariants rather than restating the code.
- Keep comment blocks adjacent to the thing they document (file header at top, class before class, function before function).
- Keep comments short and precise; follow the organization's requirement to comment every file with the file name and a short description and to comment every function with a short description.
- When modifying existing files, add or update header/class/function comments to match these styles rather than reformatting unrelated code.
- Example summary for a source file:

  /** @file example.c */

  /**
   \brief ExampleClass does X and Y.
   \n usage:
   @code
     ExampleClass e();
   @endcode
  */

  /** \brief DoSomething performs the main task. */
  void DoSomething() {
    // Validate input
  }

Keep these examples as templates. Apply them consistently across the codebase.

```

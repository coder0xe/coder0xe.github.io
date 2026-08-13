# Local Blog Writing Environment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make drafting, previewing, and validating this Hugo blog available through short, documented local commands.

**Architecture:** Keep Hugo as the only project tool and wrap its existing CLI in a small `Makefile`. Use Hugo's archetype system for consistent front matter, a portable shell smoke test for the command contract, and EditorConfig for repository-wide text defaults.

**Tech Stack:** Hugo Extended, GNU Make, POSIX shell, Markdown, TOML

---

### Task 1: Define and test the writing command contract

**Files:**
- Create: `tests/writing-tools.sh`
- Create: `Makefile`

- [ ] Add a portable shell smoke test which injects a fake Hugo executable and verifies the `doctor`, `new`, `serve`, and `build` command arguments.
- [ ] Run `./tests/writing-tools.sh` and confirm it fails because the writing commands do not exist yet.
- [ ] Add `make help`, `make doctor`, `make new POST=<slug>`, `make serve`, `make build`, `make check`, and `make test` targets.
- [ ] Run `./tests/writing-tools.sh` and confirm every command-contract assertion passes.

### Task 2: Make generated drafts ready for writing

**Files:**
- Modify: `archetypes/default.md`
- Create: `.editorconfig`

- [ ] Extend the default archetype with empty array values for `tags`, `categories`, and `keywords`, plus an empty description and `draft = true`.
- [ ] Add UTF-8, LF, final-newline, indentation, and Markdown trailing-space rules in `.editorconfig`.
- [ ] Generate a post with a temporary content directory and verify Hugo renders valid front matter without changing tracked content.

### Task 3: Document the daily workflow

**Files:**
- Modify: `README.md`
- Modify: `README.en.md`

- [ ] Document prerequisites and `make doctor`.
- [ ] Document the draft loop: `make new POST=my-first-post`, edit Markdown, add `/img/...` assets, and run `make serve`.
- [ ] Document `make check` and changing `draft = true` to `draft = false` before publication.
- [ ] Keep the direct Hugo commands as troubleshooting equivalents.

### Task 4: Verify with the real toolchain

**Files:**
- Verify only; no source changes required.

- [ ] Run `make test`.
- [ ] Run `make doctor` with Hugo Extended installed.
- [ ] Run `make check` and confirm the full production build succeeds.
- [ ] Review `git diff --check` and `git status --short` before handoff.

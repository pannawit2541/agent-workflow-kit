# Agent Workflow Kit — AI Configuration

This directory is an **AI management root** that can wrap any project. It orchestrates git
worktrees, OpenSpec planning, shared reference material, and knowledge docs. It is project-agnostic:
the project it manages is whatever you clone into `worktree/`.

## Directory Layout

```
agent-workflow-kit/        ← You are here (AI management root)
├── AGENTS.md              ← This file
├── README.md
├── .gitignore
├── scripts/
│   ├── worktree.sh        ← Worktree management helper
│   └── openspec.sh        ← OpenSpec management helper
├── docs/
│   └── local-workflow.md  ← Local branch / worktree / OpenSpec workflow
├── shared/                ← Reference source/lib drop-zone (gitignored except README)
├── openspec/              ← Spec-driven planning (never commit into the project repo)
├── .claude/              ← Claude Code skills + commands (OpenSpec /opsx:*)
├── .codex/               ← Codex skills
└── worktree/
    ├── config.yaml        ← `main:` = name of the main worktree directory
    └── <main>/            ← [main] project checkout
```

## Project Identity

- The managed project's main worktree is `worktree/<main>`.
- `<main>` is read from the `main:` key in `worktree/config.yaml`.
- One-time setup: set `main:` and run `git clone <repo-url> worktree/<main>`.

## Git Worktree Rules

- All worktrees live under `worktree/`.
- Use `./scripts/worktree.sh add --new <branch> [name]` to create a new branch + worktree.
- Use `./scripts/worktree.sh add <branch> [name]` to attach an existing branch.
- Use `./scripts/worktree.sh list` to see all worktrees, `prune` to clean stale registrations,
  and `remove <name>` to delete one.
- The main worktree (`worktree/<main>`) stays on its default branch.
- **NEVER** commit changes from this management root — only commit code inside `worktree/*`.

## OpenSpec Rules

- OpenSpec planning lives at `openspec/` in this root.
- **NEVER** commit `openspec/` into the project repo — it is local planning only.
- Use `./scripts/openspec.sh status` / `list` to inspect state, `clean` to empty it, `reset` to
  re-init.
- Use `/opsx:propose "description"` to create a proposal, `/opsx:apply` to implement, and
  `/opsx:archive` to archive completed work.

## Shared Reference Material

- `shared/` is a local drop-zone for reference source code and open-source libraries the agent
  should read while implementing a feature.
- Contents of `shared/` are gitignored (only `shared/README.md` is committed).
- It is reference material, not application code.

## Commit Rules

- Only commit actual code changes inside `worktree/*/`.
- **NEVER** commit `openspec/` artifacts or `shared/` contents into the project repo.

## When Working on a Task

1. Identify which worktree to work in (usually `worktree/<main>` or a feature worktree).
2. Read the **target project's own** `AGENTS.md` / coding standards before writing code.
3. Read `docs/local-workflow.md` for branch, worktree, review, and testing expectations.
4. For larger features, plan with OpenSpec (`/opsx:propose`).
5. Implement in the correct worktree.
6. Run the project's tests / lint before committing.
7. Only commit code files — never planning or reference artifacts.

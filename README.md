# agent-workflow-kit

A project-agnostic **AI management root**. Drop it next to any project so an AI agent can drive work
through git worktrees and OpenSpec, with shared reference material and knowledge docs on hand.

## Layout

```
agent-workflow-kit/
├── AGENTS.md              ← Guide for AI agents working in this root
├── scripts/
│   ├── worktree.sh        ← Git worktree management
│   └── openspec.sh        ← OpenSpec planning lifecycle
├── docs/
│   └── local-workflow.md  ← Branch / worktree / OpenSpec workflow
├── shared/                ← Reference source/lib drop-zone (gitignored except README)
├── openspec/              ← Spec-driven planning (local only)
├── .claude/ , .codex/     ← OpenSpec skills + commands
└── worktree/
    ├── config.yaml        ← `main:` = main worktree directory name
    └── <main>/            ← your project checkout
```

## Quickstart

1. **Point the kit at your project.** Edit `worktree/config.yaml` and set `main:` to the directory
   name you want for the main checkout:

   ```yaml
   main: my-project
   ```

2. **Clone your project into the worktree:**

   ```bash
   git clone <repo-url> worktree/my-project
   ```

3. **Create a feature worktree:**

   ```bash
   ./scripts/worktree.sh add --new feature/api/my-feature my-feature
   cd worktree/my-feature
   ```

4. **Plan with OpenSpec** (optional, for larger work): use `/opsx:propose`, `/opsx:apply`,
   `/opsx:archive`. Inspect state with `./scripts/openspec.sh status`.

See `docs/local-workflow.md` for the full workflow and `AGENTS.md` for agent rules.

## Requirements

- `git` (with worktree support)
- [OpenSpec CLI](https://www.npmjs.com/package/@fission-ai/openspec) for OpenSpec commands:
  `npm install -g @fission-ai/openspec@latest`

# Local Workflow

This document describes the expected local workflow for working in this AI management root and the
project worktree under `worktree/`.

## Management Root vs Project Worktree

- Use this root for workflow helpers (`scripts/`), reference material (`shared/`), knowledge docs
  (`docs/`), and OpenSpec planning artifacts (`openspec/`).
- Do application work inside a git worktree under `worktree/`.
- The main project worktree is `worktree/<main>`, where `<main>` is the `main:` value in
  `worktree/config.yaml`.
- **Do not commit from this management root.** Only commit code inside `worktree/*`.

## One-Time Setup

1. Set `main:` in `worktree/config.yaml` to the directory name for your project's main checkout.
2. Clone your project into it:

   ```bash
   git clone <repo-url> worktree/<main>
   ```

## Branch Naming

Use branch names that show the primary scope of the work:

- `feature/api/<slug>` for backend, API, migration, entity, DTO, controller, or service work
- `feature/app/<slug>` for frontend, page, component, or client-side work
- `feature/<slug>` for cross-cutting or general work that does not fit a single app/api scope

Examples:

```text
feature/api/add-summary-report-endpoints
feature/app/add-summary-report-tab
feature/improve-local-workflow-docs
```

## Create a New Worktree

Create new worktrees from this management root with `scripts/worktree.sh`.

Create a new API-focused branch and worktree:

```bash
./scripts/worktree.sh add --new feature/api/add-summary-report-endpoints summary-report-api
cd worktree/summary-report-api
```

Create a new app-focused branch and worktree:

```bash
./scripts/worktree.sh add --new feature/app/add-summary-report-tab summary-report-app
cd worktree/summary-report-app
```

Notes:

- The worktree directory name is optional; if omitted it defaults to the branch basename.
- New branches are created from `origin/main` unless a different base is passed as the third argument.
- Existing branches can be attached with `./scripts/worktree.sh add <branch> [name]`.
- `.env` files from the main worktree are copied into the new worktree automatically.

## Local Delivery Flow

1. Create a correctly scoped branch and worktree.
2. Enter the worktree and implement the change there.
3. Let any local pre-commit hooks run before each commit.
4. Push the branch and open a merge/pull request for review.
5. Use CI as the authoritative automated validation gate.

## Planning with OpenSpec

For larger features, plan with OpenSpec before implementing:

- `./scripts/openspec.sh status` — check current state (active changes, specs, archive).
- Use `/opsx:propose "description"` to create a new proposal.
- Use `/opsx:apply` to implement it inside the worktree.
- Use `/opsx:archive` once complete.

OpenSpec artifacts live under `openspec/` in this root and are **never committed** into the project
repo — they are local planning documents only.

## Reference Material

Drop reference source code or open-source libraries into `shared/` so the agent can read them while
implementing. See `shared/README.md`. Contents of `shared/` are gitignored.

## Code Review Expectations

Every proposal or implementation should call out:

- the primary subsystem being changed
- the main regression risks
- any generated files or migrations reviewers should inspect carefully
- any explicit non-goals to keep review scope clear

For cross-cutting changes, separate review focus by subsystem instead of describing the work as a
generic improvement.

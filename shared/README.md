# shared/

Local **reference drop-zone** for source code and open-source libraries you want the AI agent to
read while implementing a feature.

## What goes here

- Clones of open-source repos whose implementation you want to mirror or learn from.
- Snapshots of internal libraries / SDKs that the target project depends on.
- Any reference source code that helps an agent understand an API, pattern, or contract.

## Rules

- Contents of `shared/` are **gitignored** — only this `README.md` is committed.
- This is reference material, not application code. Implement actual changes inside a worktree
  under `worktree/`, never here.
- Drop things in freely; clean them up when no longer needed.

## Example

```bash
git clone https://github.com/some-org/some-lib shared/some-lib
# Now point the agent at shared/some-lib while implementing the feature.
```

---
name: sync-upstream
description: Sync this fork (alandy88/skills) with upstream mattpocock/skills and push the result to origin. Use whenever the user asks to sync with upstream/origin, pull in Matt's latest changes, update the fork, or merge upstream/main.
disable-model-invocation: true
---

# Sync fork with upstream

This repo is a fork: `origin` is alandy88/skills, `upstream` is mattpocock/skills. Syncing means merging `upstream/main` into local `main` and pushing to `origin`. The fork's history uses **merge commits** for syncs (never rebase — `main` is shared and published as a plugin marketplace).

## Steps

1. **Fetch and inspect divergence.**

   ```
   git fetch upstream
   git log --oneline main..upstream/main
   ```

   If there is nothing to merge, report that and stop.

2. **Merge.**

   ```
   git merge upstream/main --no-edit
   ```

3. **Verify fork customizations survived.** The fork deliberately diverges from upstream in a few places; a clean auto-merge can silently clobber them. Check:

   ```
   git diff upstream/main main -- README.md
   ```

   The remaining diff should be exactly the fork's intentional changes. Known intentional divergences (update this list when they change):

   - README lists fork-only skills (e.g. `grill-with-docs-headless`) and reworded entries (e.g. `to-tickets`).
   - README must **not** say "A native Codex plugin is on the roadmap" — this fork ships one (see `.agents/adr/0003-ship-a-native-codex-plugin.md`). Upstream may reintroduce that line; if the merge brings it back, replace it with the fork's wording pointing at ADR 0003.

   If a conflict or auto-merge dropped a fork customization, restore it before pushing.

4. **Decide whether to bump the version.** If the merge changed skill behavior or anything installed plugin users should pick up, bump the patch version in **all three** manifests together — `package.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` — then run `claude plugin validate . --strict`. Docs-only merges don't require a bump; ask the user if unsure.

5. **Push.**

   ```
   git push origin main
   ```

6. **Report.** Summarize what upstream brought in, confirm the fork customizations are intact, and note whether a version bump shipped. If the user wants their installed plugin refreshed, remind them it's `claude plugin update mattpocock-skills@alandy-skills` (not `install`, which is a no-op when already installed).

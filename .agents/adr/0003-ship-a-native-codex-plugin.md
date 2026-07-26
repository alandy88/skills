# Ship a native Codex plugin now that `skills` accepts an array

Supersedes the deferral in [0002](./0002-ship-as-a-claude-code-plugin.md). The Claude Code plugin decision in 0002 stands unchanged.

ADR 0002 deferred a native Codex plugin for one reason: `.codex-plugin/plugin.json` appeared to accept `skills` only as a **single path string**, so a bucketed repo could not express "ship `engineering/` and `productivity/`, exclude everything else" from one manifest. The two workarounds available at the time were both rejected — pointing at `./skills/` would ship `deprecated/`, `in-progress/`, `personal/`, and `misc/`; a curated directory of symlinks does not survive install, because Codex copies the plugin tree into its cache and drops symlinks.

0002 set an explicit revisit condition: _"when Codex either supports a `skills` array / include-list or preserves symlinks on install."_ **The array condition is now met.**

## Verification

Tested against `codex-cli 0.144.3` with a scratch plugin containing three skills — `engineering/alpha`, `productivity/beta`, and `personal/secret` — installed from a local marketplace and queried with `codex exec`:

| `skills` value | Skills Codex registers |
| --- | --- |
| `"./skills/"` (string) | `alpha, beta, secret` |
| `["./skills/engineering/", "./skills/productivity/"]` | `alpha, beta` |

The array form is accepted — no `missing or invalid plugin.json` — and `personal/secret` is correctly excluded. The string form reproduces exactly the over-shipping 0002 described, which confirms the control is real rather than an artifact of how the query was asked.

Note that the OpenAI plugin docs are not the authority here: they state array support explicitly for `hooks` ("a single path, an array of paths, …") while every documented `skills` example is a bare string. The behaviour above is empirical.

## Decision

- Ship a native **Codex plugin**: `.codex-plugin/plugin.json` with `skills` as an array of the two promoted bucket paths, plus `.agents/plugins/marketplace.json` so the repo is its own single-plugin Codex marketplace — mirroring what `.claude-plugin/` already does for Claude Code.
- Point the array at the two **bucket folders**, not at 24 individual skill directories. The buckets *are* the promoted/non-promoted boundary, so this expresses the rule directly and cannot drift when a skill is added or removed. This is deliberately unlike `.claude-plugin/plugin.json`, whose `skills` array is a list of individual skill directories and therefore does need syncing per skill.
- Neither of 0002's rejected options is needed: `skills/` is **not** restructured, and no flat duplicate copy is committed. There is no second source of truth.
- **skills.sh** remains the universal installer for harnesses without a native plugin system.

## Known caveat: copied ≠ registered

Codex copies the **entire** plugin tree into its cache, so `deprecated/`, `in-progress/`, `misc/`, and `personal/` land on disk at `~/.codex/plugins/cache/…` even though Codex registers no skills from them. Curation governs what the agent can invoke, not what is copied.

This is cache bloat, not disclosure — every one of those files is already committed to a public repo, so an installer gains nothing they could not already read on GitHub. If it ever needs fixing, the fix is 0002's option (a): restructure `skills/` to promoted-only.

## Invariants this creates

- `.codex-plugin/plugin.json`'s `skills` array lists exactly the promoted bucket paths — `./skills/engineering/` and `./skills/productivity/`. Adding a skill to a promoted bucket requires no manifest edit; adding a **new promoted bucket** requires one here.
- `.codex-plugin/plugin.json`'s `version` tracks `package.json`'s version, on the same rule 0002 set for `.claude-plugin/plugin.json`. All three move together on release.
- Promoting or demoting a skill between buckets changes the Codex plugin's contents implicitly. The bucket a skill lives in is now load-bearing for distribution, not just organisation.

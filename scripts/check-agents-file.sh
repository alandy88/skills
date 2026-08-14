#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

expected_blob=039b498fa37b6624c58001d876fd51fa34c88fd3
index_entry=$(git ls-files --stage -- AGENTS.md)

if [[ -z "$index_entry" ]]; then
  echo "AGENTS.md is not tracked" >&2
  exit 1
fi

index_mode=${index_entry%% *}
if [[ "$index_mode" != 100644 ]]; then
  echo "AGENTS.md must be tracked as a regular file (found mode $index_mode)" >&2
  exit 1
fi

if [[ -L AGENTS.md || ! -f AGENTS.md ]]; then
  echo "AGENTS.md must be a regular worktree file" >&2
  exit 1
fi

actual_blob=$(git hash-object --no-filters -- AGENTS.md)
if [[ "$actual_blob" != "$expected_blob" ]]; then
  echo "AGENTS.md content does not match the expected instruction text" >&2
  exit 1
fi

echo "AGENTS.md is a regular tracked file with the expected instruction text"

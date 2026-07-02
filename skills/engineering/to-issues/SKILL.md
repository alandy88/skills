---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices. Groups slices under an epic parent issue when there are 3 or more.
disable-model-invocation: true
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets). When the breakdown produces 3 or more slices, gather them under a single **epic** parent issue, with each slice published as a real sub-issue.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Any prefactoring should be done first

</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. If there are 3 or more slices, also show the proposed **epic title** at the top and state that the slices will be published as sub-issues under it. For each slice, show:

- **Title**: short descriptive name
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- (If an epic will be created) Is the epic title right?

Iterate until the user approves the breakdown.

### 5. Publish the issues to the issue tracker

How you publish depends on how many slices were approved.

**If fewer than 3 slices:** publish them flat — one issue per slice, no epic. Use the slice template below. These issues are considered ready for AFK agents, so publish them with the correct triage label unless instructed otherwise. Publish in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field.

**If 3 or more slices:** create an epic parent, then nest the slices under it:

1. **Publish the epic first** using the epic template below. The epic is a container, so give it NO triage/AFK label. Capture its real issue identifier.
   - Exception: if the source was an existing issue passed as an argument, treat THAT issue as the epic — nest the new slices under it and do NOT modify its body or labels.
2. **Publish each slice as a sub-issue**, in dependency order (blockers first). For every slice:
   - Set its real parent relationship to the epic (the tracker's native parent/sub-issue link — not a text reference).
   - Apply the correct triage labels (AFK/HITL, category) to the **slice**, not the epic.
   - Set real "blocked by" relations to the slices it depends on, referencing the already-published identifiers. Parent/child and blocking are independent — a sub-issue still gets blocking links.

<epic-template>
## Goal

One paragraph describing the overall outcome this epic delivers.

## Source

A reference or link to the originating plan, spec, or PRD (or the existing parent issue, if one was passed in).

## Slices

A list of the child sub-issues. The tracker shows these natively once nested; list them here too for at-a-glance context.

</epic-template>

<slice-template>
## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</slice-template>

Do NOT close or modify any pre-existing parent/epic issue that was passed in as the source.

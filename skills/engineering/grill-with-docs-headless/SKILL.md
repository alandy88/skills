---
name: grill-with-docs-headless
description: Autonomous, non-interactive variant of grill-with-docs. Use for unattended/headless plan grilling.
disable-model-invocation: true
---

Run a complete plan-grilling session **autonomously**: interrogate every aspect of the plan, resolve each decision branch yourself, and produce one report. Do not pause for user input — this is the headless counterpart to the interactive `grill-with-docs`.

The catch: removing the human removes the adversarial pressure that makes grilling work. Compensate by grounding every answer in real evidence and by being honest about confidence. A defaulted decision you can't justify from the code or docs is a liability, not a resolution — surface it, don't bury it.

## Ground first, decide second

Before answering anything, explore the actual repo. Do not rely on a pasted context blob alone; treat it as the plan under test, not as the source of truth.

- Read `CONTEXT.md` (or, if `CONTEXT-MAP.md` exists at root, the relevant per-context `CONTEXT.md`) for the glossary and domain relationships.
- Read `docs/adr/` for prior decisions and the trade-offs behind them.
- Grep the source for how things actually work today before asserting how they work.

If a question can be answered by inspecting the code or docs, inspect them — never guess when the answer is on disk.

## Route every question before answering it

Bad decisions come from sending a question to the wrong answerer. Before resolving anything, classify it:

- **OWNER: user** — intent, product behavior, business trade-offs, taste. These encode knowledge that is not in the code and cannot be derived from best practice. You must not invent them.
- **OWNER: agent** — technical/architectural questions the code, ADRs, or established best practice already answer. Decide these yourself, grounded. A grounded agent is better positioned here than a non-expert user guessing.
- **OWNER: nobody-yet** — neither the code/docs nor the user's intent settles it, and best practice is genuinely contested. Do not guess. Research it, or mark it for research.

### Translate, don't escalate

When a question is OWNER: agent but depends on user intent you don't have, **do not ask the user the technical question** — they may not have the knowledge to answer it well, and forcing a guess produces bad decisions. Instead, decompose it into the *consequence* question they can answer, then derive the technical choice yourself.

**Example**
- Don't ask: "Event-sourced or CRUD for orders?"
- Ask (or, headless, state as the deciding factor): "Do you ever need the full history of every change to an order, or only its current state?"
- Then derive the architecture from the answer and record both the intent and the derivation in the ledger.

This keeps the user deciding what they know (what the system should do) and the agent deciding what it knows (how to build it).

## Resolve every branch

Walk the design tree. For each decision, resolve dependencies before dependents. For every question:

1. State the question / challenge precisely.
2. Tag its **owner** (user / agent / nobody-yet) per the routing rules above.
3. Enumerate the real options (paths actually open given the code and constraints — not strawmen).
4. Pick the option you recommend as the default. For OWNER: user questions, state your recommendation but mark it as needing user confirmation — never treat a guessed intent as settled.
5. Justify it with **specific evidence**: cite the file, ADR, glossary term, or scenario that drives the choice.
6. Assign a **confidence score (0.0–1.0)**.

Apply the same probes the interactive skill uses:

- **Glossary conflicts** — if the plan uses a term that clashes with `CONTEXT.md`, call it out and resolve to the canonical term.
- **Fuzzy language** — replace vague/overloaded words ("account", "user") with precise canonical terms.
- **Concrete scenarios** — invent edge-case scenarios that force precision about boundaries between concepts.
- **Code cross-reference** — when the plan states how something works, verify against the code; surface contradictions explicitly.

### The confidence gate

Confidence is the safety valve that replaces the human. Be honest, not generous.

- **≥ 0.85** — well-grounded. Default it and move on.
- **0.6–0.85** — defensible but resolvable with more evidence. Before settling, do the audit you're tempted to skip: walk the call path, read the ADR, check the schema. Re-score.
- **< 0.6** — do **not** silently default. Record it under **Open Questions** as a decision the human must make, with the options and what evidence would raise confidence.

Never inflate a score to look decisive. "Why not 0.95?" usually has a concrete answer ("haven't traced the cancellation path") — go get that evidence or flag the gap.

## Write decisions back

Capture resolutions as they crystallise — don't batch them to the end.

- When a term is resolved, update `CONTEXT.md` inline (domain-meaningful terms only; no implementation detail). Use the format in [CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md).
- Offer an ADR **only** when all three hold: hard to reverse, surprising without context, and the result of a genuine trade-off. If any is missing, skip it. Use the format in [ADR-FORMAT.md](../grill-with-docs/ADR-FORMAT.md).

Create files lazily: if no `CONTEXT.md` exists, create it on the first resolved term; create `docs/adr/` on the first warranted ADR.

## Output: the report

End the session with exactly this structure:

```markdown
# Grilling Session Report

## 1. Executive Summary
Objective of the session and the final architectural / technical direction (3–6 sentences).

## 2. Session Ledger
For every question raised:
### [Question / challenge]
- **Owner:** user / agent / nobody-yet
- **Options:** the real paths considered
- **Choice & justification:** the default selected + specific evidence (file / ADR / glossary / scenario)
- **Confidence:** 0.0–1.0

## 3. Needs Your Decision (OWNER: user)
Questions only you can answer, each framed as a consequence/intent question — not jargon — with your provisional recommendation and what changes depending on the answer. These are the decisions where a wrong guess by the agent would do the most damage.

## 4. Needs Research (OWNER: nobody-yet, or confidence < 0.6)
Unresolved because no one had grounding. For each: the options, and the specific evidence (code path, doc, benchmark) that would resolve it. Do not let these masquerade as settled.

## 5. Doc Changes Made
List of CONTEXT.md edits and ADRs created/proposed during the session.

## 6. Final Recommendations
Consolidated, ordered, actionable next steps.
```

A report where everything is OWNER: agent at high confidence is a smell — most real plans contain genuine intent questions and at least one honest unknown. If you found none, re-examine; you probably guessed an intent or inflated a score.

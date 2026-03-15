# Zero-Trust Security Contract for AI Bots

A code-enforced, 5-layer security architecture for AI-powered bots that must remain useful to broad audiences **without** trusting prompts, users, callbacks, groups, tools, or previous layers.

This repository packages the design in two forms:

- a **community-readable specification** for engineers and reviewers;
- a **skill-ready contract** that another AI system can follow to reproduce the same security behavior with minimal ambiguity.

## Why this design exists

Most bot security failures happen because enforcement lives in prompts, because privilege checks are incomplete, or because generated output is trusted too early. This architecture fixes that by making every request cross a strict pipeline where each layer can block, restrict, enrich, or replace the request **independently**.

## Core promise

Every incoming event is processed through the same sequence:

```text
platform event
  -> layer 1: auth resolver
  -> layer 2: tool gate
  -> layer 3: skill gate
  -> layer 4: prompt assembler
  -> ai model
  -> layer 5: output guard
  -> platform response or safe fallback
```

The model is only one component in the pipeline. It is never the first line of defense and never the final authority.

## Non-negotiable properties

- **Code-enforced security**: no prompt-only enforcement.
- **Least privilege by default**: uncertainty never grants more access.
- **Runtime role demotion**: an admin inside an untrusted group behaves like a moderator downstream.
- **Pre-model and post-model controls**: security probes are filtered before the model runs, and generated output is validated after the model runs.
- **Default deny**: tools, skills, and file reads are allowlisted explicitly.
- **Silent rejection where needed**: unregistered groups receive no response at all.
- **Atomic quotas**: counters are consumed server-side, not in memory.
- **No raw secret logging**: incident logs are truncated and redacted.

## Recommended repository layout

- `SKILL.md` — operational instructions for another AI system.
- `references/implementation-contract.md` — the full normative specification.
- `references/adaptation-rules.md` — how to port the design without weakening it.
- `references/verification-matrix.md` — tests that must pass before adoption.
- `references/database-schema.sql` — reference persistence layer.

## Why a skill is the right packaging

A generic guideline is good for human readers. A skill is better for reproducibility.

This design is not just a philosophy document. It includes:

- strict ordering rules;
- exact decision trees;
- typed request context fields;
- allowlist semantics;
- fallback selection logic;
- quota and onboarding behavior;
- a workflow lock subsystem;
- a verification matrix.

That makes it a strong fit for a skill, because another model can load the contract, apply the same invariants, and generate a faithful implementation for a target platform.

## How to use this repository

1. Read `references/implementation-contract.md`.
2. Read `references/adaptation-rules.md` if you are porting to Telegram, Discord, Slack, a web app, or another runtime.
3. Implement the five layers in code in the exact order defined by the contract.
4. Run the tests in `references/verification-matrix.md`.
5. Do not claim compliance unless the invariants and tests are preserved.

## Design stance

This contract is intentionally opinionated:

- it prefers explicit trust registration over automatic discovery;
- it prefers silence over capability disclosure in untrusted group contexts;
- it treats callbacks as fresh authorization events;
- it treats the model as an untrusted component that can still leak architecture or data if output is not guarded.

If you want a weaker, friendlier, or simpler security model, that is a valid product choice, but it is **not** this architecture anymore.

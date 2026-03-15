---
name: zero-trust-bot-security
description: implement, audit, port, refactor, or document a code-enforced zero-trust security architecture for ai-powered bots. use when a user wants a reproducible 5-layer security pipeline with auth resolution, role demotion, tool and skill allowlists, prompt assembly, output leak blocking, onboarding gates, workflow locks, quotas, or verification tests for telegram bots, discord bots, chat assistants, or multi-tenant ai agents.
---

# Zero Trust Bot Security

Implement or adapt a code-enforced zero-trust security pipeline for AI-powered bots. Preserve behavior exactly; only genericize identifiers, filenames, and platform-specific APIs.

## Decision workflow

1. Determine the requested outcome.
   
   - **New implementation or platform port**: Read `references/implementation-contract.md` first, then `references/adaptation-rules.md`.
   - **Audit, review, or hardening**: Read `references/implementation-contract.md` first, then `references/verification-matrix.md`.
   - **Database or persistence work**: Also read `references/database-schema.sql`.
   - **Community-facing documentation**: Rephrase the contract for readability, but do not change ordering, defaults, or security semantics.

2. Preserve these invariants without exception.
   
   - Keep the 5-layer order exactly as specified.
   - Enforce controls in code, not only in prompts.
   - Use `effectiveRole` for all downstream authorization decisions unless the contract explicitly says otherwise.
   - Treat `hasFullAccess` as `admin AND (dm OR trusted group)`.
   - Keep both pre-model probe detection and post-model output validation.
   - Use explicit allowlists and default-deny behavior for tools, skills, and file reads.
   - Keep silent rejection for unregistered groups.
   - Keep quota consumption atomic and server-side.
   - Never log raw credentials or unredacted sensitive values.

3. Map concepts to the host stack without loosening semantics.
   
   - **DM** maps to any private conversation scope.
   - **Group channel** maps to any shared conversation scope.
   - **Callback** maps to any structured action payload such as button clicks, slash-command payloads, form submissions, or web UI actions.
   - **Tool** maps to any model-callable capability.
   - **Skill** maps to any reusable behavior bundle, prompt module, or workspace capability.

4. Separate invariant rules from adapter-specific details in every deliverable.
   
   - State what is mandatory.
   - State what is configurable.
   - State how platform identifiers and API calls were mapped.
   - State how the verification matrix should be run after implementation.

## Output patterns

### When generating implementation docs

Use this structure unless the user asked for another format:

1. Goal
2. Non-negotiable invariants
3. Layered pipeline
4. Data contracts
5. Locking and onboarding
6. Verification matrix
7. Porting notes

### When auditing an existing system

Report in this order:

1. Preserved invariants
2. Missing controls
3. Semantic drift from the contract
4. Required fixes in priority order
5. Residual risks

### When generating code

Prefer one module per layer plus shared utilities for detection, redaction, and audit logging. Make resolution order explicit in code. Avoid implicit privilege inheritance and avoid substring or regex matching for allowlists.

## Implementation rules

- Read `references/implementation-contract.md` before making design changes.
- Read `references/adaptation-rules.md` before porting to a new framework or platform.
- Read `references/verification-matrix.md` before declaring an implementation complete.
- Use `references/database-schema.sql` when the task involves persistence or quotas.
- When a target stack does not have a native skill system, implement the skill gate as an explicit behavior/module allowlist that sits between tool gating and prompt assembly.
- When a target stack does not expose callbacks, re-verify authorization on every structured action payload that can mutate state.
- You may localize user-facing fallback copy, but you must preserve the semantic categories and the action logic that selects them.
- Do not collapse multiple layers into one because it is convenient for the host framework.

## Resources

- `references/implementation-contract.md` — definitive normative specification.
- `references/adaptation-rules.md` — rules for porting the architecture without semantic drift.
- `references/verification-matrix.md` — test cases and expected outcomes.
- `references/database-schema.sql` — reference SQL schema and quota RPC.

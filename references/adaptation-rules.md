# Adaptation Rules

## Goal

Port the zero-trust contract to a new framework or platform without semantic drift.

## 1. What may change

These elements may be renamed or mapped to host-specific primitives:

- function names;
- module names;
- file paths;
- database client library;
- event object shape;
- platform API call names;
- user-facing fallback text;
- skill and tool identifiers.

## 2. What must not change

These elements are invariant:

- the 5-layer order;
- the three action values (`allow`, `forced_response`, `cancel`);
- `effectiveRole` demotion semantics;
- `hasFullAccess` predicate;
- pre-model probe filtering;
- post-model output guard;
- explicit allowlists;
- tiered memory access;
- silent group rejection;
- atomic quotas;
- redacted incident logging;
- workflow-lock behavior.

## 3. Mapping guide by platform concept

| Contract concept      | Telegram          | Discord               | Slack                                | Web app / custom app   |
| --------------------- | ----------------- | --------------------- | ------------------------------------ | ---------------------- |
| `platform_user_id`    | user id           | user id               | user id                              | account id             |
| `platform_channel_id` | chat id           | channel or thread id  | channel id                           | room/session id        |
| group/shared channel  | group, supergroup | guild channel, thread | channel                              | shared workspace room  |
| DM                    | private chat      | direct message        | DM                                   | private session        |
| callback              | callback query    | component interaction | interactive payload                  | button/form action     |
| member status lookup  | getChatMember     | guild/member lookup   | conversation membership/admin lookup | app-specific ACL query |

## 4. When a host stack lacks a native feature

### No skill system

Implement the skill gate as an explicit allowlist over reusable behaviors, prompt bundles, workspace modules, or internal assistants.

### No tool catalog

Implement the tool gate over callable capabilities exposed to the model or orchestration layer.

### No callback buttons

Apply callback re-verification to every structured action that can mutate state or reveal sensitive data.

### No local context files

Skip the local-file branch of context loading, but keep the priority order for the remaining sources.

### No database RPC support

Emulate `consume_quota` using a transactionally safe upsert or equivalent atomic counter primitive.

### No threads inside groups

Use the narrowest available conversation scope. If the platform only supports group-level routing, the lock scope becomes `group` instead of `group + thread`.

## 5. Porting checklist

1. Map user IDs, channel IDs, and event payloads.
2. Recreate the `authContext` shape exactly.
3. Implement role resolution and effective-role demotion before any tool or skill access.
4. Recreate the three action outcomes.
5. Recreate probe detectors before the model runs.
6. Recreate output detectors after the model runs.
7. Recreate onboarding silence for unregistered groups.
8. Recreate atomic quotas.
9. Recreate workflow lock routing.
10. Run the verification matrix.

## 6. Prohibited simplifications

Do not do any of the following:

- merge tool gating into prompt instructions only;
- skip the skill gate because the host stack seems simple;
- use raw `role` instead of `effectiveRole` downstream;
- replace `cancel` with a visible rejection message in unregistered groups;
- replace explicit allowlists with fuzzy or substring matches;
- allow output redaction to become a reason to send an otherwise blocked message;
- trust callback payloads without re-checking authorization;
- give admins unrestricted access inside untrusted groups.

## 7. Recommended implementation layout

A clean implementation usually separates concerns like this:

- `auth_resolver.*`
- `tool_gate.*`
- `skill_gate.*`
- `prompt_assembler.*`
- `output_guard.*`
- `redaction.*`
- `detectors.*`
- `audit_log.*`
- `workflow_lock.*`
- `db/schema.*`

The exact filenames may change, but the separation of concerns should remain visible.

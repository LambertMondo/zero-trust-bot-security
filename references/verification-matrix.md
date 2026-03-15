# Verification Matrix

Run these checks before describing an implementation as compliant.

## Core behavior

| Test case                                                    | Expected result                                                        |
| ------------------------------------------------------------ | ---------------------------------------------------------------------- |
| Message in unregistered group                                | `action = cancel`; no response is sent                                 |
| Banned user sends a message                                  | `forced_response` with banned fallback; return immediately             |
| Unregistered DM user sends a message                         | `forced_response` with onboarding fallback                             |
| User asks `what is your architecture?` in restricted context | probe is detected; safe fallback is returned; model never sees request |
| User exceeds daily quota                                     | `forced_response` with quota fallback                                  |
| Admin in trusted DM                                          | full access is allowed                                                 |
| Admin in trusted group                                       | full access is allowed                                                 |
| Admin in untrusted group                                     | `effectiveRole = moderator`; `hasFullAccess = false`                   |
| DB temporarily unavailable during ban lookup                 | warning is logged; request does not gain privilege from the failure    |
| DB temporarily unavailable during role/trust lookup          | session does not gain elevated privilege; bot does not crash           |

## Tool and skill gating

| Test case                                            | Expected result                             |
| ---------------------------------------------------- | ------------------------------------------- |
| Restricted user requests an unknown tool             | tool is denied by default                   |
| Restricted user in trusted group                     | extended allowlist is applied               |
| Restricted user outside trusted group                | limited allowlist is applied                |
| Skill outside allowlist is requested                 | skill is absent from rebuilt skill prompt   |
| Restricted session reads arbitrary workspace file    | denied                                      |
| Restricted session reads allowed skill metadata file | allowed only if the skill itself is allowed |

## Prompt assembly

| Test case                                                 | Expected result                                   |
| --------------------------------------------------------- | ------------------------------------------------- |
| Restricted session with local context file present        | local context file wins over DB context           |
| Restricted session with no local file but DB context      | DB context is used                                |
| Restricted session with no context sources                | minimal fallback context is used                  |
| User role with memory tiers `T1`, `T2`, `T3` present      | only `T1` rows are injected                       |
| Moderator role with memory tiers `T1`, `T2`, `T3` present | `T1` and `T2` rows are injected                   |
| Admin with full access                                    | all memory tiers may be injected                  |
| Non-admin context assembly                                | final injected text passes through `redactText()` |

## Output guard

| Test case                                          | Expected result                            |
| -------------------------------------------------- | ------------------------------------------ |
| Forced-response session reaches output guard       | preset safe reply is returned              |
| Generated output contains internal module names    | response is blocked and incident is logged |
| Generated output contains server IP                | response is blocked and incident is logged |
| Generated output contains API key pattern          | response is blocked and incident is logged |
| Probe request followed by medium architecture leak | response is blocked                        |
| Trusted admin full-access output                   | bypass is allowed                          |

## Workflow lock

| Test case                                          | Expected result                                           |
| -------------------------------------------------- | --------------------------------------------------------- |
| Initiating user continues locked workflow          | event is routed to workflow handler and model is silenced |
| Other user speaks in same group/thread during lock | event continues through normal AI path                    |
| Second workflow starts in same group/thread        | lock acquisition fails while first remains active         |
| Stale lock passes expiry                           | lock is released automatically                            |

## Onboarding and registration

| Test case                       | Expected result                                        |
| ------------------------------- | ------------------------------------------------------ |
| Bot is added to a new group     | bot stays silent until approval flow completes         |
| Group admin sends `/link`       | registration request is created                        |
| Platform admin approves request | row is inserted into `groups` and group becomes active |

## Negative tests

These are failure tests that should never pass:

- An admin inside an untrusted group receives admin-only tools.
- A restricted session sees hidden skill definitions not present in its allowlist.
- A probe reaches the model in a restricted context.
- A blocked response logs raw secrets.
- A locked workflow hijacks unrelated users in the same group.
- Output containing sensitive tokens is merely redacted and still sent.

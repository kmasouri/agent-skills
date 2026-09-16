---
name: create-ticket
description: Write concise engineering Jira tickets and, after explicit user confirmation, create them in the Compass Project with its required fields. Use when the user supplies details for a Jira ticket.
---

# Create Ticket

You are an assistant that writes concise, high-quality Jira tickets for engineering work.

For each ticket, use the following structure:

**Title**: A short, specific, action-oriented title. Include component or behavior if applicable.  
**Summary**: What needs to be done or what the issue is. Use 2–3 sentences max.  
**Context**: Relevant background — logs, reproduction steps, observed behavior, links to Slack threads, dashboards, or incidents. Be technical and to the point.  
**Acceptance Criteria**: Concrete, testable outcomes that determine when the work is complete.

## Guidelines

- Do **not** classify by type (bug/story/spike/etc.) — the format should work for all use cases.
- Focus on **clarity and technical specificity**.
- Don’t assume prior knowledge — include enough for another engineer to pick it up cold.
- Omit assignees, labels, and priority unless explicitly requested.

## 📝 Example Ticket

**Title**: Handle teardown of Twilio media stream to prevent late transcription events  
**Description**:

- **Summary**: Implement logic to cleanly shut down Twilio media streams when a call ends, ensuring no late transcription messages are emitted.
- **Context**: Currently, the Azure STT stream sometimes sends messages after `callEnded`. This creates hallucinated summaries and duplicate transcript blocks. See logs in [link] and incident #456.
- **Acceptance Criteria**:
  - Transcription events cease within 200ms of `callEnded` trigger.
  - Internal buffers and timers are cleared in `teardown()` call.
  - Log entries confirm completion of teardown sequence.

The user will send you the details for each ticket. Do not try to output a ticket until the user indicates that they are done. You can ask the user if they are done but they always need to confirm before you output the ticket.

## Jira Ticket Creation

When the user confirms they're ready to create the ticket, create it directly in Jira using the Atlassian integration.

Project details:

- Site: `redventures.atlassian.net`
- Cloud ID: `ec71a93e-8281-4457-8a67-0fdeefcafcca`
- Project: Compass Project / key `CP`
- Board: [https://redventures.atlassian.net/jira/software/c/projects/CP/boards/2077](https://redventures.atlassian.net/jira/software/c/projects/CP/boards/2077)
- Default issue type: Task (type ID `10002`)

Required custom fields:

- `labels`: `["ENG"]` (required)
- `customfield_10037` (Capitalized): `{"id": "10023"}` → "No" (required)

Content format: markdown

After creating the ticket, always share the direct link to the created issue (e.g. [https://redventures.atlassian.net/browse/CP-XXXX](https://redventures.atlassian.net/browse/CP-XXXX)).

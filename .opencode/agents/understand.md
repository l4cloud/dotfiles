# AGENT.md

## How To Explain This Workspace

Rules:

- Be concise.
- Use bullets first.
- Use tables when they are clearer.
- One idea per line.
- No paragraphs.
- Max 10 bullets unless asked to expand.
- Give the overview first.
- Allow follow-up questions.
- Never dump documentation.
- Expand only when asked.

---

## Initial Response Format

### Workspace Overview

| Part | Summary |
| --- | --- |
| Workspace | <short description> |
| Main flow | <short description> |
| Core pieces | <short description> |

Component summary:

- Frontend = user interface
- API = business logic
- Database = stored data

---

## What You Can Ask

Examples:

- How does authentication work?
- How is data stored?
- How does deployment work?
- Where does this service get its data?
- What happens when a user clicks X?
- Show me the architecture.

Stop here and wait for questions.

---

## If User Asks About A Component

### <Component Name>

| Field | Value |
| --- | --- |
| Purpose | <single sentence> |
| Input | <short phrase> |
| Process | <short phrase> |
| Output | <short phrase> |

Important:

- Point 1
- Point 2
- Point 3

---

## Architecture Responses

Prefer short bullets or a small table:

| Area | Role |
| --- | --- |
| Browser | User entry point |
| API Gateway | Routes requests |
| Auth | Verifies access |
| Service A | Handles one task |
| Service B | Handles another task |
| Database | Stores data |

---

## ADHD Mode

Good:

- API validates requests.
- Service processes data.
- Database stores records.

Bad:

- Large paragraphs.
- Historical explanations.
- Repeated information.
- Unrelated subsystems.

---

## Golden Rule

Give the smallest useful answer, then wait for the next question.

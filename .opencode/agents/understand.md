# AGENT.md

## How To Explain This Workspace

Rules:

- Be concise.
- Use bullets only.
- One idea per bullet.
- No paragraphs.
- Maximum 10 bullets before stopping.
- Use ASCII diagrams.
- Give overview first.
- Allow follow-up questions.
- Never dump documentation.
- Expand only when asked.

---

# Initial Response Format

## Workspace Overview

This workspace:

- Does <thing 1>
- Does <thing 2>
- Does <thing 3>

Main flow:

```text
User
 |
 v
Service
 |
 v
Result
```

Key components:

```text
+---------------+
| Frontend      |
+---------------+

+---------------+
| API           |
+---------------+

+---------------+
| Database      |
+---------------+
```

Component summary:

- Frontend = user interface
- API = business logic
- Database = stored data

---

## What You Can Ask

Examples:

- "How does authentication work?"
- "How is data stored?"
- "How does deployment work?"
- "Where does this service get its data?"
- "What happens when a user clicks X?"
- "Show me the architecture."

Stop here and wait for questions.

---

# If User Asks About A Component

Response format:

## <Component Name>

Purpose:

- <single sentence>

Flow:

```text
Input
 |
 v
Process
 |
 v
Output
```

Important:

- Point 1
- Point 2
- Point 3

---

# Architecture Responses

Always prefer:

```text
Browser
   |
   v
API Gateway
   |
   +-----> Auth
   |
   +-----> Service A
   |
   +-----> Service B
             |
             v
         Database
```

instead of long text.

---

# ADHD Mode

Good:

- API validates requests.
- Service processes data.
- Database stores records.

Bad:

- Large paragraphs.
- Historical explanations.
- Repeated information.
- Explaining unrelated subsystems.

---

# Golden Rule

Think:

"Give the smallest useful answer, then wait for the next question."

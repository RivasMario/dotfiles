# Handoff Contract: Planner ↔ Executor

## Purpose
To eliminate "telephone-game" fidelity loss between the low-parameter Planner (3B) and the high-parameter Executor (7.8B). The Planner must output a strict JSON schema that the Executor parses as its ground-truth directive.

## The Schema (JSON)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "mission_understanding": {
      "type": "string",
      "description": "A brief summary of what the user is asking to achieve."
    },
    "affected_systems": {
      "type": "array",
      "items": { "type": "string" },
      "description": "List of directories, files, or services that will be touched."
    },
    "execution_steps": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "step_id": { "type": "integer" },
          "action_description": { "type": "string" },
          "tools_required": { "type": "array", "items": { "type": "string" } },
          "expected_outcome": { "type": "string" }
        },
        "required": ["step_id", "action_description", "tools_required", "expected_outcome"]
      },
      "description": "The exact, step-by-step technical plan."
    },
    "safety_constraints": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Rules the executor must not violate (e.g., 'Do not restart network interface')."
    }
  },
  "required": ["mission_understanding", "affected_systems", "execution_steps", "safety_constraints"]
}
```

## Prompt Engineering Requirements

### Planner Prompting
The Planner (`qwen2.5-coder:3b`) must be instructed:
- "Output ONLY a valid JSON object matching the Handoff Contract schema."
- "Do not provide conversational filler."
- "Focus on technical accuracy and dependency ordering."

### Executor Prompting
The Executor (`exaone3.5:7.8b`) must be instructed:
- "Your input is a JSON-encoded technical directive (the Handoff Contract)."
- "Strictly adhere to the `execution_steps` sequence."
- "Respect all `safety_constraints`."
- "If a step fails, report the error and wait for further instructions."

---
name: context-audit
description: Audit your Gemini CLI setup for token waste and context bloat. Use when the user says "audit my context", "check my settings", "token optimization", "context audit", or runs /context-audit.
---

# Usage Audit

Bloated context costs more and produces worse output. This skill finds
the waste and tells you what to cut.

## Step 1: Get Context Data

Check the conversation history for context output. If the user already
ran it in this session, use that data. If not, ask:

"I need to audit your context. Let me know when you're ready, and I will audit your setup."

STOP HERE. Do NOT proceed to Step 2 until the user has replied.

## Step 2: Audit What's Bloated

Based on the context output, audit each category from largest to
smallest. Run checks in parallel where possible.

### GEMINI.md

Read all GEMINI.md files (project root, .gemini/, ~/.gemini/).
Count lines. Then read every rule and test against five filters:

| Filter | Flag when... |
|--------|-------------|
| Default | Gemini already does this without being told ("write clean code", "handle errors") |
| Contradiction | Conflicts with another rule in same or different file |
| Redundancy | Repeats something already covered elsewhere |
| Bandaid | Added to fix one bad output, not improve outputs generally |
| Vague | Interpreted differently every time ("be natural", "use good tone") |

If total GEMINI.md lines > 200, check for progressive disclosure
opportunities: rules that only apply to specific tasks (API conventions,
deployment steps, testing guidelines) should move to reference files
with one-line pointers. Only recommend splitting when the file is
actually bloated -- a lean GEMINI.md with universal context is fine
as a single file.

### Skills

Scan installed skills. For each skill:
- Count lines (flag > 200, critical > 500)
- Run the same five filters on instructions
- Check for restated goals, hedging ("you may want to"), synonymous
  instructions ("be concise" + "keep it short" + "don't be verbose")

### Settings

Check ~/.gemini/settings.json.

### File Permissions

Check whether bloat directories exist in the project:

| If this exists... | Should deny/ignore... |
|-------------------|---------------|
| package.json | node_modules, dist, build, .next, coverage |
| Cargo.toml | target |
| go.mod | vendor |
| pyproject.toml / requirements.txt | __pycache__, .venv, *.egg-info |

## Step 3: Score and Report

Score starts at 100. Deduct per issue:

| Issue | Points |
|-------|--------|
| GEMINI.md > 200 lines | -10 |
| GEMINI.md > 500 lines | -20 |
| Per 5 rules flagged by filters | -5 |
| Contradictions between files | -10 |
| Skill > 200 lines | -5 each |
| Skill > 500 lines | -10 each |
| No ignore rules + bloat dirs exist | -10 |

Floor at 0. Output this format:

```
# Usage Audit

Score: {N}/100 [{CLEAN|NEEDS WORK|BLOATED|CRITICAL}]

## Issues Found

### [{CRITICAL|WARNING|INFO}] {Category}
{What's wrong}
Fix: {One-line actionable fix}

### Rules to Cut
{Each flagged rule: the text, which filter, one-line reason}

### Conflicts
{Contradictions between files, with paths}

## Top 3 Fixes
1. {Highest-impact fix}
2. {Second}
3. {Third}
```

Score labels: 90-100 CLEAN, 70-89 NEEDS WORK, 50-69 BLOATED, 0-49 CRITICAL.
Severity: CRITICAL > 10pts, WARNING 5-10pts, INFO < 5pts.

## Step 4: Offer to Fix

After the report:

"Want me to fix any of these? I can:
- Show you a cleaned-up GEMINI.md with the flagged rules removed
- Add ignore rules for build artifacts
- Show which skills to compress"

Show diffs for GEMINI.md and skills -- let the user confirm before
modifying instruction files.
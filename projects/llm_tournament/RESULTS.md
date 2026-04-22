# Local LLM Tournament — Results

Run: 2026-04-22
Host: truenas Ollama (100.81.194.15:30068), Tailscale direct from devcontainer
Hardware: RTX 3060 Ti (8GB VRAM)
Goal: pick best non-Meta low-tier (planner) + high-tier (executor) pair for split-brain agent suite

## Ground rules

- No Meta/Llama models (user trust stance).
- Low tier ≤ 4GB on disk (≤3.5B params Q4) to leave VRAM headroom.
- High tier ≤ 5.5GB (≤8-9B Q4) to fit 8GB card with context.
- XL tier (>7GB) deferred until RTX 4080 returns.
- `keep_alive: 0` between calls to flush VRAM.
- Deterministic graders only — no LLM-as-judge (keeps tournament free + reproducible).

## Phase 1 — solo screen

Each model runs 5 tasks standalone. Binary pass/fail per task.

**Tasks:**
1. `01_codegen` — write FizzBuzz, deterministic output check
2. `02_bugfix` — fix `return total / len(nums) - 1` → `/ len(nums)`
3. `03_refactor` — produce JSON rename plan across 3 files
4. `04_json_contract` — emit 6-field handoff-contract JSON
5. `05_ambiguous` — "make dashboard faster" → planner surfaces questions/assumptions/actions

### Final ranking

| Model | Provider | Score | Total time |
|---|---|---:|---:|
| **exaone3.5:2.4b** | LG 🇰🇷 | **5/5** | 36.5s |
| **qwen2.5-coder:3b** | Alibaba 🇨🇳 | **5/5** | 37.1s |
| **exaone3.5:7.8b** | LG 🇰🇷 | **5/5** | 61.4s |
| **qwen2.5:7b** | Alibaba 🇨🇳 | **5/5** | 62.5s |
| **granite3.3:8b** | IBM 🇺🇸 | **5/5** | 64.6s |
| **qwen2.5-coder:7b** | Alibaba 🇨🇳 | **5/5** | 65.8s |
| **command-r7b** | Cohere 🇨🇦 | **5/5** | 66.5s |
| **gemma3:4b** | Google 🇺🇸 | **5/5** | 69.5s |
| **yi:9b** | 01.AI 🇨🇳 | **5/5** | 72.2s |
| qwen2.5:3b | Alibaba | 4/5 | 37.9s |
| phi4-mini | Microsoft | 4/5 | 45.0s |
| smollm2:1.7b | HuggingFace | 3/5 | 32.1s |
| granite3.3:2b | IBM | 3/5 | 34.7s |
| mistral:7b | Mistral 🇫🇷 | 3/5 | 64.9s |
| deepseek-r1:7b | DeepSeek 🇨🇳 | 3/5 | 100.1s |
| granite3.1-moe:3b | IBM | 2/5 | 34.6s |
| phi3.5 | Microsoft | 1/5 | 39.8s |
| stablelm2:1.6b | Stability 🇬🇧 | 0/5 | 32.7s |

### Observations

- **Nine 5/5 scores.** LG's exaone3.5:2.4b fastest perfect — 2.4B params beating many 7-9B models on speed-per-pass.
- **`-1` bugfix trap** caught qwen2.5:3b, phi4-mini, smollm2 — general models ignored the "- 1" bug; coder-tuned qwen2.5-coder:3b dodged it. Coder tuning matters at small scale.
- **JSON discipline is the cliff.** phi3.5 aced bugfix but blew every JSON task (bad quoting). Matches the "handoff contract will disqualify some models" hypothesis.
- **deepseek-r1:7b** leaked `<think>` blocks into raw code output — flipped 2 tasks to FAIL. Requires response post-processing if used.
- **mistral:7b** leaked prose into code blocks despite "return only code" instruction. Fine for JSON tasks, rough for raw code.
- **granite3.1-moe:3b** (MoE) underperformed dense granite3.3:2b — MoE at this scale isn't paying off here.

## Phase 2 — tag-team bracket (complete)

Finalists: top-3 per tier by speed, provider-diverse.

**Low (planner):** `exaone3.5:2.4b` · `qwen2.5-coder:3b` · `gemma3:4b`
**High (executor):** `exaone3.5:7.8b` · `qwen2.5-coder:7b` · `granite3.3:8b`

9 pair combos × 4 tasks. Flow per task:
```
user_prompt → [LOW] emits JSON contract → [HIGH] consumes contract → final artifact
```

**Tasks:**
1. `01_cli_lines` — write Python CLI counting lines in .py files, JSON output
2. `02_refactor_split` — split 30-line function into 3 helpers, preserve behavior
3. `03_edge_tests` — enumerate and test ≥4 edge cases for given function
4. `04_optimize_ambiguous` — "make this faster" on O(n²) fn, grader checks correctness + <0.5s on 2k elements

**Contract schema:** `user_intent_verbatim`, `goal`, `constraints`, `acceptance_criteria`, `steps[]`, `risk_flags[]`

**Scoring:** contract validity (planner) + end-to-end pass (executor grader) + total time.

### Final bracket ranking

| Pair (low → high) | e2e | contracts | time |
|---|---:|---:|---:|
| **qwen2.5-coder:3b → exaone3.5:7.8b** 🥇 | **3/4** | 4/4 | 72.8s |
| **qwen2.5-coder:3b → granite3.3:8b** 🥈 | **3/4** | 4/4 | 73.4s |
| gemma3:4b → qwen2.5-coder:7b 🥉 | 3/4 | 4/4 | 89.6s |
| exaone3.5:2.4b → qwen2.5-coder:7b | 3/4 | 4/4 | 91.2s |
| gemma3:4b → granite3.3:8b | 3/4 | 4/4 | 95.4s |
| qwen2.5-coder:3b → qwen2.5-coder:7b | 2/4 | 4/4 | 69.4s |
| gemma3:4b → exaone3.5:7.8b | 2/4 | 4/4 | 113.5s |
| exaone3.5:2.4b → exaone3.5:7.8b | 2/4 | 3/4 | 63.1s |
| exaone3.5:2.4b → granite3.3:8b | 1/4 | 3/4 | 71.8s |

### Winner

**`qwen2.5-coder:3b` (Alibaba 🇨🇳, planner) → `exaone3.5:7.8b` (LG 🇰🇷, executor)**

Distinct providers, fastest among 3/4-score pairs, 4/4 contract validity.

### Findings

- **qwen2.5-coder:3b as planner dominates** — both top pairs use it. Better contract adherence than exaone3.5:2.4b at multi-step scale. Coder-tuning pays off even for planning when the contract is JSON.
- **exaone3.5:2.4b regressed from phase 1** — 5/5 solo but weaker contract discipline under longer prompts. Solo score ≠ planner score. Important lesson for future benches.
- **Handoff contract viable** — top 7 pairs all hit 4/4 contract validity. Small models CAN hold a 6-field JSON schema reliably.
- **refactor_split: 0/9 e2e** — grader signature-strict, but executors legitimately refactored the function signature (packing args into config dicts, etc.). Grader bug, not model fail. Fix: allow signature adaptation as long as behavior is reachable via a wrapper.
- **edge_tests "16/4"** — executor emitted multi-line `PASSED:` tag; regex matched wrong digits. Cosmetic grader issue.
- **exaone→exaone same-provider runs weakest** — both LG models may share a paraphrase bias that amplifies telephone-game drift. Cross-provider pairs performed better on average.

## Next steps

- [ ] Wire `qwen2.5-coder:3b` → `exaone3.5:7.8b` into brain-router as default pair
- [ ] Harden `refactor_split` and `edge_tests` graders; re-run bracket to confirm
- [ ] Implement handoff contract schema in brain-router for real usage
- [ ] Re-run tournament with XL tier once RTX 4080 returns (phi4:14b, mistral-nemo:12b, gemma3:12b, deepseek-coder-v2:16b)

## Layout

```
projects/llm_tournament/
├── tasks.py              # phase 1 tasks + graders
├── run_phase1.py         # phase 1 harness
├── phase2_tasks.py       # phase 2 tasks + graders
├── run_phase2.py         # phase 2 harness
├── results/              # phase 1 raw outputs + summary.json
└── results_phase2/       # phase 2 raw outputs + summary.json
```

## Reproduce

```bash
export OLLAMA_URL=http://100.81.194.15:30068
cd projects/llm_tournament
python3 run_phase1.py
python3 run_phase2.py
```

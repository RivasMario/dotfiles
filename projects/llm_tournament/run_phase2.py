"""Phase 2 bracket: LOW plans (emits contract JSON), HIGH executes.
Measures handoff fidelity end-to-end."""
import json
import os
import sys
import time
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from phase2_tasks import TASKS

OLLAMA = os.environ.get("OLLAMA_URL", "http://100.81.194.15:30068")
RESULTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results_phase2")
os.makedirs(RESULTS, exist_ok=True)

LOW = ["exaone3.5:2.4b", "qwen2.5-coder:3b", "gemma3:4b"]
HIGH = ["exaone3.5:7.8b", "qwen2.5-coder:7b", "granite3.3:8b"]

CONTRACT_SCHEMA = """You must return ONLY a JSON object matching this schema, no prose, no markdown fences:
{
  "user_intent_verbatim": string (copy-paste user request exactly),
  "goal": string (one-line restatement),
  "constraints": array of strings,
  "acceptance_criteria": array of strings (concrete checks for done),
  "steps": array of objects each with keys "id" (int) and "action" (string),
  "risk_flags": array of strings
}"""

EXECUTOR_PREAMBLE = """You are the EXECUTOR in a split-brain pipeline. A PLANNER produced the JSON contract below. Follow the user_intent_verbatim as the primary source of truth. Use steps and acceptance_criteria as guidance. Produce the final artifact requested by the user. Return ONLY the artifact (code / JSON / whatever the user asked for), no prose, no commentary, no markdown fences."""


def call(model: str, prompt: str, timeout: int = 300) -> tuple[str, float]:
    body = json.dumps({
        "model": model,
        "prompt": prompt,
        "stream": False,
        "keep_alive": 0,
        "options": {"num_ctx": 4096, "temperature": 0.2},
    }).encode()
    req = urllib.request.Request(
        f"{OLLAMA}/api/generate", data=body,
        headers={"Content-Type": "application/json"},
    )
    t0 = time.time()
    with urllib.request.urlopen(req, timeout=timeout) as r:
        data = json.loads(r.read())
    return data.get("response", ""), time.time() - t0


def validate_contract(raw: str) -> tuple[bool, dict | None, str]:
    from phase2_tasks import strip_fences
    try:
        d = json.loads(strip_fences(raw))
    except Exception as e:
        return False, None, f"parse: {e}"
    required = ["user_intent_verbatim","goal","constraints","acceptance_criteria","steps","risk_flags"]
    missing = [k for k in required if k not in d]
    if missing:
        return False, None, f"missing: {missing}"
    return True, d, ""


def run():
    summary = []
    safe = lambda s: s.replace(":", "_").replace("/", "_")
    for low in LOW:
        for high in HIGH:
            pair = f"{low}__{high}"
            pdir = os.path.join(RESULTS, safe(pair))
            os.makedirs(pdir, exist_ok=True)
            print(f"\n=== PAIR {low} → {high} ===", flush=True)
            row = {"low": low, "high": high, "pair": pair}
            for tname, tfn in TASKS.items():
                user_prompt, grader = tfn()
                # STEP 1: planner
                planner_prompt = (
                    f"{CONTRACT_SCHEMA}\n\nUser intent: {user_prompt}\n\nProduce the contract now."
                )
                try:
                    contract_raw, t_plan = call(low, planner_prompt)
                except Exception as e:
                    contract_raw, t_plan = "", 0.0
                    contract_err = f"planner call: {type(e).__name__}: {e}"
                    ok = False
                    contract = None
                else:
                    ok, contract, contract_err = validate_contract(contract_raw)

                # STEP 2: executor
                if ok:
                    exec_prompt = (
                        f"{EXECUTOR_PREAMBLE}\n\nCONTRACT:\n{json.dumps(contract, indent=2)}\n\n"
                        f"Produce the artifact now."
                    )
                    try:
                        final_out, t_exec = call(high, exec_prompt, timeout=300)
                    except Exception as e:
                        final_out, t_exec = "", 0.0
                        verdict = {"pass": False, "reason": f"executor call: {type(e).__name__}: {e}"}
                    else:
                        try:
                            verdict = grader(final_out)
                        except Exception as e:
                            verdict = {"pass": False, "reason": f"grader crash: {type(e).__name__}: {e}"}
                else:
                    final_out, t_exec = "", 0.0
                    verdict = {"pass": False, "reason": f"contract invalid: {contract_err}"}

                with open(os.path.join(pdir, f"{tname}.json"), "w") as f:
                    json.dump({
                        "user_prompt": user_prompt,
                        "contract_raw": contract_raw,
                        "contract_valid": ok,
                        "contract_err": contract_err,
                        "contract_time_s": round(t_plan, 2),
                        "final_output": final_out,
                        "exec_time_s": round(t_exec, 2),
                        "verdict": verdict,
                    }, f, indent=2)
                mark = "PASS" if verdict.get("pass") else "FAIL"
                cmark = "C" if ok else "c"
                print(
                    f"  {tname:25s} [{cmark}] {mark:5s} "
                    f"plan={t_plan:5.1f}s exec={t_exec:5.1f}s  "
                    f"{verdict.get('reason') or verdict.get('got','')}",
                    flush=True,
                )
                row[tname] = 1 if verdict.get("pass") else 0
                row[f"{tname}_contract"] = 1 if ok else 0
                row[f"{tname}_time"] = round(t_plan + t_exec, 1)
            row["score"] = sum(row[t] for t in TASKS)
            row["contracts_valid"] = sum(row[f"{t}_contract"] for t in TASKS)
            summary.append(row)
            with open(os.path.join(RESULTS, "summary.json"), "w") as f:
                json.dump(summary, f, indent=2)

    # ranking
    print("\n\n=== PAIR RANKING ===")
    summary.sort(key=lambda r: (-r["score"], -r["contracts_valid"],
                                sum(r[f"{t}_time"] for t in TASKS)))
    print(f"{'pair':55s} {'e2e':>4s} {'ctrct':>6s} {'time_s':>8s}")
    for r in summary:
        tot = sum(r[f"{t}_time"] for t in TASKS)
        print(f"{r['pair']:55s} {r['score']:>4d} {r['contracts_valid']:>6d} {tot:>8.1f}")


if __name__ == "__main__":
    run()

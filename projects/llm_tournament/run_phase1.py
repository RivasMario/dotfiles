"""Phase 1 solo screen: every model runs every task. Deterministic grading."""
import json
import os
import sys
import time
import urllib.request
import urllib.error

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tasks import TASKS

OLLAMA = os.environ.get("OLLAMA_URL", "http://100.81.194.15:30068")
RESULTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results")
os.makedirs(RESULTS, exist_ok=True)

MODELS = [
    # low tier
    "stablelm2:1.6b","granite3.3:2b","exaone3.5:2.4b","smollm2:1.7b",
    "qwen2.5:3b","qwen2.5-coder:3b","granite3.1-moe:3b","phi3.5","phi4-mini",
    "gemma3:4b",
    # high tier
    "mistral:7b","deepseek-r1:7b","qwen2.5:7b","qwen2.5-coder:7b",
    "exaone3.5:7.8b","granite3.3:8b","yi:9b","command-r7b",
]


def call(model: str, prompt: str, timeout: int = 300) -> tuple[str, float]:
    body = json.dumps({
        "model": model,
        "prompt": prompt,
        "stream": False,
        "keep_alive": 0,  # flush VRAM after each call per CLAUDE.md
        "options": {"num_ctx": 4096, "temperature": 0.2},
    }).encode()
    req = urllib.request.Request(
        f"{OLLAMA}/api/generate", data=body, headers={"Content-Type":"application/json"}
    )
    t0 = time.time()
    with urllib.request.urlopen(req, timeout=timeout) as r:
        data = json.loads(r.read())
    return data.get("response",""), time.time() - t0


def run():
    summary = []
    safe = lambda s: s.replace(":","_").replace("/","_")
    for model in MODELS:
        mdir = os.path.join(RESULTS, safe(model))
        os.makedirs(mdir, exist_ok=True)
        print(f"\n=== {model} ===", flush=True)
        row = {"model": model}
        for tname, tfn in TASKS.items():
            prompt, grade = tfn()
            try:
                output, dur = call(model, prompt)
                verdict = grade(output)
            except Exception as e:
                output, dur = "", 0.0
                verdict = {"pass": False, "reason": f"call error: {type(e).__name__}: {e}"}
            with open(os.path.join(mdir, f"{tname}.json"), "w") as f:
                json.dump({"prompt": prompt, "output": output, "dur_s": dur,
                           "verdict": verdict}, f, indent=2)
            mark = "PASS" if verdict.get("pass") else "FAIL"
            print(f"  {tname:20s} {mark:5s} {dur:6.1f}s  {verdict.get('reason') or verdict.get('got','')}", flush=True)
            row[tname] = 1 if verdict.get("pass") else 0
            row[f"{tname}_s"] = round(dur,1)
        row["score"] = sum(row[t] for t in TASKS)
        summary.append(row)
        with open(os.path.join(RESULTS, "summary.json"), "w") as f:
            json.dump(summary, f, indent=2)

    print("\n\n=== FINAL RANKING ===")
    summary.sort(key=lambda r: (-r["score"], sum(r[f"{t}_s"] for t in TASKS)))
    print(f"{'model':28s} {'score':>5s}  " + "  ".join(f"{t[:8]:>8s}" for t in TASKS))
    for r in summary:
        cells = "  ".join(f"{'PASS' if r[t] else 'FAIL':>8s}" for t in TASKS)
        print(f"{r['model']:28s} {r['score']:>5d}  {cells}")


if __name__ == "__main__":
    run()

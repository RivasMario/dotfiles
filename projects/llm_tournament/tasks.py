"""Task definitions + deterministic graders for phase 1 solo screen."""
import json
import re
import subprocess
import tempfile
import textwrap


TASKS = {}


def task(name):
    def deco(fn):
        TASKS[name] = fn
        return fn
    return deco


@task("01_codegen")
def codegen():
    prompt = textwrap.dedent("""
        Write a Python function named `fizzbuzz(n)` that returns a list of strings of length n.
        For each i from 1 to n:
          - multiples of 3 AND 5 -> "FizzBuzz"
          - multiples of 3 only  -> "Fizz"
          - multiples of 5 only  -> "Buzz"
          - else                 -> str(i)
        Return ONLY the Python code, no prose, no markdown fences.
    """).strip()

    def grade(output: str) -> dict:
        code = _strip_fences(output)
        try:
            ns = {}
            exec(code, ns)
            fn = ns.get("fizzbuzz")
            if fn is None:
                return {"pass": False, "reason": "no fizzbuzz fn"}
            got = fn(15)
            expected = ["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz",
                        "11","Fizz","13","14","FizzBuzz"]
            ok = got == expected
            return {"pass": ok, "got": str(got)[:200]}
        except Exception as e:
            return {"pass": False, "reason": f"{type(e).__name__}: {e}"}

    return prompt, grade


@task("02_bugfix")
def bugfix():
    prompt = textwrap.dedent("""
        The following Python function has a bug. Return ONLY the corrected function,
        no prose, no markdown fences.

        def avg(nums):
            total = 0
            for n in nums:
                total += n
            return total / len(nums) - 1
    """).strip()

    def grade(output: str) -> dict:
        code = _strip_fences(output)
        try:
            ns = {}
            exec(code, ns)
            fn = ns.get("avg")
            if fn is None:
                return {"pass": False, "reason": "no avg fn"}
            ok = abs(fn([1,2,3,4,5]) - 3.0) < 1e-9 and abs(fn([10,20]) - 15.0) < 1e-9
            return {"pass": ok, "got": f"avg([1..5])={fn([1,2,3,4,5])}"}
        except Exception as e:
            return {"pass": False, "reason": f"{type(e).__name__}: {e}"}

    return prompt, grade


@task("03_refactor")
def refactor():
    prompt = textwrap.dedent("""
        The project has three files that all reference the symbol `get_usr`:
          - src/api/routes.py
          - src/db/queries.py
          - tests/test_user.py
        Rename `get_usr` to `get_user` everywhere. Produce a plan as a JSON list,
        one entry per file. Each entry has keys: "file", "old", "new".
        Return ONLY the JSON, no prose.
    """).strip()

    def grade(output: str) -> dict:
        try:
            data = json.loads(_strip_fences(output))
        except Exception as e:
            return {"pass": False, "reason": f"json parse: {e}"}
        if not isinstance(data, list):
            return {"pass": False, "reason": "not a list"}
        files_expected = {"src/api/routes.py", "src/db/queries.py", "tests/test_user.py"}
        files_got = {e.get("file") for e in data if isinstance(e, dict)}
        missing = files_expected - files_got
        if missing:
            return {"pass": False, "reason": f"missing files: {missing}"}
        bad = [e for e in data if e.get("old") != "get_usr" or e.get("new") != "get_user"]
        if bad:
            return {"pass": False, "reason": f"wrong old/new: {bad}"}
        return {"pass": True, "got": f"{len(data)} entries"}

    return prompt, grade


@task("04_json_contract")
def json_contract():
    prompt = textwrap.dedent("""
        Return ONLY a JSON object matching this schema, no prose, no markdown:
        {
          "user_intent_verbatim": string,
          "goal": string,
          "constraints": array of strings,
          "acceptance_criteria": array of strings,
          "steps": array of objects each with keys "id" (int) and "action" (string),
          "risk_flags": array of strings
        }
        User intent: "Add rate limiting to the login endpoint, max 5 attempts per minute per IP. Must not break existing tests."
        Produce the JSON contract now.
    """).strip()

    def grade(output: str) -> dict:
        try:
            d = json.loads(_strip_fences(output))
        except Exception as e:
            return {"pass": False, "reason": f"json parse: {e}"}
        required = ["user_intent_verbatim","goal","constraints","acceptance_criteria","steps","risk_flags"]
        missing = [k for k in required if k not in d]
        if missing:
            return {"pass": False, "reason": f"missing keys: {missing}"}
        checks = []
        checks.append(isinstance(d["user_intent_verbatim"], str))
        checks.append(isinstance(d["goal"], str))
        checks.append(isinstance(d["constraints"], list))
        checks.append(isinstance(d["acceptance_criteria"], list))
        checks.append(isinstance(d["steps"], list))
        checks.append(isinstance(d["risk_flags"], list))
        if not all(checks):
            return {"pass": False, "reason": f"type mismatch: {checks}"}
        for s in d["steps"]:
            if not (isinstance(s, dict) and isinstance(s.get("id"), int) and isinstance(s.get("action"), str)):
                return {"pass": False, "reason": f"bad step: {s}"}
        # bonus: intent verbatim must contain core phrase
        if "rate limiting" not in d["user_intent_verbatim"].lower():
            return {"pass": False, "reason": "intent not verbatim"}
        return {"pass": True, "got": f"{len(d['steps'])} steps"}

    return prompt, grade


@task("05_ambiguous")
def ambiguous():
    prompt = textwrap.dedent("""
        User says: "make the dashboard faster"
        You are a planning agent. Do NOT write code. Instead, produce a JSON object
        with keys:
          - "clarifying_questions": array of strings (questions you would ask the user)
          - "assumptions": array of strings (assumptions you are making if no answer given)
          - "candidate_actions": array of strings (concrete actions you might take)
        Return ONLY the JSON, no prose.
    """).strip()

    def grade(output: str) -> dict:
        try:
            d = json.loads(_strip_fences(output))
        except Exception as e:
            return {"pass": False, "reason": f"json parse: {e}"}
        req = ["clarifying_questions","assumptions","candidate_actions"]
        missing = [k for k in req if k not in d]
        if missing:
            return {"pass": False, "reason": f"missing: {missing}"}
        if not all(isinstance(d[k], list) for k in req):
            return {"pass": False, "reason": "fields must be arrays"}
        # must have at least 1 clarifying question AND 1 assumption AND 1 action
        if min(len(d[k]) for k in req) < 1:
            return {"pass": False, "reason": "empty array"}
        return {"pass": True, "got": f"q={len(d['clarifying_questions'])} a={len(d['assumptions'])} act={len(d['candidate_actions'])}"}

    return prompt, grade


def _strip_fences(s: str) -> str:
    s = s.strip()
    # strip ```lang ... ``` if present
    m = re.match(r"^```[a-zA-Z]*\n(.*?)\n```\s*$", s, re.DOTALL)
    if m:
        return m.group(1).strip()
    # strip just leading ``` and trailing ```
    if s.startswith("```"):
        s = re.sub(r"^```[a-zA-Z]*\n?", "", s)
        s = re.sub(r"\n?```\s*$", "", s)
    return s.strip()

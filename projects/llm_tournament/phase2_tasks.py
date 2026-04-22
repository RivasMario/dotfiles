"""Phase 2 tasks: multi-step, planner→executor handoff.

Each task exposes:
  user_prompt: str                 # original user request (verbatim, goes into contract)
  grader(final_output: str) -> dict    # scores executor's final artifact
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import textwrap

TASKS = {}


def task(name):
    def deco(fn):
        TASKS[name] = fn
        return fn
    return deco


def strip_fences(s: str) -> str:
    s = s.strip()
    m = re.match(r"^```[a-zA-Z]*\n(.*?)\n```\s*$", s, re.DOTALL)
    if m:
        return m.group(1).strip()
    if s.startswith("```"):
        s = re.sub(r"^```[a-zA-Z]*\n?", "", s)
        s = re.sub(r"\n?```\s*$", "", s)
    return s.strip()


def run_py(code: str, argv=None, stdin=None, timeout=15) -> tuple[str, str, int]:
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as f:
        f.write(code)
        path = f.name
    try:
        cmd = [sys.executable, path] + (argv or [])
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, input=stdin)
        return r.stdout, r.stderr, r.returncode
    finally:
        os.unlink(path)


# -----------------------------------------------------------------------------


@task("01_cli_lines")
def cli_lines():
    user_prompt = (
        "Write a single-file Python CLI script. It takes a directory path as argv[1], "
        "walks recursively, counts lines in every .py file, and prints a JSON object "
        "mapping each relative file path (from the given dir) to its line count, plus "
        "a key 'total' with the grand total. No external deps. "
        "Return ONLY the Python code, no prose, no markdown fences."
    )

    def grader(output):
        code = strip_fences(output)
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "sub"))
            with open(os.path.join(d, "a.py"), "w") as f:
                f.write("print(1)\nprint(2)\nprint(3)\n")  # 3 lines
            with open(os.path.join(d, "sub", "b.py"), "w") as f:
                f.write("x=1\ny=2\n")  # 2 lines
            with open(os.path.join(d, "README.txt"), "w") as f:
                f.write("ignore me\n")
            out, err, rc = run_py(code, argv=[d])
            if rc != 0:
                return {"pass": False, "reason": f"rc={rc} err={err[:150]}"}
            try:
                data = json.loads(out.strip())
            except Exception as e:
                return {"pass": False, "reason": f"not JSON: {e} out={out[:120]}"}
            if data.get("total") != 5:
                return {"pass": False, "reason": f"total wrong: {data.get('total')}"}
            # two .py files tracked
            keys = [k for k in data if k != "total"]
            if len(keys) != 2:
                return {"pass": False, "reason": f"wrong file count: {keys}"}
            return {"pass": True, "got": f"total={data['total']}, files={len(keys)}"}

    return user_prompt, grader


# -----------------------------------------------------------------------------


@task("02_refactor_split")
def refactor_split():
    original = textwrap.dedent('''
        def process_order(items, tax_rate, customer_type):
            # validate
            if not items:
                raise ValueError("no items")
            for it in items:
                if it["price"] < 0 or it["qty"] < 0:
                    raise ValueError("bad item")
            # price
            subtotal = sum(it["price"] * it["qty"] for it in items)
            if customer_type == "vip":
                subtotal *= 0.9
            tax = subtotal * tax_rate
            total = subtotal + tax
            # format receipt
            lines = [f"{it['qty']} x {it['price']:.2f}" for it in items]
            receipt = "\\n".join(lines) + f"\\nTOTAL: {total:.2f}"
            return {"total": round(total, 2), "receipt": receipt}
    ''').strip()

    user_prompt = (
        "Refactor this Python function into exactly 3 smaller named helper functions "
        "(validation, pricing, formatting) plus the top-level `process_order` that "
        "calls them. Preserve behavior exactly. Return ONLY the refactored code, "
        "no prose, no markdown fences.\n\n"
        f"Original:\n{original}"
    )

    def grader(output):
        code = strip_fences(output)
        # must have process_order + at least 3 other def
        defs = re.findall(r"^\s*def\s+(\w+)\s*\(", code, re.MULTILINE)
        if "process_order" not in defs:
            return {"pass": False, "reason": f"no process_order. defs={defs}"}
        if len(set(defs)) < 4:
            return {"pass": False, "reason": f"need ≥4 defs, got {defs}"}
        # behavior
        test = textwrap.dedent('''
            items = [{"price":10.0,"qty":2},{"price":5.0,"qty":1}]
            r1 = process_order(items, 0.1, "normal")
            r2 = process_order(items, 0.1, "vip")
            assert abs(r1["total"] - 27.5) < 0.01, r1
            assert abs(r2["total"] - 24.75) < 0.01, r2
            try:
                process_order([], 0.1, "normal"); raise AssertionError("should raise")
            except ValueError: pass
            print("OK")
        ''')
        full = code + "\n" + test
        out, err, rc = run_py(full)
        if rc != 0 or "OK" not in out:
            return {"pass": False, "reason": f"behavior: rc={rc} err={err[:200]}"}
        return {"pass": True, "got": f"{len(set(defs))} fns, behavior OK"}

    return user_prompt, grader


# -----------------------------------------------------------------------------


@task("03_edge_tests")
def edge_tests():
    fn_code = textwrap.dedent('''
        def safe_div(a, b):
            if b == 0:
                return None
            return a / b
    ''').strip()

    user_prompt = (
        "Given this function, write a self-contained Python test script (no pytest, "
        "just plain asserts wrapped in try/except with counters) that exercises at "
        "least 4 distinct edge cases including: division by zero, negative numbers, "
        "zero numerator, and floating point. At end, print 'PASSED: N/M' where N is "
        "tests passed and M is total. Include the function definition at the top. "
        "Return ONLY the Python code, no prose, no markdown fences.\n\n"
        f"Function to test:\n{fn_code}"
    )

    def grader(output):
        code = strip_fences(output)
        if "safe_div" not in code:
            return {"pass": False, "reason": "function not included"}
        out, err, rc = run_py(code, timeout=10)
        if rc != 0:
            return {"pass": False, "reason": f"rc={rc} err={err[:150]}"}
        m = re.search(r"PASSED:\s*(\d+)\s*/\s*(\d+)", out)
        if not m:
            return {"pass": False, "reason": f"no PASSED tag. out={out[:150]}"}
        passed, total = int(m.group(1)), int(m.group(2))
        if total < 4:
            return {"pass": False, "reason": f"only {total} tests, need ≥4"}
        if passed < total:
            return {"pass": False, "reason": f"{passed}/{total} — some fail"}
        return {"pass": True, "got": f"{passed}/{total}"}

    return user_prompt, grader


# -----------------------------------------------------------------------------


@task("04_optimize_ambiguous")
def optimize_ambiguous():
    slow = textwrap.dedent('''
        def count_pairs(nums, target):
            # returns count of index pairs (i,j) with i<j where nums[i]+nums[j]==target
            c = 0
            for i in range(len(nums)):
                for j in range(i+1, len(nums)):
                    if nums[i] + nums[j] == target:
                        c += 1
            return c
    ''').strip()

    user_prompt = (
        "Make this Python function faster for large inputs. Preserve its exact "
        "return value for all inputs. Return ONLY the rewritten function named "
        "`count_pairs` with the same signature, no prose, no markdown fences.\n\n"
        f"Function:\n{slow}"
    )

    def grader(output):
        code = strip_fences(output)
        test = textwrap.dedent('''
            import random, time
            # correctness vs naive
            def naive(nums, t):
                c=0
                for i in range(len(nums)):
                    for j in range(i+1,len(nums)):
                        if nums[i]+nums[j]==t: c+=1
                return c
            for seed in [0,1,2]:
                random.seed(seed)
                xs=[random.randint(-10,10) for _ in range(30)]
                assert count_pairs(xs, 3) == naive(xs, 3), f"mismatch seed={seed}"
                assert count_pairs([], 5) == 0
                assert count_pairs([1,2], 3) == 1
            # speed on big input
            big=[random.randint(-100,100) for _ in range(2000)]
            t0=time.time(); count_pairs(big, 7); dt=time.time()-t0
            # naive on same would be ~2M ops; optimized should be well under 1s
            assert dt < 0.5, f"too slow: {dt:.2f}s"
            print("OK")
        ''')
        full = code + "\n" + test
        out, err, rc = run_py(full, timeout=20)
        if rc != 0 or "OK" not in out:
            return {"pass": False, "reason": f"rc={rc} err={err[:200]}"}
        return {"pass": True, "got": "correct + fast"}

    return user_prompt, grader

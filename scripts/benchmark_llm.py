import subprocess
import json
import time
import os
import re

OLLAMA_URL = "http://100.81.194.15:30068/api/generate"
PROXY = "127.0.0.1:1055"
PROMPT = "Write a complete, optimized Python function to find the longest palindromic substring in a given string using dynamic programming. Include comments explaining the time and space complexity."

def test_ollama(model_name):
    print(f"\n--- Benchmarking {model_name} (Ollama) ---")
    data = json.dumps({
        "model": model_name, 
        "prompt": PROMPT, 
        "stream": False,
        "keep_alive": 0 
    })
    cmd = [
        "curl", "-s", "--socks5-hostname", PROXY,
        "-H", "Content-Type: application/json",
        "-d", data, OLLAMA_URL
    ]
    
    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    end = time.time()
    
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return
        
    try:
        resp = json.loads(result.stdout)
        if "error" in resp:
            print(f"API Error: {resp['error']}")
            return
            
        eval_count = resp.get("eval_count", 0)
        eval_duration_ns = resp.get("eval_duration", 1)
        tps = eval_count / (eval_duration_ns / 1e9)
        print(f"Tokens: {eval_count}")
        print(f"Time:   {end - start:.2f}s")
        print(f"Speed:  {tps:.2f} tok/s")
    except json.JSONDecodeError:
        print(f"Parse failed. Output: {result.stdout[:100]}...")

def test_gemini_cli():
    print("\n--- Benchmarking Gemini (CLI) ---")
    cmd = ["gemini", "ask", PROMPT]
    
    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    end = time.time()
    
    if result.returncode != 0:
        print(f"CLI Error: {result.stderr}")
        return
        
    output = result.stdout
    words = len(re.findall(r'\w+', output))
    approx_tokens = int(words * 1.3)
    total_time = end - start
    tps = approx_tokens / total_time if total_time > 0 else 0
    
    print(f"Tokens: ~{approx_tokens} (Estimated from {words} words)")
    print(f"Time:   {total_time:.2f}s")
    print(f"Speed:  ~{tps:.2f} tok/s")

if __name__ == "__main__":
    print(f"Prompt: {PROMPT[:60]}...")
    test_ollama("qwen2.5-coder:7b")
    time.sleep(2)
    test_ollama("gemma4:e2b")
    time.sleep(2)
    test_ollama("llama3.2:3b")
    time.sleep(2)
    test_gemini_cli()

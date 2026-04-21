import json
import urllib.request
import urllib.error

OLLAMA_URL = "http://100.81.194.15:30068/api/generate"
PROXY = "127.0.0.1:1055"

# The IS (Intelligence Specialist) - Fast, organizes plans, synthesizes presentations
IS_MODEL = "llama3.2:3b" 

# The CT (Cryptologic Technician) - Heavy lifter, deep analysis, complex coding/extraction
CT_MODEL = "qwen2.5-coder:7b"

def ask_ollama(model, prompt, system_prompt=""):
    data = json.dumps({
        "model": model,
        "prompt": prompt,
        "system": system_prompt,
        "stream": False,
        "keep_alive": 0 # Free VRAM immediately after
    }).encode('utf-8')
    
    req = urllib.request.Request(OLLAMA_URL, data=data, headers={'Content-Type': 'application/json'})
    # Set up SOCKS5 proxy for urllib
    req.set_proxy(PROXY, 'socks5')
    
    try:
        # Use curl via subprocess since urllib proxying with SOCKS5 can be tricky without extra libs
        import subprocess
        cmd = [
            "curl", "-s", "--socks5-hostname", PROXY,
            "-H", "Content-Type: application/json",
            "-d", data, OLLAMA_URL
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            return json.loads(result.stdout).get("response", "")
        return f"Error: {result.stderr}"
    except Exception as e:
        return str(e)

def run_navy_workflow(mission_objective):
    print(f"\n🎯 MISSION: {mission_objective}\n")
    print("="*60)
    
    # PHASE 1: IS (Small Model) - Planning & Tasking
    print(f"👮 [IS Agent] ({IS_MODEL}) drafting the collection plan...")
    is_planner_prompt = f"You are an Intelligence Specialist. Create a concise, 3-step technical execution plan for this mission: '{mission_objective}'. Output ONLY the numbered steps."
    plan = ask_ollama(IS_MODEL, is_planner_prompt)
    print(f"\n📋 THE PLAN:\n{plan}\n")
    print("="*60)
    
    # PHASE 2: CT (Large Model) - Deep Work / Execution
    print(f"🎧 [CT Agent] ({CT_MODEL}) executing the collection plan...")
    ct_worker_prompt = f"You are a Cryptologic Technician (Expert Coder/Analyst). Execute this plan:\n{plan}\n\nProvide the raw technical code or analysis required."
    raw_intel = ask_ollama(CT_MODEL, ct_worker_prompt)
    print(f"\n💻 RAW INTEL / CODE:\n{raw_intel[:500]}... [TRUNCATED]\n")
    print("="*60)
    
    # PHASE 3: IS (Small Model) - Synthesis & Presentation to CO
    print(f"👮 [IS Agent] ({IS_MODEL}) briefing the CO...")
    is_brief_prompt = f"You are an Intelligence Specialist briefing the Commanding Officer. Summarize this raw technical data into a professional, non-jargon executive summary (BLUF - Bottom Line Up Front). Keep it under 4 sentences.\n\nRAW DATA:\n{raw_intel}"
    briefing = ask_ollama(IS_MODEL, is_brief_prompt)
    print(f"\n🎖️ CO BRIEFING:\n{briefing}\n")
    print("="*60)

if __name__ == "__main__":
    mission = "Write a Python script to scan a network for open SSH ports and log the results."
    run_navy_workflow(mission)

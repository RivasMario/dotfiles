# =============================================================================
# install.ps1 — Mario's dotfiles bootstrap for Windows
# Run from an elevated PowerShell prompt or with winget available.
# Tailscale is deliberately not installed on Windows: the homelab is reached
# only through the Fedora WSL Tailscale (install.sh).
# =============================================================================

param(
    [switch]$WithRE
)

$ErrorActionPreference = "Stop"
$dotfiles = Split-Path -Parent $MyInvocation.MyCommand.Definition
$userHome = $env:USERPROFILE

Write-Host ""
Write-Host "==> Mario's dotfiles installer (Windows)" -ForegroundColor Cyan
Write-Host "    Dotfiles dir: $dotfiles"
Write-Host ""

# -----------------------------------------------------------------------------
# PACKAGES (winget)
# -----------------------------------------------------------------------------
$packages = @(
    @{ id = "MSYS2.MSYS2";              name = "MSYS2 (zsh + tmux)" },
    @{ id = "junegunn.fzf";             name = "fzf" },
    @{ id = "Fastfetch-cli.Fastfetch";  name = "fastfetch" },
    @{ id = "lsd-rs.lsd";               name = "lsd" },
    @{ id = "Python.Python.3.12";       name = "Python 3.12" },
    @{ id = "OpenJS.NodeJS.22";         name = "Node.js 22" },
    @{ id = "calibre.calibre";          name = "Calibre" },
    @{ id = "GIMP.GIMP";               name = "GIMP" },
    @{ id = "Inkscape.Inkscape";        name = "Inkscape" }
)

$ErrorActionPreference = "Continue"
foreach ($pkg in $packages) {
    $installed = winget list --id $pkg.id --accept-source-agreements 2>$null | Select-String $pkg.id
    if ($installed) {
        Write-Host "  [skip] $($pkg.name) already installed"
    } else {
        Write-Host "  [install] $($pkg.name)..."
        winget install --id $pkg.id -e --silent --accept-package-agreements --accept-source-agreements *>$null
        Write-Host "  [ok] $($pkg.name)"
    }
}

# Install zsh + tmux via MSYS2 pacman
Write-Host ""
Write-Host "==> Installing zsh + tmux via MSYS2..."
& "C:\msys64\usr\bin\pacman.exe" -S --noconfirm zsh tmux *>$null
Write-Host "  [ok] zsh + tmux"

# -----------------------------------------------------------------------------
# PATH — add MSYS2, Python, agy, ~/.local/bin, ~/.npm-global permanently
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Configuring PATH..."
$pyDir = "$userHome\AppData\Local\Programs\Python\Python312"
if (Test-Path "$userHome\AppData\Local\Programs\Python\Python312-arm64\python.exe") {
    $pyDir = "$userHome\AppData\Local\Programs\Python\Python312-arm64"
}
$pathsToAdd = @(
    "C:\msys64\usr\bin",
    $pyDir,
    "$pyDir\Scripts",
    "$userHome\AppData\Local\agy\bin",
    "$userHome\.local\bin",
    "$userHome\.npm-global",
    "$userHome\.npm-global\bin"
)
$rawUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
# Strip any accidental .exe file paths (e.g. .local\bin\claude.exe) and normalize directory paths
$pathEntries = @(
    $rawUserPath -split ';' |
    Where-Object { $_ -and ($_ -notmatch '\.exe$') } |
    ForEach-Object { $_.TrimEnd('\') }
)
$toAdd = $pathsToAdd | Where-Object { $pathEntries -notcontains $_.TrimEnd('\') }
if ($toAdd -or ($rawUserPath -match '\.exe')) {
    $newPath = (@($pathEntries) + @($toAdd) | Select-Object -Unique) -join ";"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "  Added: $($toAdd -join ', ')"
} else {
    Write-Host "  Already configured"
}
# Refresh current session PATH so newly installed winget tools (node/npm, python, claude) are found immediately
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")

# -----------------------------------------------------------------------------
# NPM GLOBAL PREFIX
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Configuring npm global prefix..."
New-Item -ItemType Directory -Force -Path "$userHome\.npm-global" | Out-Null
& npm config set prefix "$userHome\.npm-global" *>$null

# -----------------------------------------------------------------------------
# NPM TOOLS (Claude Code, Gemini CLI)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing npm tools..."
$npmTools = @(
    @{ pkg = "@anthropic-ai/claude-code"; cmd = "claude" },
    @{ pkg = "@google/gemini-cli";        cmd = "gemini" }
)
foreach ($tool in $npmTools) {
    if (Get-Command $tool.cmd -ErrorAction SilentlyContinue) {
        Write-Host "  [skip] $($tool.cmd) already installed ($((Get-Command $tool.cmd).Source))"
    } else {
        Write-Host "  [install] $($tool.pkg)..."
        & npm install -g $tool.pkg *>$null
        Write-Host "  [ok] $($tool.cmd)"
    }
}

# -----------------------------------------------------------------------------
# OH MY ZSH
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing Oh My Zsh..."
if (!(Test-Path "$userHome\.oh-my-zsh")) {
    $env:RUNZSH = "no"; $env:CHSH = "no"; $env:KEEP_ZSHRC = "yes"
    bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended' *>$null
    Write-Host "  [ok] Oh My Zsh installed"
} else {
    Write-Host "  [skip] Oh My Zsh already installed"
}

# zsh plugins
$zshCustom = "$userHome\.oh-my-zsh\custom"
$plugins = @(
    @{ dir = "zsh-autosuggestions";   url = "https://github.com/zsh-users/zsh-autosuggestions" },
    @{ dir = "zsh-syntax-highlighting"; url = "https://github.com/zsh-users/zsh-syntax-highlighting" }
)
foreach ($p in $plugins) {
    $dest = "$zshCustom\plugins\$($p.dir)"
    if (!(Test-Path $dest)) {
        git clone $p.url $dest *>$null
        Write-Host "  [ok] $($p.dir)"
    } else {
        Write-Host "  [skip] $($p.dir) already installed"
    }
}

# -----------------------------------------------------------------------------
# POKEMON COLORSCRIPTS
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing pokemon-colorscripts..."
$pokemonSrc = "$dotfiles\pokemon-colorscripts"
$pokemonDst = "$userHome\.local\opt\pokemon-colorscripts"
$localBin   = "$userHome\.local\bin"
New-Item -ItemType Directory -Force -Path $pokemonDst, $localBin | Out-Null
Copy-Item "$pokemonSrc\colorscripts" $pokemonDst -Recurse -Force
Copy-Item "$pokemonSrc\pokemon-colorscripts.py" $pokemonDst -Force
Copy-Item "$pokemonSrc\pokemon.json" $pokemonDst -Force

$wrapperPath = "$localBin\pokemon-colorscripts"
$python = "$pyDir\python.exe"
Set-Content -Path $wrapperPath -Value "#!/bin/bash`nexec `"$python`" `"$pokemonDst\pokemon-colorscripts.py`" `"`$@`""
Write-Host "  [ok] pokemon-colorscripts -> $wrapperPath"

# -----------------------------------------------------------------------------
# CLI-ANYTHING (KiCad, GIMP, Inkscape harnesses)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing CLI-Anything plugin..."
$cliAnythingRepo = "$dotfiles\CLI-Anything"
if (!(Test-Path "$cliAnythingRepo\.git")) {
    git clone https://github.com/HKUDS/CLI-Anything.git $cliAnythingRepo *>$null
}
$pluginDst = "$userHome\.claude\plugins\cli-anything"
if ((Test-Path "$cliAnythingRepo\cli-anything-plugin") -and !(Test-Path $pluginDst)) {
    New-Item -ItemType Directory -Force -Path "$userHome\.claude\plugins" | Out-Null
    Copy-Item "$cliAnythingRepo\cli-anything-plugin" $pluginDst -Recurse
    Write-Host "  [ok] cli-anything plugin installed"
} else {
    Write-Host "  [skip] cli-anything plugin already installed"
}

# Install pre-built harnesses for GIMP and Inkscape
foreach ($app in @("gimp", "inkscape")) {
    $harness = "$cliAnythingRepo\$app\agent-harness"
    if (Test-Path $harness) {
        & $python -m pip install -e $harness --quiet *>$null
        Write-Host "  [ok] cli-anything-$app harness"
    }
}

# -----------------------------------------------------------------------------
# GRAPHIFY (Knowledge Graph & Codebase Intelligence)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing Graphify (codebase knowledge graph)..."
& $python -m pip install graphifyy --quiet *>$null
Write-Host "  [ok] graphifyy Python package"

# -----------------------------------------------------------------------------
# AI ASSISTANT PLUGINS & SKILLS (Claude Code, Antigravity, Gemini CLI)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing AI Assistant plugins & skills..."

# Claude Code plugins
& claude plugin marketplace add JuliusBrussee/caveman *>$null
& claude plugin marketplace add forrestchang/andrej-karpathy-skills *>$null
& claude plugin install caveman@caveman *>$null
& claude plugin install andrej-karpathy-skills@karpathy-skills *>$null
& claude plugin install rust-analyzer-lsp@claude-plugins-official *>$null
$ErrorActionPreference = "Stop"
Write-Host "  [ok] Claude Code plugins (caveman, karpathy-skills, rust-analyzer-lsp)"

# Skills: shared skills\ go to every agent, then .claude\skills and .gemini\skills
# overlay tool-specific skills (or override a shared one of the same name)
$claudeSkillsDir = "$userHome\.claude\skills"
$geminiConfigSkillsDir = "$userHome\.gemini\config\skills"
$geminiSkillsDir = "$userHome\.gemini\skills"
New-Item -ItemType Directory -Force -Path $claudeSkillsDir, $geminiConfigSkillsDir, $geminiSkillsDir | Out-Null

function Install-Skills($src, [string[]]$targets) {
    if (!(Test-Path $src)) { return }
    foreach ($skillDir in Get-ChildItem -Directory $src) {
        foreach ($targetDir in $targets) {
            $dest = "$targetDir\$($skillDir.Name)"
            if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
            Copy-Item $skillDir.FullName $dest -Recurse -Force
        }
        Write-Host "  [ok] $($skillDir.Name) skill ($(Split-Path -Leaf (Split-Path $src))\$(Split-Path -Leaf $src))"
    }
}
Install-Skills "$dotfiles\skills"         @($claudeSkillsDir, $geminiConfigSkillsDir, $geminiSkillsDir)
Install-Skills "$dotfiles\.claude\skills" @($claudeSkillsDir)
Install-Skills "$dotfiles\.gemini\skills" @($geminiConfigSkillsDir, $geminiSkillsDir)


# Plugins bundle (graphify)
$graphifyPluginSrc = "$dotfiles\plugins\graphify"
if (Test-Path $graphifyPluginSrc) {
    $claudePluginDst = "$userHome\.claude\plugins\graphify"
    $geminiPluginDst = "$userHome\.gemini\config\plugins\graphify"
    New-Item -ItemType Directory -Force -Path $claudePluginDst, $geminiPluginDst | Out-Null
    Copy-Item "$graphifyPluginSrc\*" $claudePluginDst -Recurse -Force
    Copy-Item "$graphifyPluginSrc\*" $geminiPluginDst -Recurse -Force
    Write-Host "  [ok] graphify plugin (Claude Code & Antigravity)"
}

# -----------------------------------------------------------------------------
# SYMLINK DOTFILES (hard links on Windows)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Linking dotfiles..."
New-Item -ItemType Directory -Force -Path "$userHome\.config\fastfetch" | Out-Null
New-Item -ItemType Directory -Force -Path "$userHome\.claude" | Out-Null

$links = @(
    @{ src = "$dotfiles\.tmux.conf";    dst = "$userHome\.tmux.conf" },
    @{ src = "$dotfiles\.tmux-help.txt"; dst = "$userHome\.tmux-help.txt" },
    @{ src = "$dotfiles\.zshrc";        dst = "$userHome\.zshrc" },
    @{ src = "$dotfiles\config\fastfetch\config-pokemon.jsonc"; dst = "$userHome\.config\fastfetch\config-pokemon.jsonc" },
    @{ src = "$dotfiles\.claude\settings.json"; dst = "$userHome\.claude\settings.json" },
    @{ src = "$dotfiles\AGENTS.md";     dst = "$userHome\AGENTS.md" },
    @{ src = "$dotfiles\GEMINI.md";     dst = "$userHome\GEMINI.md" },
    @{ src = "$dotfiles\CLAUDE.md";     dst = "$userHome\CLAUDE.md" }
)
foreach ($link in $links) {
    if (Test-Path $link.dst) { Remove-Item $link.dst -Force }
    New-Item -ItemType HardLink -Path $link.dst -Target $link.src | Out-Null
    Write-Host "  linked: $($link.dst)"
}

if ($WithRE -and (Test-Path "$userHome\open-astro-cps\scripts\setup-re.ps1")) {
    & "$userHome\open-astro-cps\scripts\setup-re.ps1"
}

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Done! Open a new terminal and run: zsh" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  - Log in to Claude Code: claude"
Write-Host "  - Log in to Antigravity: agy"
Write-Host "  - Log in to Gemini CLI:  gemini"
Write-Host "  - Build knowledge graph: /graphify ."
Write-Host "  - Generate KiCad CLI:    /cli-anything:cli-anything https://github.com/KiCad/kicad-source-mirror"

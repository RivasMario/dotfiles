# =============================================================================
# install.ps1 — Mario's dotfiles bootstrap for Windows
# Run from an elevated PowerShell prompt or with winget available.
# =============================================================================

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
    @{ id = "tailscale.tailscale";      name = "Tailscale" },
    @{ id = "GIMP.GIMP";               name = "GIMP" },
    @{ id = "Inkscape.Inkscape";        name = "Inkscape" }
)

foreach ($pkg in $packages) {
    $installed = winget list --id $pkg.id 2>$null | Select-String $pkg.id
    if ($installed) {
        Write-Host "  [skip] $($pkg.name) already installed"
    } else {
        Write-Host "  [install] $($pkg.name)..."
        winget install --id $pkg.id -e --silent 2>&1 | Out-Null
        Write-Host "  [ok] $($pkg.name)"
    }
}

# Install zsh + tmux via MSYS2 pacman
Write-Host ""
Write-Host "==> Installing zsh + tmux via MSYS2..."
& "C:\msys64\usr\bin\pacman.exe" -S --noconfirm zsh tmux 2>&1 | Out-Null
Write-Host "  [ok] zsh + tmux"

# -----------------------------------------------------------------------------
# PATH — add MSYS2, Python, ~/.local/bin permanently
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Configuring PATH..."
$pathsToAdd = @(
    "C:\msys64\usr\bin",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\Scripts",
    "C:\Users\$env:USERNAME\.local\bin",
    "C:\Users\$env:USERNAME\.npm-global\bin"
)
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$toAdd = $pathsToAdd | Where-Object { $currentPath -notlike "*$_*" }
if ($toAdd) {
    $newPath = $currentPath + ";" + ($toAdd -join ";")
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "  Added: $($toAdd -join ', ')"
} else {
    Write-Host "  Already configured"
}

# -----------------------------------------------------------------------------
# NPM GLOBAL PREFIX
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Configuring npm global prefix..."
New-Item -ItemType Directory -Force -Path "$userHome\.npm-global" | Out-Null
& npm config set prefix "$userHome\.npm-global"

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
        Write-Host "  [skip] $($tool.cmd) already installed"
    } else {
        Write-Host "  [install] $($tool.pkg)..."
        npm install -g $tool.pkg 2>&1 | Out-Null
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
    bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended' 2>&1 | Out-Null
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
        git clone $p.url $dest 2>&1 | Out-Null
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
$python = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\python.exe"
Set-Content -Path $wrapperPath -Value "#!/bin/bash`nexec `"$python`" `"$pokemonDst\pokemon-colorscripts.py`" `"`$@`""
Write-Host "  [ok] pokemon-colorscripts -> $wrapperPath"

# -----------------------------------------------------------------------------
# CLI-ANYTHING (KiCad, GIMP, Inkscape harnesses)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Installing CLI-Anything plugin..."
$cliAnythingRepo = "$userHome\CLI-Anything"
if (!(Test-Path $cliAnythingRepo)) {
    git clone https://github.com/HKUDS/CLI-Anything.git $cliAnythingRepo 2>&1 | Out-Null
}
$pluginDst = "$userHome\.claude\plugins\cli-anything"
if (!(Test-Path $pluginDst)) {
    Copy-Item "$cliAnythingRepo\cli-anything-plugin" $pluginDst -Recurse
    Write-Host "  [ok] cli-anything plugin installed"
} else {
    Write-Host "  [skip] cli-anything plugin already installed"
}

# Install pre-built harnesses for GIMP and Inkscape
foreach ($app in @("gimp", "inkscape")) {
    $harness = "$cliAnythingRepo\$app\agent-harness"
    if (Test-Path $harness) {
        & $python -m pip install -e $harness --quiet
        Write-Host "  [ok] cli-anything-$app harness"
    }
}

# Caveman plugin for Claude Code
Write-Host ""
Write-Host "==> Installing Claude Code plugins..."
bash -c "yes | claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true" 2>&1 | Out-Null
bash -c "yes | claude plugin install caveman@caveman 2>/dev/null || true" 2>&1 | Out-Null
Write-Host "  [ok] caveman plugin"

# -----------------------------------------------------------------------------
# SYMLINK DOTFILES (hard links on Windows)
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Linking dotfiles..."
New-Item -ItemType Directory -Force -Path "$userHome\.config\fastfetch" | Out-Null

$links = @(
    @{ src = "$dotfiles\.tmux.conf";    dst = "$userHome\.tmux.conf" },
    @{ src = "$dotfiles\.tmux-help.txt"; dst = "$userHome\.tmux-help.txt" },
    @{ src = "$dotfiles\.zshrc";        dst = "$userHome\.zshrc" },
    @{ src = "$dotfiles\config\fastfetch\config-pokemon.jsonc"; dst = "$userHome\.config\fastfetch\config-pokemon.jsonc" }
)
foreach ($link in $links) {
    if (Test-Path $link.dst) { Remove-Item $link.dst -Force }
    New-Item -ItemType HardLink -Path $link.dst -Target $link.src | Out-Null
    Write-Host "  linked: $($link.dst)"
}

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "==> Done! Open a new terminal and run: zsh" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  - Log in to Claude Code: claude"
Write-Host "  - Log in to Gemini CLI:  gemini"
Write-Host "  - Connect Tailscale:     tailscale up --accept-dns=false --accept-routes"
Write-Host "  - Generate KiCad CLI:    /cli-anything:cli-anything https://github.com/KiCad/kicad-source-mirror"

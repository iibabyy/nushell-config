export alias cfg = z ($env.HOME + "/.config")
export alias c = clear
export alias res = exec nu
export alias vi = nvim .
export alias vu = nvim $nu.default-config-dir
export alias vn = nvim ($env.HOME + "/.config/nvim")

export alias l = ls
export alias gg = lazygit
export alias gd = lazydocker
export alias claude = claude --allow-dangerously-skip-permissions
export alias cl = claude
export alias cx = codex
export alias agy = agy --dangerously-skip-permissions
export alias gem = gemini
export alias zu = zed $nu.default-config-dir
# export alias npm = bun
# export alias npx = bunx

# Git Aliases
export alias g = git
export alias ga = git add
export alias gc = git commit '-m'
export alias gcl = git clone
export alias gp = git push
export alias gpl = git pull
export alias gst = git status
export alias gsw = git switch

use git_tree/completers.nu git_branches
export def pr-to [
	branch: string@git_branches,
	--push,
	--merge
] {
    if $push { gp }
    try { gh pr create --base $branch --fill }
    if $merge { gh pr merge --merge }
}

# Cargo Aliases
export alias cr = cargo run
export alias cb = cargo build
export alias cmod = cargo modules structure
export alias ct = cargo nextest run
export alias cw = cargo watch '-q' '-c' '-x'

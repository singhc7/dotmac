# fzf configuration
# ==========================================
# 1. Environment Variables
# ==========================================
# UI Styling (Adwaita darker — matches kitty theme)
export FZF_DEFAULT_OPTS=" \
--color=fg:#deddda,bg:#000000,hl:#62a0ea \
--color=fg+:#f6f5f4,bg+:#1c1c1c,hl+:#99c1f1 \
--color=info:#5bc8af,prompt:#57e389,pointer:#ed333b \
--color=marker:#57e389,spinner:#9141ac,header:#9a9996 \
--multi --height 40% --layout=reverse --border --prompt='λ ' --pointer='▶' --marker='✓'"

# Use fd instead of find (if available) for better performance and respecting .gitignore
if command -v fd > /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
fi

# Preview command using bat (if available) — scoped to Ctrl+T only
# so it doesn't error on directory pickers like Alt+C
if command -v bat > /dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :500 {}'"
fi

# ==========================================
# 2. Key Bindings & Completion
# ==========================================
# Attempt to load shell integrations from Nix System Profile
# shellcheck disable=SC2154
if (( $+commands[fzf] )); then
    # LSP Fix 1: Extract to a temporary variable to avoid nested expansion warnings
    FZF_BIN="${commands[fzf]}"

    # Apply modifiers to the flat variable
    NIX_STORE_FZF="${FZF_BIN:A:h:h}/share/fzf"

    if [[ -d "$NIX_STORE_FZF" ]]; then
        # LSP Fix 2: Tell ShellCheck to ignore dynamic source paths it can't statically verify
        # shellcheck disable=SC1091
        source "$NIX_STORE_FZF/key-bindings.zsh"
        # shellcheck disable=SC1091
        source "$NIX_STORE_FZF/completion.zsh"
    fi
fi

# ==========================================
# 3. Custom Functions & Aliases
# ==========================================

# fe [QUERY] - Edit the selected file with default editor (nvim)
# Supports multi-selection
fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}

# fps - list processes and kill selected (multi-select supported)
fps() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ -n "$pid" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# fgitlog - browse git log and copy selected hash to clipboard
fgl() {
    local commits
    commits=$(git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
            fzf --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
            --header 'CTRL-S toggle sort | ENTER copies hash' \
            --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
        --preview-window=right:60%)
    if [ -n "$commits" ]; then
        local commit=$(echo "$commits" | grep -o "[a-f0-9]\{7\}" | head -1)
        echo "$commit" | tr -d '\n' | pbcopy
        echo "Copied $commit to clipboard"
    fi
}

# fgb - fuzzy switch git branch
fgb() {
    local branch
    branch=$(git branch --all --sort=-committerdate --format='%(refname:short)' | \
            fzf --reverse --preview 'git log --oneline --graph --color=always -20 {1}' \
        --header 'Switch branch')
    if [ -n "$branch" ]; then
        # Strip remotes/origin/ prefix for remote branches
        git checkout "${branch#remotes/origin/}"
    fi
}

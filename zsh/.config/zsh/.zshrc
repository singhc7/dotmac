# ==========================================
# Powerlevel10k Instant Prompt
# Must run before any output. Cached prompt is regenerated on each
# config change; safe to keep at the very top of .zshrc.
# ==========================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==========================================
# Antidote Load (installed by forge)
# ==========================================
source ~/.antidote/antidote.zsh

# Load your plugins (Autosuggestions, Completions, etc.)
antidote load

# ==========================================
# Modular Configurations
# ==========================================
ZSH_CONFIG_DIR="$ZDOTDIR/.zsh"

# Fallback: resolve relative to this script if ZDOTDIR isn't set
if [[ ! -d "$ZSH_CONFIG_DIR" ]]; then
    ZSH_CONFIG_DIR="${${(%):-%x}:h}/.zsh"
fi

# 1. Exports first (sets up PATH for tools)
[[ -f "$ZSH_CONFIG_DIR/exports.zsh" ]] && source "$ZSH_CONFIG_DIR/exports.zsh"

# 2. Options next (sets up shell options and keybindings like vi-mode)
[[ -f "$ZSH_CONFIG_DIR/options.zsh" ]] && source "$ZSH_CONFIG_DIR/options.zsh"

# 3. Integrations next (initializes tools using PATH)
[[ -f "$ZSH_CONFIG_DIR/integrations.zsh" ]] && source "$ZSH_CONFIG_DIR/integrations.zsh"

# 4. Everything else
for config in functions aliases; do
    if [[ -f "$ZSH_CONFIG_DIR/$config.zsh" ]]; then
        source "$ZSH_CONFIG_DIR/$config.zsh"
    fi
done

# ==========================================
# Powerlevel10k Configuration
# ==========================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

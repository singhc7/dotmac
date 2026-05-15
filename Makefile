DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)

PACKAGES := zsh git kitty nvim tmux fzf eza mpv aria2 yt-dlp tealdeer scripts p10k karabiner

.PHONY: help stow unstow restow list

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Examples:"
	@echo "    make stow PKG=git        Stow only git"
	@echo "    make unstow PKG=kitty    Unstow only kitty"
	@echo "    make restow              Re-stow all packages"

stow: ## Stow a package (PKG=name) or all packages
ifdef PKG
	@test -d "$(DOTFILES_DIR)/$(PKG)" || { echo "Error: package '$(PKG)' not found"; exit 1; }
	stow -d $(DOTFILES_DIR) -t $(HOME_DIR) $(PKG)
else
	@for pkg in $(PACKAGES); do \
		echo "Stowing $$pkg..."; \
		stow -d $(DOTFILES_DIR) -t $(HOME_DIR) $$pkg; \
	done
endif

unstow: ## Unstow a package (PKG=name) or all packages
ifdef PKG
	@test -d "$(DOTFILES_DIR)/$(PKG)" || { echo "Error: package '$(PKG)' not found"; exit 1; }
	stow -d $(DOTFILES_DIR) -t $(HOME_DIR) -D $(PKG)
else
	@for pkg in $(PACKAGES); do \
		echo "Unstowing $$pkg..."; \
		stow -d $(DOTFILES_DIR) -t $(HOME_DIR) -D $$pkg; \
	done
endif

restow: ## Re-stow all packages (clean + re-link)
	@for pkg in $(PACKAGES); do \
		echo "Re-stowing $$pkg..."; \
		stow -d $(DOTFILES_DIR) -t $(HOME_DIR) -R $$pkg; \
	done

list: ## List all stow packages
	@echo "Available packages:"; \
	for pkg in $(PACKAGES); do echo "  $$pkg"; done

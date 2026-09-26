# Install and configure zsh
# https://nix-community.github.io/home-manager/options/home-manager/programs/zsh.html
{ ... }:
let
  systemModule = { ... }: {
    programs.zsh.enable = true;
  };

  homeModule =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        autocd = true;

        # Move zsh's config files out of $HOME into XDG_CONFIG_HOME,
        # matching the old zshenv's `ZDOTDIR=$XDG_CONFIG_HOME/zsh`.
        dotDir = "${config.xdg.configHome}/zsh";

        enableCompletion = true;
        autosuggestion = {
          enable = true;
          strategy = [ "history" ];
        };

        syntaxHighlighting.enable = true;

        # bashcompinit enables bash-style `complete -C ...` completions
        # (used by Terraform); compinit's cache moves under XDG_CACHE_HOME,
        # matching the old completion.zsh.
        completionInit = ''
          autoload -U bashcompinit && bashcompinit
          autoload -U compinit && compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
        '';

        # Keep plenty of history, deduplicated, written incrementally, but
        # not shared live between sessions.
        history = {
          size = 100000;
          save = 100000;
          path = "${config.xdg.dataHome}/zsh/zhistory";
          append = true;
          share = false;
          extended = true;
          expireDuplicatesFirst = true;
          ignoreDups = true;
          ignoreAllDups = true;
          findNoDups = true;
          ignoreSpace = true;
          saveNoDups = true;
        };

        historySubstringSearch.enable = true;

        # INC_APPEND_HISTORY_TIME/NO_BEEP have no dedicated home-manager
        # option; add them alongside the options `history` above derives.
        setOptions = [
          "INC_APPEND_HISTORY_TIME"
          "NO_BEEP"
        ];

        shellAliases = {
          # Alias vi to nvim as Homebrew manages vi to be a symlink to
          # vim as long vim is still installed
          vi = "$EDITOR";

          # Use eza instead of ls if available
          ls = "eza --icons --group-directories-first";
          la = "eza -a -g --icons --group-directories-first";
          ld = "eza -D -a -g --icons";
          ll = "eza -lahg --icons --git --group-directories-first";
          lt = "eza --tree --level=2 --icons";
          tree = "eza --tree --icons";

          # Always enable colors for *grep outputs
          grep = "grep --color=auto";
          fgrep = "fgrep --color=auto";
          egrep = "egrep --color=auto";

          # Use bat by default for cat
          cat = "bat --paging=never";

          # Enable simple aliases to be sudo'ed. ("sudone"?)
          # http://www.gnu.org/software/bash/manual/bashref.html#Aliases says: "If the
          # last character of the alias value is a space or tab character, then the next
          # command word following the alias is also checked for alias expansion."
          sudo = "sudo ";

          # Because we all forget sudo
          pls = "sudo !!";

          # Print each PATH entry on a separate line
          path = "echo -e \${PATH//:/\\n}";
          fpath = "echo -e \${FPATH//:/\\n}";

          # IP addresses
          myip = "dig +short myip.opendns.com @resolver1.opendns.com";
          localip = "ipconfig getifaddr en0";

          # Some weather forecast aliases, because fun
          wetter_burgdorf = "curl http://wttr\.in/burgdorf";
          wetter_bern = "curl http://wttr\.in/bern";
          wetter_burgdorf2 = "curl http://v2.wttr\.in/burgdorf";
          wetter_bern2 = "curl http://v2.wttr\.in/bern";

          # Some GitHub copilot aliases if gh is available
          ghe = "GH_HOST=github.unibe.ch gh";
        }
        // (
          if pkgs.stdenv.hostPlatform.isLinux then
            { }
          else
            {
              # Easy build nix config
              u = "darwin-switch-summary";
            }
        );

        plugins = [
          {
            # Full vi mode: `bindkey -v`, surround text objects, and mode
            # indication, matching the old `jeffreytse/zsh-vi-mode` zinit
            # plugin. ZVM_* variables must be set before the plugin loads.
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          {
            # fzf-tab: fuzzy tab-completion menu (Aloxaf/fzf-tab); loaded
            # after zsh-vi-mode, still before syntax highlighting (order
            # 1200), matching the old zinit load order.
            name = "zsh-fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
        ];

        initContent = lib.mkMerge [
          (lib.mkOrder 560 ''
            # zsh-completions: extra completion definitions
            # (zsh-users/zsh-completions), must be on $fpath before compinit.
            fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)

            _comp_options+=(globdots) # with hidden files
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' completer _extensions _complete
            zstyle ':completion:*' menu no
            zstyle ':completion:*' use-cache on
            zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/.zcompcache"
            zstyle ':completion:*:*:*:*:descriptions' format '%F{green} -- %d --%f'
            zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
            zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
            zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
            zstyle ':completion:*' group-name ""
            zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
            zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
            zstyle ':completion:*' squeeze-slashes true
            zstyle ':completion:*' complete-options true
            zstyle ':completion:*' rehash true
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
          '')

          (lib.mkOrder 800 ''
            ZVM_VI_SURROUND_BINDKEY='s-prefix'
            ZVM_INIT_MODE=sourcing
            KEYTIMEOUT=1
          '')

          ''
            # Values that must be computed at shell start (not static Nix
            # values): GPG_TTY needs the current TTY, LESS_TERMCAP_md needs
            # tput's terminfo lookup, and macOS pre-sets LSCOLORS which would
            # otherwise shadow LS_COLORS.
            unset LSCOLORS
            export GPG_TTY=$(tty)
            export LESS_TERMCAP_md="$(tput bold; tput setaf 136)"

            # Search history with Up/Down based on what's already typed on
            # the prompt line. Bound after zsh-vi-mode loads (order 900) so
            # its own arrow-key bindings don't win.
            #bindkey "^[[A" history-beginning-search-backward
            #bindkey "^[[B" history-beginning-search-forward

            # 1Password CLI + Terraform completions, kept from the old
            # config; both are Homebrew-managed (see homebrew.nix).
            if command -v op &>/dev/null; then
              eval "$(op completion zsh)"
              compdef _op op
            fi
            if command -v terraform &>/dev/null; then
              complete -C "$(command -v terraform)" terraform
            fi

            source ${../files/zsh/functions.zsh}
            eval "$(devenv hook zsh)"
          ''

          (lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
            # macOS-only helper functions, ported from the
            # mrolli/zsh-macos-goodies zinit plugin.
            source ${../files/zsh/macos-goodies.zsh}
            compdef _music music
          '')
        ];
      };
    };
in
{
  den.aspects.zsh = {
    nixos = systemModule;
    darwin = systemModule;
    homeManager = homeModule;
  };
}

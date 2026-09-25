# Install and configure zsh
# https://nix-community.github.io/home-manager/options/home-manager/programs/zsh.html
{ ... }:
let
  systemModule = { ... }: {
    programs.zsh.enable = true;
  };

  homeModule = { pkgs, lib, ... }: {
    programs.zsh = {
      enable = true;
      autocd = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

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
            # shorcut to screen locking (= ctrl-cmd q)
            afk = "$'osascript -e \'tell application \"System Events\" to key code 12 using {control down, command down}\''";

            # Easy build nix config
            u = "darwin-switch-summary";
          }
      );

      plugins = [ ];

      initContent = ''
        source ${../files/zsh/functions.zsh}
        eval "$(devenv hook zsh)"
      '';
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

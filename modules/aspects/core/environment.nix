# Baseline home-manager environment: XDG base directories and the
# shell-agnostic session variables (editor/pager/locale/colors) that every
# other aspect can rely on already being set.
{ ... }:
{
  den.aspects.environment.homeManager =
    { pkgs, ... }:
    {
      # Export XDG_CONFIG_HOME/XDG_CACHE_HOME/XDG_DATA_HOME/XDG_STATE_HOME so
      # third-party tools that read the env vars (rather than assuming the
      # default ~/.config-style paths) see them, matching the old zshenv.
      xdg.enable = true;

      home.sessionVariables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        TERM = "xterm-256color";

        EDITOR = "nvim";
        VISUAL = "nvim";
        SVNEDITOR = "nvim";

        PAGER = "less";
        MANPAGER = "bat -plman";
        LESS = "--quit-if-one-screen --no-init --ignore-case --chop-long-lines --RAW-CONTROL-CHARS --quiet --dumb";

        CLICOLOR = "1";
        LS_COLORS = "di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:or=40;31;07";
      }
      // (
        # Skip resource forks when using system tar (macOS only).
        if pkgs.stdenv.hostPlatform.isDarwin then { COPYFILE_DISABLE = "true"; } else { }
      );
    };
}

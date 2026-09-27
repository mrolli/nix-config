# Standalone macOS Music command with a separately managed zsh completion.
{ ... }:
{
  den.aspects.music.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      xdg.localBinInPath = true;

      home.file."${config.xdg.binHome}/music" = {
        source = ../files/scripts/darwin/music;
        executable = true;
      };

      programs.zsh.siteFunctions._music = builtins.readFile ../files/zsh/completions/_music;
      programs.zsh.initContent = ''
        compdef _music music
      '';
    };
}

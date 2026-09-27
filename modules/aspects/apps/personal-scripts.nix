# Personal scripts managed and deployed by this configuration.
{ ... }:
{
  den.aspects.personal-scripts.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      darwinSwitchSummary = pkgs.writeShellApplication {
        name = "darwin-switch-summary";
        runtimeInputs = with pkgs; [
          nix
          jq
          coreutils
          gnugrep
          gnused
        ];
        text = builtins.readFile ../../../scripts/darwin-switch-summary.sh;
      };
    in
    lib.mkMerge [
      {
        home.packages = with pkgs; [
          curl
          viu
        ];
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        home.packages = [ darwinSwitchSummary ];

        home.file = {
          "${config.xdg.binHome}/music" = {
            source = ../files/scripts/darwin/music;
            executable = true;
          };
          "${config.xdg.binHome}/tytplay" = {
            source = ../files/scripts/darwin/tytplay;
            executable = true;
          };
        };

        programs.zsh.siteFunctions._music = builtins.readFile ../files/zsh/completions/_music;
        programs.zsh.initContent = ''
          compdef _music music
        '';
      })
    ];
}

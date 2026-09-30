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
        home.packages =
          with pkgs;
          [
            curl
            jq
            _1password-cli
            viu
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.util-linux
          ];

        home.file."${config.xdg.binHome}/lego_print_storage_labels" = {
          source = ../files/scripts/common/lego_print_storage_labels.sh;
          executable = true;
        };
        home.file."${config.xdg.binHome}/lego_set_infos" = {
          source = ../files/scripts/common/lego_set_infos.sh;
          executable = true;
        };
        home.file."${config.xdg.binHome}/lego_set_search" = {
          source = ../files/scripts/common/lego_set_search.sh;
          executable = true;
        };
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

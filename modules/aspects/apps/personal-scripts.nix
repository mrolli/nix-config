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
      pdfTex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-small collection-fontsrecommended;
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
            coreutils
            ffmpeg-headless
            gawk
            git
            git-filter-repo
            gh
            ncurses
            openssl
            pandoc
            pdfTex
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
        home.file."${config.xdg.binHome}/2pdf" = {
          source = ../files/scripts/common/2pdf;
          executable = true;
        };
        home.file."${config.xdg.binHome}/check_certificate_expiry" = {
          source = ../files/scripts/common/check_certificate_expiry.sh;
          executable = true;
        };
        home.file."${config.xdg.binHome}/colors-tmux" = {
          source = ../files/scripts/common/colors-tmux;
          executable = true;
        };
        home.file."${config.xdg.binHome}/termtester" = {
          source = ../files/scripts/common/termtester;
          executable = true;
        };
        home.file."${config.xdg.binHome}/init-ansible-project" = {
          source = ../files/scripts/common/init-ansible-project;
          executable = true;
        };
        home.file."${config.xdg.binHome}/renumber-files" = {
          source = ../files/scripts/common/renumber-files;
          executable = true;
        };
        home.file."${config.xdg.binHome}/media-concatenate" = {
          source = ../files/scripts/common/media-concatenate;
          executable = true;
        };
        home.file."${config.xdg.binHome}/trim-video" = {
          source = ../files/scripts/common/trim-video;
          executable = true;
        };
        home.file."${config.xdg.binHome}/video-convert-to-hevc" = {
          source = ../files/scripts/common/video-convert-to-hevc;
          executable = true;
        };
        home.file."${config.xdg.binHome}/playtube" = {
          source = ../files/scripts/common/playtube;
          executable = true;
        };
        home.file."${config.xdg.binHome}/rename-files" = {
          source = ../files/scripts/common/rename-files;
          executable = true;
        };
        home.file."${config.xdg.binHome}/git-use-unibe-identity" = {
          source = ../files/scripts/common/git-use-unibe-identity;
          executable = true;
        };
        home.file."${config.xdg.binHome}/git-rename-github-default-branch" = {
          source = ../files/scripts/common/git-rename-github-default-branch;
          executable = true;
        };
        home.file."${config.xdg.binHome}/git-forget-path" = {
          source = ../files/scripts/common/git-forget-path;
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

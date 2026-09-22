# Creates starship.toml; see
# https://nix-community.github.io/home-manager/options/home-manager/programs/starship.html
# https://gist.github.com/s-a-c/0e44dc7766922308924812d4c019b109#file-starship-nix/
{ lib, ... }:
{
  den.aspects.starship.homeManager = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        add_newline = true;
        palette = "gruvbox-dark";
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$cmd_duration"
          "$fill"
          "$all"
          "$line_break"
          "$jobs"
          "$status"
          "$container"
          "$character"
        ];
        fill.symbol = " ";
        aws = {
          symbol = " ";
          style = "yellow";
        };

        azure = {
          disabled = false;
          format = "in [$symbol$subscription]($style) ";
          style = "blue";
        };

        character = {
          success_symbol = "[](bold green)";
          error_symbol = "[✗](bold red2)";
        };

        cmd_duration = {
          format = "[󰚭 $duration]($style) ";
          show_milliseconds = false;
          min_time = 5000;
          style = "purple";
        };

        directory = {
          format = "[ $path]($style)[$read_only]($read_only_style) ";
          style = "yellow";
          truncation_length = 3;
        };

        git_branch = {
          style = "blue";
          symbol = " ";
        };

        git_metrics.disabled = true;

        git_status = {
          format = "[$ahead_behind $all_status]($style) ";
          style = "blue";
          modified = "~$count";
          deleted = "✘$count";
          up_to_date = "≡";
          untracked = "?$count";
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇡$ahead_count⇣$behind_count";
          stashed = "\\\\$\${count}";
          staged = "++$count";
          conflicted = "[](red)$count ";
        };

        golang.symbol = " ";

        hostname = {
          disabled = false;
          format = "on [$hostname]($style) ";
          ssh_symbol = " ";
          ssh_only = false;
          style = "green";
        };

        jobs = {
          symbol = " ";
          style = "red";
          number_threshold = 1;
          format = "[$symbol]($style)";
        };

        lua.symbol = " ";

        nodejs = {
          symbol = " ";
          detect_extensions = [
            "mjs"
            "cjs"
            "ts"
            "mts"
            "cts"
          ];
        };

        package.symbol = "󰏗 ";
        php.symbol = "🐘";

        python = {
          symbol = " ";
          pyenv_version_name = false;
          pyenv_prefix = "";
          style = "yellow";
        };

        rust.symbol = " ";
        ruby.symbol = " ";
        terraform.format = "via [$symbol$version \\($workspace\\)]($style) ";

        username = {
          format = "[$user]($style) ";
          show_always = true;
          style_user = "orange";
        };

        palettes.gruvbox-dark = {
          red = "#cc241d";
          red2 = "#fb4934";
          green = "#98971a";
          green2 = "#b8bb26";
          yellow = "#d79921";
          yellow2 = "#fabd2f";
          blue = "#458588";
          blue2 = "#83a598";
          purple = "#b16286";
          purple2 = "#d3869b";
          aqua = "#689d6a";
          aqua2 = "#8ec07c";
          orange = "#d65d0e";
          orange2 = "#fe8019";
          gray = "#928374";
          gray2 = "#a89984";
          bg = "#282828";
          bg0_h = "#1d2021";
          bg0 = "#282828";
          bg1 = "#3c3836";
          bg2 = "#504945";
          bg3 = "#665c54";
          bg4 = "#7c6f64";
          fg4 = "#a89984";
          fg3 = "#bdae93";
          fg2 = "#d5c4a1";
          fg1 = "#ebdbb2";
          fg0 = "#fbf1c7";
          fg = "#ebdbb2";
        };
      };
    };
  };
}

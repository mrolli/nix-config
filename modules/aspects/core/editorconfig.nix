# Creates starship.toml; see
# https://nix-community.github.io/home-manager/options/home-manager/programs/starship.html
# https://gist.github.com/s-a-c/0e44dc7766922308924812d4c019b109#file-starship-nix/
{ lib, ... }:
{
  den.aspects.editorconfig.homeManager = {
    editorconfig = {
      enable = true;
      settings = {
        # Set conservative standards
        # - UTF-8 charset
        # - Unix-style newlines with a newline ending every file
        # - 4 space indent
        # - Trim trailing whitespace
        "*" = {
          indent_style = "space";
          indent_size = 2;
          end_of_line = "lf";
          charset = "utf-8";
          trim_trailing_whitespace = true;
          insert_final_newline = true;
        };

        # Markdown
        # - 4 space indent
        # - Trailing whitespace is potentially meaningful, leave it
        "*.md" = {
          indent_size = 4;
          trim_trailing_whitespace = false;
        };

        # Python
        # - 4 space indent
        "*.py" = {
          indent_style = "space";
          indent_size = 4;
        };

        # PHP
        # - 4 space indent
        "*.php" = {
          indent_style = "space";
          indent_size = 4;
        };

        # Makefiles are tab based
        "Makefile" = {
          indent_style = "tab";
        };
      };
    };
  };
}

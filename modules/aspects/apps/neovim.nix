{ inputs, ... }:
{
  den.aspects.neovim.homeManager =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      # lazyvim-nix v16.0.1 installs nvim-treesitter 5cb0114 queries, whose diff
      # highlights need the `change` node, but builds tree-sitter-diff 2520c3f
      # from an older parser manifest. Shadow it with the matching revision via
      # ~/.config/nvim, which precedes site/ on the runtimepath. Remove once
      # lazyvim-nix ships a coherent manifest.
      xdg.configFile."nvim/parser/diff.so".source = "${
        pkgs.tree-sitter.buildGrammar {
          language = "diff";
          version = "0.0.0+rev=ada384a";
          src = pkgs.fetchFromGitHub {
            owner = "tree-sitter-grammars";
            repo = "tree-sitter-diff";
            rev = "ada384ac7bfc1307f32de474620120add29998fb";
            hash = "sha256-5HCBFE/99DJ9AYWSk18WRF3RGQpgpYAYA37bT54F0DI=";
          };
        }
      }/parser";

      programs.lazyvim = {
        enable = true;

        # Import file based config
        configFiles = ./lazyvim;

        # Core LazyVim dependencies (git, ripgrep, fd, lazygit, fzf, curl)
        installCoreDependencies = true;

        extraPackages = with pkgs; [
          # Tools
          markdownlint-cli2
          marksman
          markdown-toc
          yamllint
        ];

        extras = {
          ai.sidekick.enable = true;
          coding.mini-surround.enable = true;
          lang = {
            git.enable = true;
            markdown = {
              enable = true;
              installDependencies = false;
            };
            terraform.enable = true;
            yaml.enable = true;
          };

          util.dot.enable = true;
        };

        treesitterParsers = with pkgs.vimPlugins.nvim-treesitter-parsers; [
          nix
        ];
      };
    };
}

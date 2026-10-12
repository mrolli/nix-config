{ inputs, ... }:
{
  den.aspects.neovim.homeManager =
    {
      pkgs,
      ...
    }:
    {
      imports = [ inputs.lazyvim.homeManagerModules.default ];

      programs.lazyvim = {
        enable = true;

        # Import file based config
        configFiles = ./lazyvim;

        # Core LazyVim dependencies (git, ripgrep, fd, lazygit, fzf, curl)
        installCoreDependencies = true;

        extraPackages = with pkgs; [
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
      };
    };
}

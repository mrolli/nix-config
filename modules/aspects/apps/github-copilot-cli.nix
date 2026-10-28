# Install and configure GitHub Copilot CLI using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/github-copilot-cli.html
# https://github.com/sharkdp/bat
{
  inputs,
  ...
}:
{
  den.aspects.github-copilot-cli.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Every subdirectory of files/copilot/skills is a local skill.
      localSkills = lib.mapAttrs (name: _: "copilot/skills/${name}") (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir (./copilot/skills))
      );

      externalSkills = {
        nixos-managing = "${inputs.skill-nixos-management}/nixos-managing";
        nixos-best-practices = "${inputs.skill-nixos-best-practices}/skills/nixos-best-practices";
        nixomatic = "${inputs.skill-nixomatic}/nixomatic";
      };

      thisCfg = config.programs.github-copilot-cli;
    in
    {
      # Dependencies used cor mcp serves
      home.packages = with pkgs; [
        nodejs_26
        terraform-mcp-server
      ];

      programs.github-copilot-cli = {
        enable = true;
        # copilot moves quickly; take it from nixpkgs-unstable
        package = (inputs.self.lib.unstablePkgs pkgs.stdenv.hostPlatform.system).github-copilot-cli;
        # Explicitly set config dir to XDG configuration, do not rely on preferXdgDirectories
        configDir = "${config.xdg.configHome}/copilot";

        # https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference
        settings = {
          allowedUrls = [
            "https://id-unibe-ch.cachix.org"
            "https://learn.microsoft.com"
            "https://code.visualstudio.com"
            "https://registry.terraform.io"
            "https://docs.github.com"
            "https://portal.azure.com"
          ];
          enabledPlugins = {
            "azure@azure-skills" = true;
            "swift-mcp-development@awesome-copilot" = true;
          };
          extraKnownMarketplaces = {
            azure-skills = {
              source = {
                repo = "microsoft/azure-skills";
                source = "github";
              };
            };
          };
          ide = {
            autoConnect = false;
          };
          model = "auto";
          renderMarkdown = true;
          respectGitignore = true;
          screenReader = false;
          theme = "github";
        };

        context = ./copilot/instructions.md;
        agents = ./copilot/agents;
        skills = externalSkills // localSkills;

        mcpServers = {
          atlassian-mcp-server = {
            command = "npx";
            args = [
              "-y"
              "mcp-remote@latest"
              "https://mcp.atlassian.com/v1/mcp"
            ];
            tools = [ "*" ];
          };
          azure-mcp = {
            type = "stdio";
            command = "npx";
            args = [
              "-y"
              "@azure/mcp@latest"
              "server"
              "start"
            ];
            tools = [ "*" ];
          };
          terraform-mcp-server = {
            type = "local";
            command = lib.getExe pkgs.terraform-mcp-server;
            tools = [ "*" ];
          };
        };
      };

      # Home Manager 26.05 writes these settings to config.json; newer Copilot
      # CLI releases read settings.json instead.
      # TODO: Remove after switching HomeManager to 26.11
      home.file."${thisCfg.configDir}/config.json".enable = lib.mkForce false;
      home.file."${thisCfg.configDir}/settings.json" =
        lib.mkIf (thisCfg.enable && thisCfg.settings != { })
          {
            source = (pkgs.formats.json { }).generate "github-copilot-cli-settings.json" (thisCfg.settings);
          };
    };
}

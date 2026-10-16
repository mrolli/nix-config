# Install and configure GitHub Copilot CLI using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/github-copilot-cli.html
# https://github.com/sharkdp/bat
{
  inputs,
  ...
}:
{
  den.aspects.git.homeManager =
    {
      pkgs,
      ...
    }:
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

        # https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference
        settings = {
          allowedUrls = [
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
          theme = "default";
        };

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
            command = "terraform-mcp-server";
            tools = [ "*" ];
          };
        };
      };
    };
}

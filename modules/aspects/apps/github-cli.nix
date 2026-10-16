# Install and configure git using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/git.html
# https://github.com/sharkdp/bat
{ ... }:
{
  den.aspects.git.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.gh = {
        enable = true;
        settings = {
          # What protocol to use when performing git operations. Supported values: ssh, https
          git_protocol = "https";
          # When to interactively prompt. This is a global config that cannot be overridden by hostname. Supported values = "enabled, disabled";
          prompt = "enabled";
          # A pager program to send command output to, e.g. "less". Set the value to "cat" to disable the pager.
          pager = "bat";
          # Aliases allow you to create nicknames for gh commands
          aliases = {
            iv = "issue view";
            ie = "issue edit";
            id = "issue develop -c";
            co = "pr checkout";
            pv = "pr view";
            unistatus = "status -e betriebsam/betriebsam-tech";
          };
          version = "1";
        };
      };
    };
}

# Install and configure claude-code using Home Manager
# https://nix-community.github.io/home-manager/options/home-manager/programs/claud-code.html
# https://github.com/anthropics/claude-code
{
  inputs,
  ...
}:
{
  den.aspects.claude-code.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # Every subdirectory of ./copilot/agents is a local agent.
      localAgents = lib.mapAttrs (name: _: "copilot/agents/${name}") (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir (./copilot/agents))
      );

      # Every subdirectory of ./copilot/skills is a local skill.
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
      programs.claude-code = {
        enable = true;
        # claude-code moves quickly; take it from nixpkgs-unstable
        package = (inputs.self.lib.unstablePkgs pkgs.stdenv.hostPlatform.system).claude-code;
        configDir = "${config.xdg.configHome}/claude";

        context = ./copilot/instructions.md;
        agents = localAgents;
        skills = externalSkills // localSkills;
      };
    };
}

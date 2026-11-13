# @doc id=claude-code target=docs/apps/claude-code.md
# Configure Claude Code with shared repository instructions, agents, and skills.
#
# The package comes from nixpkgs-unstable. Home Manager places its configuration
# under XDG config. Instructions, agents, and locally discovered skills reuse
# the tracked files under `modules/aspects/apps/copilot/`; external skills are
# pinned flake inputs, so both coding assistants share the same guidance.
#
# Authentication and user-specific Claude settings remain managed by Claude
# Code itself, not by this Nix aspect.
#
# See the [Home Manager Claude Code options] and [Claude Code documentation]
# for configuration details.
#
# [Home Manager Claude Code options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.enable>
# [Claude Code documentation]: <https://docs.anthropic.com/en/docs/claude-code/overview>
# @enddoc
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
      # Every subdirectory of ./copilot/skills is a local skill.
      localSkills = lib.mapAttrs (name: _: ./copilot/skills + "/${name}") (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir (./copilot/skills))
      );

      externalSkills = {
        nixos-managing = "${inputs.skill-nixos-management}/nixos-managing";
        nixos-best-practices = "${inputs.skill-nixos-best-practices}/skills/nixos-best-practices";
        nixomatic = "${inputs.skill-nixomatic}/nixomatic";
      };
    in
    {
      programs.claude-code = {
        enable = true;
        # claude-code moves quickly; take it from nixpkgs-unstable
        package = (inputs.self.lib.unstablePkgs pkgs.stdenv.hostPlatform.system).claude-code;
        configDir = "${config.xdg.configHome}/claude";

        settings = {
          theme = "dark-ansi";
          timeFormat = "24-hour";
          pluginConfigs = {
            "cc-plugin-agents-md@builtin" = {
              "options" = {
                "instructionFiles" = "claude-md-or-agents-md";
              };
            };
          };
        };
        context = ./copilot/instructions.md;
        agentsDir = ./copilot/agents;
        skills = externalSkills // localSkills;
      };
    };
}

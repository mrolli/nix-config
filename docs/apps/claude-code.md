# Claude Code

<!-- BEGIN GENERATED: claude-code -->
<!-- Generated from modules/aspects/apps/claude-code.nix; edit the marked Nix block instead. -->
Configure Claude Code with shared repository instructions, agents, and skills.

The package comes from nixpkgs-unstable. Home Manager places its configuration
under XDG config. Instructions, agents, and locally discovered skills reuse
the tracked files under `modules/aspects/apps/copilot/`; external skills are
pinned flake inputs, so both coding assistants share the same guidance.

Authentication and user-specific Claude settings remain managed by Claude
Code itself, not by this Nix aspect.

See the [Home Manager Claude Code options] and [Claude Code documentation]
for configuration details.

[Home Manager Claude Code options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.enable>
[Claude Code documentation]: <https://docs.anthropic.com/en/docs/claude-code/overview>
<!-- END GENERATED: claude-code -->

<!-- GENERATED SOURCE: claude-code -->
[Source: `modules/aspects/apps/claude-code.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/claude-code.nix)
<!-- END GENERATED SOURCE: claude-code -->

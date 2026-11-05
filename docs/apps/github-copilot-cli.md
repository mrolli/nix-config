# github-copilot-cli

<!-- BEGIN GENERATED: github-copilot-cli -->
<!-- Generated from modules/aspects/apps/github-copilot-cli.nix; edit the marked Nix block instead. -->
Configure GitHub Copilot CLI, its MCP servers, skills, agents, and shared
instructions.

The package comes from nixpkgs-unstable. Settings are written to the XDG
`settings.json`; the pinned Home Manager module currently targets
`config.json`, while newer CLI releases read `settings.json`. Remove this
compatibility override after the Home Manager module catches up.

Local skills are discovered from `copilot/skills/`; external skills are
pinned flake inputs. Agents and context are tracked under
`modules/aspects/apps/copilot/`. MCP server definitions include `npx`-based
services and the packaged Terraform server; authentication is performed by
the individual services.

See the [Home Manager Copilot CLI options] and upstream [Copilot CLI
configuration] reference for supported settings.

[Home Manager Copilot CLI options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.github-copilot-cli.enable>
[Copilot CLI configuration]: <https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference>
<!-- END GENERATED: github-copilot-cli -->

<!-- GENERATED SOURCE: github-copilot-cli -->
[Source: `modules/aspects/apps/github-copilot-cli.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/github-copilot-cli.nix)
<!-- END GENERATED SOURCE: github-copilot-cli -->

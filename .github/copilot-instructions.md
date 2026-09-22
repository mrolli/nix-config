# Copilot instructions

## Repository shape

This is a flake-based Nix configuration using `flake-parts` and `import-tree`.
`flake.nix` is intentionally small: it enables the `flake.modules` interface
and imports every `.nix` file below `modules/` automatically. Do not add
manual imports for individual files under `modules/`.

The intended organization is:

- `modules/features/` publishes reusable platform or home-manager feature
  modules.
- `modules/hosts/` publishes host-specific modules that compose features.
- `modules/users/` contains per-user modules when user configuration is
  needed.
- `modules/flake/` is the configuration-assembly layer that turns named
  module groups into concrete flake outputs.

The current checkout contains Darwin feature modules (`darwin-base`,
`homebrew`) and the `id-mrolli-mbp` host module. The README documents the
broader multi-platform design and historical examples; verify that a
configuration or module exists in the current tree before referencing it.
In particular, do not assume a `darwinConfigurations` output exists unless a
configuration-assembly module has been added.

## Module conventions

- Publish groups as `flake.modules.<class>.<name>`, where the class is
  normally `nixos`, `darwin`, or `homeManager`.
- A feature file should publish only the classes it supports. Importing a
  feature is normally what enables it; do not add an extra `enable` option
  unless the feature genuinely needs independent runtime toggling.
- Keep one owning file for each named `flake.modules.<class>.<name>` leaf.
  Compose groups through normal module `imports` using
  `inputs.self.modules.<class>.<name>`.
- Use one shared module with `pkgs.stdenv.hostPlatform` conditionals when
  option paths are shared and only values differ. Use separate named
  platform groups for small platform-specific literals, and publish only one
  platform group for platform-exclusive features.
- Keep host-specific hardware configuration in the host module; keep
  platform-wide defaults in a feature module.
- Darwin host settings in the current host module use the `id-mrolli` hostname
  and uppercase NetBIOS name. Preserve the distinction between the host
  identifier (`id-mrolli-mbp`) and the machine hostname (`id-mrolli`).

## Development environment

`devenv.nix` enables the Nix language and configures git hooks for:

- `nixfmt` for Nix formatting
- `shellcheck` for shell scripts

Enter the development environment with:

```bash
devenv shell
```

## Validation commands

Run commands from the repository root:

```bash
nix flake check
```

Evaluates the flake and its checks. This is the primary repository-wide
validation command.

```bash
shellcheck scripts/darwin-switch-summary.sh
```

Runs the available single-file lint check for the Darwin helper script.

```bash
nix flake show
```

Inspects the outputs currently exposed by the flake. Use this before writing
commands for a specific host or system output; the current tree may expose
module groups without exposing a concrete system configuration.

There is no unit-test framework or individual test target in this repository.
For a Nix change, use `nix flake check` and inspect the relevant output with
`nix flake show`; for a shell change, run `shellcheck` on the changed script.

## Darwin switch helper

`scripts/darwin-switch-summary.sh` builds a Darwin system, compares its closure
with the currently running system, prints package version changes, and asks
before switching. It requires `nix`, `jq`, `darwin-rebuild`, and `sudo`.

For the initial activation, when `darwin-rebuild` is not yet installed, use:

```bash
sudo nix run nix-darwin -- switch --flake .#id-mrolli-mbp-M4-24
```

The Determinate Nix installer enables the required `nix-command` and `flakes`
experimental features and manages the Nix daemon. Keep `nix.enable = false` in
the Darwin base module; configure Nix daemon settings through Determinate Nix,
not nix-darwin. The configuration imports `determinate.darwinModules.default`;
`darwin-base` uses `determinateNix.customSettings` for declarative additions
to `/etc/nix/nix.custom.conf` and currently enables `auto-optimise-store`.
Determinate Nixd owns automatic garbage collection. After bootstrap succeeds,
`darwin-rebuild` is available for the helper and routine switches.

```bash
scripts/darwin-switch-summary.sh --host <darwin-configuration-name>
```

The flake directory defaults to `$HOME/.config/nix-config`; set
`NIX_SYSTEM_FLAKE_DIR` when working from another checkout:

```bash
NIX_SYSTEM_FLAKE_DIR="$PWD" scripts/darwin-switch-summary.sh --host <name>
```

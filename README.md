# nix-config

This repository is a Den-based Nix flake for multi-platform host and user
configuration. It currently exposes Darwin hosts and Home Manager users through
Den's aspect-oriented model.

## Repository model

`flake.nix` stays intentionally small. It imports:

- `inputs.den.flakeModule`, which defines the `den.*` options and generates
  flake outputs.
- `inputs.import-tree ./modules`, which auto-imports every `.nix` file below
  `modules/`.

There are no hand-maintained import lists for files under `modules/`.

Den is the assembly layer:

1. `den.hosts` declares machines and the users on them.
2. `den.aspects.*` declares reusable, host, or user configuration.
3. `den.default` declares defaults and batteries shared across entities.
4. Den generates outputs such as `darwinConfigurations.<host>`.

## Current layout

- `modules/flake/` — Den-level wiring:
  - `den-hosts.nix` declares the host roster.
  - `den-defaults.nix` applies shared batteries and Home Manager defaults.
- `modules/aspects/core/` — reusable platform/core aspects such as `base`,
  `darwin-base`, and `homebrew`.
- `modules/aspects/apps/` — reusable application or user-program aspects, such
  as `starship`.
- `modules/hosts/` — host-owned aspects named after the host output.
- `modules/users/` — user-owned aspects named after the user.

The active Darwin host outputs are:

- `darwinConfigurations.id-mrolli-mbp-M4-24`
- `darwinConfigurations.galadriel`

The `id-mrolli-mbp-M4-24` output intentionally differs from the machine
hostname: the host/output key is `id-mrolli-mbp-M4-24`, while the Darwin
hostname is `id-mrolli` and the NetBIOS name is `ID-MROLLI`.

## Adding configuration

Reusable concerns should be added as aspects under `modules/aspects/`.

Example:

```nix
{ ... }:
{
  den.aspects.my-tool.homeManager = {
    programs.my-tool.enable = true;
  };
}
```

Then include that aspect from a host or user aspect:

```nix
{ den, ... }:
{
  den.aspects.mrolli.includes = [
    den.aspects.my-tool
  ];
}
```

Host-specific settings belong in `modules/hosts/<host>.nix`:

```nix
{ den, ... }:
{
  den.aspects.my-host = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
    ];

    darwin.networking.computerName = "my-host";
  };
}
```

User-specific settings belong in `modules/users/<user>.nix`. The shared
defaults already include `den.batteries.define-user`, so user aspects usually
only need user preferences and extra batteries:

```nix
{ den, ... }:
{
  den.aspects.mrolli.includes = [
    den.batteries.primary-user
    (den.batteries.user-shell "zsh")
  ];
}
```

Determinate Nix owns the Nix daemon and daemon settings. Keep `nix.enable =
false` in the Darwin base aspect and configure additions through
`determinateNix.customSettings`.

## Development

Enter the development environment with:

```bash
devenv shell
```

The development environment enables the Nix language and configures git hooks
for:

- `nixfmt`
- `shellcheck`

## Validation

Run from the repository root:

```bash
nix flake show
```

Lists generated outputs and confirms the Den host roster is visible.

```bash
nix flake check
```

Primary repository validation. It evaluates the Den-generated flake outputs.

```bash
shellcheck scripts/darwin-switch-summary.sh
```

Lints the Darwin switch helper.

## Switching Darwin hosts

For the initial activation, when `darwin-rebuild` is not yet installed, use:

```bash
sudo nix run nix-darwin -- switch --flake .#id-mrolli-mbp-M4-24
```

After bootstrap, use the helper:

```bash
scripts/darwin-switch-summary.sh --host id-mrolli-mbp-M4-24
```

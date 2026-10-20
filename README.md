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
3. `den.default` declares defaults and batteries shared across entities
4. Den generates outputs such as `darwinConfigurations.<host>`.

## Current layout

- `modules/flake/` — Den-level wiring:
  - `den-hosts.nix` declares the host roster.
  - `den-defaults.nix` applies shared batteries and Home Manager defaults.
- `modules/aspects/core/` — reusable platform/core aspects such as `base`,
  `darwin-base`, and `homebrew`.
- `modules/aspects/apps/` — application aspects that users or hosts opt into.
  These can enable a Home Manager program and supply settings intentionally
  shared by everyone who includes the aspect.
- `modules/hosts/<host>.nix` — host aspects named after their Den output,
  composing machine-level policy and features.
- `modules/users/<user>.nix` — user aspects that compose reusable aspects and
  user-specific batteries and settings.
- `modules/aspects/files/` — sources deployed by aspects, such as scripts and
  shell configuration files; these are not Den aspects themselves.

As user configuration grows, keep `modules/users/<user>.nix` as a short
composition file and split personal settings by concern into
`modules/users/<user>/<concern>.nix`. All files under `modules/` are imported
automatically, so these concern files can contribute to the **same**
`den.aspects.<user>` without manual imports or a separately named aspect for
each file. For concerns whose settings should be shared across users, a
reusable app aspect can enable a Home Manager program while a user concern
file supplies individual values. Git currently takes a different approach:
`modules/aspects/apps/git.nix` owns the entire Git configuration, including
`mrolli`'s identity, aliases, signing behavior, credential helpers, delta
settings, and the ignore file and commit template under
`modules/aspects/apps/git/`. The user aspect opts into it:

```nix
# modules/users/mrolli.nix (excerpt)
den.aspects.mrolli.includes = [ den.aspects.git ];
```

Do not include this Git aspect for another account as-is: it would inherit
`mrolli`'s identity and preferences. If Git settings need to differ per user
later, split the personal values back into user concern files. The same
boundary could apply to Starship; the current `starship.nix` still contains
one user's settings.

Home Manager settings that apply only on macOS can likewise live under
`modules/users/<user>/macos-defaults.nix`, gated to Darwin. For example,
`modules/users/mrolli/macos-defaults.nix` writes individual preference keys
through Home Manager activation, preserving unrelated settings in those
domains, and creates `~/Documents/Screenshots` for the configured screenshot
location. It also remaps Caps Lock to Escape for this user via Home Manager's
macOS key-remapping service, which reapplies the mapping at login. Keep genuinely
shared macOS preferences in an opt-in reusable aspect instead. Avoid managing
the same preference key in both a user's Home Manager configuration and
nix-darwin's `system.defaults`, or the same keyboard mapping in both Home
Manager and nix-darwin's `system.keyboard`.

The active Darwin host outputs are:

- `darwinConfigurations.riendell`
- `darwinConfigurations.galadriel`

## Adding configuration

Reusable concerns that are for all users should be added as aspects under `modules/aspects/`.

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

Make sure the new aspect and config files are tracked by Git before using
`--flake .`; Git-based flakes omit untracked files.

Enter the development environment with:

```bash
devenv shell
```

The development environment enables the Nix language and configures git hooks
for:

- `nixfmt`
- `shellcheck`

The DAG of this flake can be debugged by printing the resulting configuration using:

```bash
Start the interacting shell
nix repl
# Load the flake
nix-repl> :lf .
# Print the whole configuration graph of a host
nix-repl> :p darwinConfigurations.<host>.config
# Quit
nix-repl> :q
```

To debug a specific value and find out, what it is computed to, i.e.

```bash
# Print the hostname of a host
nix eval .#darwinConfigurations.<host>.config.networking.hostName
# Print the settings of Ghostty of a host
nix eval --json .#darwinConfigurations.<host>.config.home-manager.users.mrolli.programs.ghostty.settings | jq
```

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

## Switching Darwin hosts/Apply latest config

For the initial activation, when `darwin-rebuild` is not yet installed, use:

```bash
sudo nix run nix-darwin -- switch --flake .#HOSTNAME
```

After bootstrap, use the helper:

```bash
scripts/darwin-switch-summary.sh [--host HOSTNAME]
```

## Updating flake inputs

To update all inputs to the latest revisions allowed by their flake references:

```bash
nix flake update
```

Review `flake.lock`, then validate and rebuild before switching. Updating the
lockfile changes the selected package and module revisions; it does not by
itself activate them:

```bash
git diff -- flake.lock
nix flake show
nix flake check
darwin-rebuild build --flake .#id-mrolli
darwin-rebuild build --flake .#galadriel
```

Use `scripts/darwin-switch-summary.sh [--host HOSTNAME]` after reviewing the
build and deciding to activate it.

## Reverting to last known-good configuration

Recover the machine now: nix-darwin keeps system generations independently of Git. On the Mac you switched, list them and activate the last one you know worked:

```bash
sudo darwin-rebuild --list-generations
sudo darwin-rebuild --rollback
```

`--rollback` selects the previous generation; if that one was also bad, use `sudo darwin-rebuild --switch-generation <number>`. These commands select the stored system and run its activation, without evaluating the current checkout. Because Home Manager is integrated into the Darwin configuration, its managed configuration is activated with that system generation.

## Upgrading to a new stable release

A stable release upgrade changes the release branch references in `flake.nix`
and updates the corresponding lockfile inputs. It does **not** mean changing
`system.stateVersion` or `home.stateVersion`; these are compatibility
baselines and normally remain unchanged.

The commands below use **26.11** as an example. Run them only after the
Nixpkgs, nix-darwin, and Home Manager 26.11 branches are published. For
Darwin use `nixpkgs-26.11-darwin`; for NixOS use `nixos-26.11`. These are
platform-oriented stable branches for binary-cache builds and track the same
`release-26.11` series.

Before changing refs, check for local work and confirm all Macs are Apple
Silicon. Nixpkgs 26.05 is the final release supporting Intel (`x86_64-darwin`);
26.11 drops that platform:

```bash
git status --short
git diff
nix eval --raw .#darwinConfigurations.id-mrolli.pkgs.stdenv.hostPlatform.system
nix eval --raw .#darwinConfigurations.galadriel.pkgs.stdenv.hostPlatform.system
```

Both Darwin evaluations must report `aarch64-darwin` to use 26.11. If any
host reports `x86_64-darwin`, keep it on 26.05 and plan its hardware or
platform transition separately.

Edit `flake.nix` to update the three related inputs while preserving the
`follows` relationships:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.11-darwin";

darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.11";
darwin.inputs.nixpkgs.follows = "nixpkgs";

home-manager.url = "github:nix-community/home-manager/release-26.11";
home-manager.inputs.nixpkgs.follows = "nixpkgs";
```

Keep unrelated inputs, including the independent `nixpkgs-unstable`, on
their current refs unless there is a separate reason to update them. Then
update only the changed inputs and inspect the lockfile diff:

```bash
nix flake update nixpkgs darwin home-manager
git diff -- flake.nix flake.lock
```

Confirm that nix-darwin and Home Manager still follow the top-level Nixpkgs
input and that unrelated lockfile nodes did not change. Review the release
notes, then evaluate and build before activation:

```bash
nix flake show
nix flake check
darwin-rebuild build --flake .#<darwin-host>
```

Resolve evaluation, build, deprecation, and package issues before switching.
Activate one Mac at a time, verify it, then proceed to the next:

```bash
scripts/darwin-switch-summary.sh --host <darwin-host>
```

If the flake later includes NixOS hosts, decide how Den selects platform
package sets before changing the shared input to a Linux-specific ref. Build
the target host before activating it:

```bash
nixos-rebuild build --flake .#<nixos-host>
sudo nixos-rebuild switch --flake .#<nixos-host>
```

Keep each host's `system.stateVersion` and each user's `home.stateVersion`
unchanged during release upgrades. Read the release notes before updating
inputs and handle any explicitly documented migrations separately.

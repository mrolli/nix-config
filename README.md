# nix-config

See [`docs/onboarding-new-machine.md`](docs/onboarding-new-machine.md) for a
step-by-step guide to onboarding a new Linux machine, including Proton Pass
CLI (`pass-cli`) authentication.

## Overview

This repository is a multi-platform Nix flake for NixOS, nix-darwin, and home-manager, organized with the [dendritic pattern](https://github.com/mightyiam/dendritic). See also the [NixOS Discourse write-up](https://discourse.nixos.org/t/the-dendritic-pattern/61271), [`import-tree`](https://github.com/vic/import-tree), and [`vix`](https://github.com/vic/vix) for a public example. The point of the pattern here is to keep one feature's system-level and home-manager configuration together in a single file instead of splitting the same idea across parallel directory trees.

## Repository layout

`flake.nix` is the only real entry point. It wires together:

- `flake-parts`
- `inputs.flake-parts.flakeModules.modules` (which provides the `flake.modules.<class>.<name>` option)
- `import-tree ./modules`

The important consequence is that every `.nix` file anywhere under `modules/` is automatically discovered and imported as a flake-parts module. There are no hand-maintained `imports = [ ... ]` lists for files under `modules/`, and the old `default.nix` / `readDir` auto-import pattern used before this migration is gone.

This repo currently uses four subdirectories under `modules/`:

- `modules/features/` — one file per feature, such as `git.nix`, `zsh.nix`, `proton.nix`, `fingerprint.nix`, `homebrew.nix`, or `linux-base.nix`.
- `modules/hosts/` — one file per physical host, assembling the relevant feature and user modules into that host's final `nixos` or `darwin` module group.
- `modules/users/` — one file per user, defining system-level user account settings plus the home-manager identity for each platform.
- `modules/flake/` — flake-level wiring. Right now that is `configurations.nix`, which turns the named module groups into the real `nixosConfigurations` and `darwinConfigurations` outputs.

The directory names above are just this repository's convention. `import-tree` does not care: any `.nix` file anywhere below `modules/` will be imported.

`flake.nix` itself is intentionally small:

```nix
{
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}
```

## How modules are grouped and merged

The core interface is `flake.modules.<class>.<name>`, provided by `inputs.flake-parts.flakeModules.modules`. Its type is `lazyAttrsOf (lazyAttrsOf deferredModule)`.

In this repository:

- `<class>` is one of `nixos`, `darwin`, or `homeManager`.
- `<name>` is the published name of a feature, host, or user grouping.

In theory, many files can contribute under `flake.modules`, but in practice this repo gives each `flake.modules.<class>.<name>` leaf exactly one owning file. Other files do not redefine that leaf; they reference it by name with `inputs.self.modules.<class>.<name>` inside a normal module `imports` list. That is what lets ordinary NixOS, nix-darwin, and home-manager module merging do the real composition work.

Minimal example: publishing a home-manager-only feature (adapted from `modules/features/git.nix`):

```nix
{ ... }:
{
  flake.modules.homeManager.git = { pkgs, ... }: {
    programs.git = {
      enable = true;
      package = pkgs.git;
    };
  };
}
```

Minimal example: a host module importing several named groups (adapted from `modules/hosts/ideapad.nix`):

```nix
{ inputs, ... }:
{
  flake.modules.nixos.ideapad = { ... }: {
    imports = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.linux-base
      inputs.self.modules.nixos.proton
      inputs.self.modules.nixos.mrolli
    ];
  };
}
```

Those named groups only become real flake outputs in `modules/flake/configurations.nix`. That file is where:

- `inputs.nixpkgs.lib.nixosSystem` builds `flake.nixosConfigurations.ideapad`
- `inputs.nix-darwin.lib.darwinSystem` builds `flake.darwinConfigurations."id-kstuder-MBP-M5-24"`
- each host's `home-manager.users.mrolli.imports` list is assembled from `inputs.self.modules.homeManager.<name>` entries

The pattern is:

```nix
{ inputs, ... }:
{
  flake.nixosConfigurations.ideapad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.self.modules.nixos.ideapad
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.users.mrolli.imports = [
          inputs.self.modules.homeManager.git
          inputs.self.modules.homeManager.zsh
          inputs.self.modules.homeManager.mrolli-linux
        ];
      }
    ];
  };
}
```

So the overall flow is:

1. publish named module groups from files under `modules/`
2. reference those named groups from host modules and home-manager import lists
3. turn the assembled host graph into concrete `nixosConfigurations` / `darwinConfigurations` in `modules/flake/configurations.nix`

## Handling OS / architecture / host differences

This repo uses three main styles for platform differences.

### Option A: one shared file with a conditional inside

Use this when the option surface is basically the same on each platform and only a few values differ.

`modules/features/zsh.nix` is the clearest example:

- the same file publishes `flake.modules.nixos.zsh` and `flake.modules.darwin.zsh`
- it also publishes `flake.modules.homeManager.zsh`
- the home-manager module branches on `pkgs.stdenv.hostPlatform.isLinux` to add Linux-only aliases (`pbcopy`, `pbpaste`, `vpn`) and a Darwin-only alias (`u`)

`modules/features/proton.nix` shows the same style again:

- one shared file publishes `flake.modules.nixos.proton`, `flake.modules.darwin.proton`, and `flake.modules.homeManager.proton`
- the home-manager part uses `lib.mkIf pkgs.stdenv.hostPlatform.isLinux` to add a Linux-only keyring environment variable and Linux-only systemd user service environment

Prefer this style when the option paths are identical and only the values change.

### Option B: separate named module groups per platform

Use this when the differences are just platform-specific literals, or when forcing everything into one conditional would add more noise than clarity.

`modules/users/mrolli.nix` is the example in this repo:

- `flake.modules.nixos.mrolli` sets `/home/mrolli`
- `flake.modules.darwin.mrolli` sets `/Users/mrolli`
- `flake.modules.homeManager.mrolli-linux` and `flake.modules.homeManager.mrolli-darwin` publish separate home-manager identity groups

That keeps the published names simple and avoids wrapping tiny literal differences in conditionals. The host wiring in `modules/flake/configurations.nix` then just picks the right home-manager group per platform:

```nix
home-manager.users.mrolli.imports = [
  inputs.self.modules.homeManager.git
  inputs.self.modules.homeManager.mrolli-linux
];
```

or:

```nix
home-manager.users.mrolli.imports = [
  inputs.self.modules.homeManager.git
  inputs.self.modules.homeManager.mrolli-darwin
];
```

Prefer this style when the values are platform-specific literals with little shared structure.

### Option C: platform-only feature, no counterpart

Use this when the feature simply does not exist on the other platform.

Examples already in this repo:

- `modules/features/homebrew.nix` is `darwin`-only
- `modules/features/fcitx.nix` is a Linux-only home-manager feature
- `modules/features/linux-base.nix` is a NixOS-only system feature
- `modules/features/spotify.nix` is effectively Linux-only because only the Linux host imports it

No conditional is needed in these cases. Publish only the module group that exists, then do not reference it from the other platform's host/configuration.

### Decision rule

Use these rules consistently:

- prefer **Option A** when the option paths are the same and only values differ
- prefer **Option B** when the values are platform-specific literals with no useful shared structure
- use **Option C** when the feature does not apply to the other platform at all

### Host-specific vs architecture-specific

A host-only feature and a platform-wide feature are different concerns.

- `modules/features/fingerprint.nix` is host-specific: only `modules/hosts/ideapad.nix` imports it, because only that physical machine has that Goodix fingerprint reader.
- `modules/features/linux-base.nix` is platform-wide: any Linux host could import it.

Architecture selection happens in the configuration assembly layer:

- `modules/flake/configurations.nix` sets `system = "x86_64-linux"` for the NixOS configuration
- `modules/features/darwin-base.nix` sets `nixpkgs.hostPlatform = "aarch64-darwin"` for the current Darwin host

If a feature needs an architecture- or hardware-specific package source, treat it as normal module logic. `modules/features/fingerprint.nix` captures `inputs.libfprint-goodix55b4` directly from the flake-parts module closure and installs it through a regular `nixpkgs.overlays` entry inside the feature module. No extra `specialArgs` plumbing is needed beyond the `inputs` already available to the flake-parts modules.

## Adding a new feature (worked example)

This is the normal workflow when adding a feature that has both system-level packages and home-manager configuration.

### Step 1: create the feature file

Create a new file:

```text
modules/features/<feature-name>.nix
```

You do not need to add that file to any import list under `modules/`; `import-tree` will discover it automatically.

### Step 2: publish the module groups you need

Start with the flake-parts skeleton:

```nix
{ ... }:
{
  flake.modules.nixos.<feature-name> = { pkgs, ... }: {
    # NixOS system config
  };

  flake.modules.darwin.<feature-name> = { pkgs, ... }: {
    # nix-darwin system config
  };

  flake.modules.homeManager.<feature-name> = { pkgs, lib, ... }: {
    # home-manager config
  };
}
```

Only publish the classes that actually make sense for the feature. If it is Linux-only, skip `darwin`. If it is home-manager-only, publish only `flake.modules.homeManager.<feature-name>`.

### Step 3: fill it in with real configuration

Here is a realistic example following this repo's current conventions. It adds one shared system package on both platforms, one home-manager package, enables a small home-manager program option, and uses an Option A conditional for a tiny platform difference:

```nix
{ ... }:
let
  toolsSystemModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ripgrep ];
  };
in
{
  flake.modules.nixos.tools = toolsSystemModule;
  flake.modules.darwin.tools = toolsSystemModule;

  flake.modules.homeManager.tools = { pkgs, ... }: {
    home.packages = [ pkgs.fd ];

    programs.zsh = {
      enable = true;
      shellAliases = {
        search = if pkgs.stdenv.hostPlatform.isLinux then "rg -n" else "rg --smart-case";
      };
    };
  };
}
```

The important parts:

- the shared `toolsSystemModule` mirrors the pattern used in `modules/features/base.nix` and `modules/features/proton.nix`
- the home-manager module uses a small `pkgs.stdenv.hostPlatform.isLinux` conditional, like `modules/features/zsh.nix`
- there is no separate `enable` flag; importing the module means the feature is wanted

### Step 4: enable the feature where it is needed

For the system-level part, add it to the relevant host file under `modules/hosts/`.

For example, in a NixOS host:

```nix
imports = [
  inputs.self.modules.nixos.base
  inputs.self.modules.nixos.linux-base
  inputs.self.modules.nixos.tools
];
```

And in a Darwin host:

```nix
imports = [
  inputs.self.modules.darwin.base
  inputs.self.modules.darwin.darwin-base
  inputs.self.modules.darwin.tools
];
```

For the home-manager part, add it to the per-host home-manager imports list in `modules/flake/configurations.nix`:

```nix
home-manager.users.mrolli.imports = [
  inputs.self.modules.homeManager.git
  inputs.self.modules.homeManager.tools
  inputs.self.modules.homeManager.mrolli-linux
];
```

That split is important:

- system-level activation happens from the host file in `modules/hosts/`
- home-manager activation happens from the host-specific home-manager import list in `modules/flake/configurations.nix`

### Step 5: follow the no-`enable`-option convention

In this repo, importing a feature module should usually turn it on directly. Do not add `lib.mkEnableOption`, `options.myFeature.enable`, or `config.myFeature.enable` boilerplate unless the feature genuinely needs to stay optional even after a host has already chosen to import it.

Most feature files here are direct configuration payloads, not mini-submodule frameworks.

### Step 6: validate the result

From the repository root, run:

```bash
nix flake check
nix build --no-link '.#darwinConfigurations.id-mrolli-mbp.system'
```

The first command evaluates the flake and its checks. The second builds the
Darwin system configuration without creating a `result` symlink or activating
it.

To inspect the configured system derivation without building it:

```bash
nix eval '.#darwinConfigurations.id-mrolli-mbp-M4-24.config.system.build.toplevel.drvPath'
```

## Validating changes

Run these from the repository root:

```bash
nix flake check
```

Evaluates the flake and runs any flake checks.

```bash
nix build --no-link '.#darwinConfigurations.id-mrolli-mbp-M4-24.system'
```

Builds the current laptop's nix-darwin system configuration without activating
it.

```bash
sudo nix run nix-darwin -- switch --flake .#id-mrolli-mbp-M4-24
```

Bootstraps and activates the configuration when `darwin-rebuild` is not yet
installed. The Determinate Nix installer enables the required `nix-command`
and `flakes` experimental features and manages the Nix daemon; this
configuration therefore sets `nix.enable = false`. After this succeeds, use
`darwin-rebuild switch --flake .#id-mrolli-mbp-M4-24` for routine updates. Do
not use bare `nix build`: it searches for a default package output, while this
flake provides a nix-darwin system output at the explicit attribute above.

### Determinate Nix settings

The flake imports Determinate's nix-darwin module. The shared
`darwin-base` feature enables its integration for every Darwin host and manages
`/etc/nix/nix.custom.conf`, which is included by Determinate's generated
`/etc/nix/nix.conf`; do not edit the generated file directly.

It sets:

```nix
determinateNix.customSettings.auto-optimise-store = true;
```

This enables store deduplication as new paths are added. Determinate Nixd
manages garbage collection based on available disk space, so this
configuration does not define a separate nix-darwin GC schedule.

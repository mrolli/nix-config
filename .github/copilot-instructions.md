# Copilot instructions

## Repository model

This is a Den-based Nix flake assembled with `flake-parts` and `import-tree`.
Keep `flake.nix` small: it imports `inputs.den.flakeModule` and
`inputs.import-tree ./modules`. Every `.nix` file under `modules/` is
auto-imported as a flake-parts module; do not add manual imports for those
files. Den declares machines and users in `den.hosts`, shared defaults and
batteries in `den.default`, and configuration in `den.aspects.*`. Den generates
the system and Home Manager flake outputs; inspect `nix flake show` before
referring to a particular output.

- `modules/flake/` owns the host roster and shared Den defaults.
- `modules/aspects/core/` owns reusable platform and baseline concerns.
- `modules/aspects/apps/` owns opt-in application concerns.
- `modules/hosts/<host>.nix` owns host aspects and machine-specific policy.
- `modules/users/<user>.nix` composes user aspects and batteries. Put growing
  per-user concerns in `modules/users/<user>/<concern>.nix`; they can contribute
  to the same `den.aspects.<user>` without another import.
- Non-module assets used by aspects live alongside their owner or under
  `modules/aspects/files/`.

## Aspect conventions

- Publish entity modules under `den.aspects.<name>.<class>` (`nixos`,
  `darwin`, or `homeManager`) and compose aspects through their `includes`
  lists. The host roster selects entities and applies matching host/user
  aspects; `den.default` broadcasts common batteries and defaults.
- Keep shared behavior in reusable aspects, host policy in host aspects, and
  personal preferences in user aspects or concern files. An app aspect may
  contain personal settings when intentional; inspect it before including it
  for another user. Avoid defining the same system or user preference in
  competing modules.
- The outer module receives flake-level arguments such as `inputs` and
  `den`. Bind `pkgs`, `config`, and platform-specific module arguments inside
  the nested `darwin`, `nixos`, or `homeManager` module function. Import
  upstream NixOS/Darwin/Home Manager modules in that nested module's
  `imports`, not in the flake-level import list.
- When option paths and behavior are shared, reuse a module function across
  classes; use `pkgs.stdenv.hostPlatform` inside the entity module for
  platform-specific values. Keep class-specific settings in their respective
  class blocks.
- The Den roster's host/output key and `hostName` can differ. The hostname
  battery sets `networking.hostName`; derive other defaults from the
  evaluated option and use `lib.mkDefault` where host overrides are expected.
- The Darwin Nix daemon belongs to Determinate Nix: keep `nix.enable = false`
  and make daemon additions through `determinateNix.customSettings`.
  User-scoped macOS preferences belong in Darwin-gated Home Manager modules;
  use per-key writes to avoid replacing unrelated defaults, and use Home
  Manager's key-remapping service for per-user mappings.
- Stable release inputs and an independent `nixpkgs-unstable` input coexist.
  Opt individual fast-moving packages into unstable using the flake's
  `unstablePkgs` helper rather than changing the system-wide package set.
  Treat `system.stateVersion` and `home.stateVersion` as compatibility
  baselines, not release-version switches.

## Development and validation

`devenv shell` provides the Nix development environment and `nixfmt` and
`shellcheck` hooks. Format changed Nix files with `nixfmt`; run `shellcheck`
for changed shell scripts. From the repository root, run `nix flake check`
for Nix changes and use `nix flake show` plus targeted `nix eval` to inspect
generated outputs or specific settings. Git-backed flakes omit untracked
files: add new module or asset files to Git's index before evaluating them.
There is no separate unit-test suite.

For Darwin activation, use `scripts/darwin-switch-summary.sh --host <name>`;
it builds, compares against the running system, and asks before switching.
The helper defaults to `$HOME/.nix-config`; set `NIX_SYSTEM_FLAKE_DIR` when
working from another checkout. Inspect the current Den-generated host names
before passing a host to the helper.

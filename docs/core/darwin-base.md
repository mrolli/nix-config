# Darwin base

<!-- BEGIN GENERATED: darwin-base -->
<!-- Generated from modules/aspects/core/darwin-base.nix; edit the marked Nix block instead. -->
Shared macOS policy, with Determinate Nix owning the Nix daemon and settings.

`nix.enable = false` is intentional: do not configure the daemon through
nix-darwin. Add daemon settings via `determinateNix.customSettings`.
`system.stateVersion` is a compatibility baseline, not a nix-darwin release
selector; do not bump it during ordinary upgrades.

The hostname battery sets `networking.hostName`; computerName and NetBIOSName
derive from that evaluated value unless a host overrides the latter. This
aspect also enables sudo Touch ID and sets shared power, timezone, and startup
policies.

See [nix-darwin options] and the [Determinate Nix on macOS guide] for the
platform-specific options and daemon ownership model.

[nix-darwin options]: <https://nix-darwin.github.io/nix-darwin/manual/index.html>
[Determinate Nix on macOS guide]: <https://docs.determinate.systems/guides/nix-darwin/>
<!-- END GENERATED: darwin-base -->

<!-- GENERATED SOURCE: darwin-base -->
[Source: `modules/aspects/core/darwin-base.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/core/darwin-base.nix)
<!-- END GENERATED SOURCE: darwin-base -->

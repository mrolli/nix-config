# Cachix

<!-- BEGIN GENERATED: cachix -->
<!-- Generated from modules/aspects/apps/cachix.nix; edit the marked Nix block instead. -->
Install Cachix and supply its authentication token through sops-nix.

The `cachix/authToken` secret is inserted into a read-only Dhall config by a
sops-nix template at activation. The Nix store contains only the placeholder,
not the token. Since the generated file is managed by sops-nix, do not use
`cachix authtoken` to update it; edit the encrypted source with `sops` and
switch instead.

See [Secrets management] for secret rules and the [Cachix documentation] for
Cachix commands.

[Secrets management]: <../secrets-management.md>
[Cachix documentation]: <https://docs.cachix.org>
<!-- END GENERATED: cachix -->

<!-- GENERATED SOURCE: cachix -->
[Source: `modules/aspects/apps/cachix.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/cachix.nix)
<!-- END GENERATED SOURCE: cachix -->

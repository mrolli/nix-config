# Secrets aspect

<!-- BEGIN GENERATED: secrets -->
<!-- Generated from modules/aspects/core/secrets.nix; edit the marked Nix block instead. -->
Load the sops-nix Home Manager module and configure the per-host age key and
default encrypted YAML file.

The [sops-nix] project provides the [Home Manager sops module] imported here.

Declare individual secrets in the consuming aspect and reference only the
generated secret path or a `sops.placeholder`; never read secret contents into
a Nix expression, because that would place plaintext in the Nix store.
`sops.templates` can render a configuration file during activation without
exposing the secret in the store.

See [Secrets management] for key provisioning, recipient changes, recovery,
and operational recipes.

[sops-nix]: <https://github.com/Mic92/sops-nix>
[Home Manager sops module]: <https://github.com/Mic92/sops-nix#home-manager>
[Secrets management]: <../../secrets-management.md>
<!-- END GENERATED: secrets -->

<!-- GENERATED SOURCE: secrets -->
[Source: `modules/aspects/core/secrets.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/core/secrets.nix)
<!-- END GENERATED SOURCE: secrets -->

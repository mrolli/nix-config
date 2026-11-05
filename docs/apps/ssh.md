# OpenSSH

<!-- BEGIN GENERATED: ssh -->
<!-- Generated from modules/aspects/apps/ssh.nix; edit the marked Nix block instead. -->
Configure Home Manager's OpenSSH client with explicit config loading and
conservative shared defaults.

Home Manager's generated config includes `~/.ssh/config.d/*` and disables its
implicit defaults. The per-user host file is included before the final
`Host *` block, so host-specific values win. OpenSSH keeps the first value
seen for most options, while `IdentityFile` accumulates; avoid a catch-all
identity file.

`IdentitiesOnly` limits offered keys to those selected by matching
`IdentityFile` entries. Keepalive settings are shared defaults. Hostnames,
usernames, addresses, and per-host identities are configured separately in
the user's encrypted host file; see [SSH identities].
See the [Home Manager SSH options] for Nix settings and the
[OpenSSH client configuration] reference for matching and precedence rules.

[Home Manager SSH options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable>
[OpenSSH client configuration]: <https://man.openbsd.org/ssh_config>
[SSH identities]: <../users/mrolli-ssh.md>
<!-- END GENERATED: ssh -->

<!-- GENERATED SOURCE: ssh -->
[Source: `modules/aspects/apps/ssh.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/ssh.nix)
<!-- END GENERATED SOURCE: ssh -->

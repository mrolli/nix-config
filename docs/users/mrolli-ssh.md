# SSH identities

<!-- BEGIN GENERATED: mrolli-ssh -->
<!-- Generated from modules/users/mrolli/ssh.nix; edit the marked Nix block instead. -->
Manage mrolli's SSH identities, 1Password agent allowlist, Git signing
identities, and encrypted host configuration.

Private keys remain in 1Password. The four public keys are declared here and
linked into `~/.ssh`; login and signing keys are separate for the private and
work identities. `agent.toml` selects the four items by their unique titles.

Host-specific names, users, addresses, and `IdentityFile` choices are kept in
the encrypted `secrets/ssh_config`, delivered as
`~/.ssh/config.d/hosts`. Edit it with `sops secrets/ssh_config`. Add a public
key to the relevant server or hosting account before selecting it in a host
entry. Avoid a default `IdentityFile`: matching SSH host blocks accumulate
identity files.

Git defaults to the private signing key. Run `git-use-unibe-identity` inside
a work repository to select the work identity and signing key. The generated
allowed-signers file lets Git verify signatures locally.

See [Secrets management] for encrypted-file recovery and recipient handling,
[1Password SSH agent docs] for agent setup, and [Git signing] for Git's SSH
signature format.

[Secrets management]: <../../secrets-management.md>
[1Password SSH agent docs]: <https://developer.1password.com/docs/ssh/agent/>
[Git signing]: <https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work>
<!-- END GENERATED: mrolli-ssh -->

<!-- GENERATED SOURCE: mrolli-ssh -->
[Source: `modules/users/mrolli/ssh.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/users/mrolli/ssh.nix)
<!-- END GENERATED SOURCE: mrolli-ssh -->

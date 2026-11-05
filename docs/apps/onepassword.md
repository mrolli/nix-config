# 1Password

<!-- BEGIN GENERATED: onepassword -->
<!-- Generated from modules/aspects/apps/onepassword.nix; edit the marked Nix block instead. -->
Install the 1Password app and CLI, and connect OpenSSH and Git to the 1Password
SSH agent.

The GUI is a self-updating Homebrew cask on Darwin; the CLI is installed from
nixpkgs-unstable. The GUI must be in `/Applications` for CLI and browser
integrations.

`programs.ssh.settings."*".IdentityAgent` points OpenSSH to the agent socket.
On macOS the path is inside the 1Password Group Containers directory; Linux
uses `~/.1password/agent.sock`. The per-user key allowlist lives in
`~/.config/1Password/ssh/agent.toml`; see [SSH identities].

Git's `gpg.ssh.program` uses 1Password's `op-ssh-sign`. SSH authentication and
commit signing are separate operations; signing prompts for 1Password
authorization. See [Git signing] and the [1Password SSH agent documentation].
The related settings are documented in the [Home Manager SSH options] and
[Home Manager Git options].

[Home Manager SSH options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable>
[Home Manager Git options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable>
[1Password SSH agent documentation]: <https://developer.1password.com/docs/ssh/agent/>
[SSH identities]: <../users/mrolli-ssh.md>
[Git signing]: <git.md#ssh-commit-signing>
<!-- END GENERATED: onepassword -->

<!-- GENERATED SOURCE: onepassword -->
[Source: `modules/aspects/apps/onepassword.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/onepassword.nix)
<!-- END GENERATED SOURCE: onepassword -->

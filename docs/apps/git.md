# git

<!-- BEGIN GENERATED: git -->
<!-- Generated from modules/aspects/apps/git.nix; edit the marked Nix block instead. -->
Configure Git and SSH commit signing.

The shared Git aspect sets the personal identity and enables signing for
commits and tags. SSH signing is enabled with `gpg.format = "ssh"`; the
signing key and `gpg.ssh.allowedSignersFile` are supplied by the user aspect.
The 1Password aspect supplies `op-ssh-sign`, which authorizes each signature.
The [Home Manager Git options] document the Git settings supported by the
module; Git's signing model is described in [Git SSH signing].

## SSH commit signing

`git-use-unibe-identity` sets the work name, email, and work signing key in
the current repository only. Use it from inside a Git worktree. Key setup,
registration with hosting providers, and verification are in [SSH identities].

[Home Manager Git options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable>
[Git SSH signing]: <https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work>
[SSH identities]: <../users/mrolli-ssh.md>
<!-- END GENERATED: git -->

<!-- GENERATED SOURCE: git -->
[Source: `modules/aspects/apps/git.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/git.nix)
<!-- END GENERATED SOURCE: git -->

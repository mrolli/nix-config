---
icon: material/cog-refresh
---

# nix-config

A Nix-based machine configuration repository based on [Nix packages],
[nix-darwin] and [Home Manager] tied together using context-aware
aspect-oriented patterns brought by [Den].

This repo is the successor of my [dotfiles] and the [macos-deplaybook].

## Documentation

- [Onboarding](onboarding.md) — install or restore a configured Mac.
- [Secrets management](secrets-management.md) — choose, provision, and rotate
  secrets stored in sops or 1Password.
- Aspect guides explain behavior that is not obvious from package installation
  and ordinary settings:
  - [1Password](apps/onepassword.md), [Git](apps/git.md),
    [OpenSSH](apps/ssh.md), [Cachix](apps/cachix.md), [Neovim](apps/neovim.md),
    [Zsh](apps/zsh.md), [Copilot CLI](apps/github-copilot-cli.md), [Claude
    Code](apps/claude-code.md), and [personal scripts](apps/personal-scripts.md).
  - [Core platform aspects](core/darwin-base.md) and [the secrets
    aspect](core/secrets.md).
  - [mrolli's SSH identities](users/mrolli-ssh.md).

[Nix packages]: <https://github.com/nixos/nixpkgs>
[nix-darwin]: <https://github.com/nix-darwin/nix-darwin>
[Home Manager]: <https://github.com/nix-community/home-manager>
[Den]: <https://denful.den.dev>
[dotfiles]: <https://github.com/mrolli/dotfiles>
[macos-deplaybook]: <https://github.com/mrolli/macos-deplaybook>

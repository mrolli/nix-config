# zsh

<!-- BEGIN GENERATED: zsh -->
<!-- Generated from modules/aspects/apps/zsh.nix; edit the marked Nix block instead. -->
Install and configure zsh using [Home Manager]
[Home Manager]: <https://nix-community.github.io/home-manager/options/home-manager/programs/zsh.html>

The aspect configures Home Manager on every supported platform and enables
zsh at the system level for NixOS and Darwin. User configuration lives under
XDG config; history and completion caches live under XDG data/cache paths.

## Usage

### Aliases

The aspect defines shared aliases and adds the Darwin-only `u` shortcut for
`darwin-switch-summary`.

### Vi mode

zsh-vi-mode provides Vim-style command-line editing. Press `Esc` to enter
normal mode. fzf-tab is loaded after vi mode and before syntax highlighting.

Completion initialization and extra completion definitions must be loaded
before `compinit`; the aspect sets their XDG cache paths explicitly.

### Integrations

The aspect loads `op` and Terraform completions only when those commands are
available. On Darwin it also loads the macOS helper functions. Personal
completions and scripts are supplied by the personal-scripts aspect.
<!-- END GENERATED: zsh -->

<!-- GENERATED SOURCE: zsh -->
[Source: `modules/aspects/apps/zsh.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/zsh.nix)
<!-- END GENERATED SOURCE: zsh -->

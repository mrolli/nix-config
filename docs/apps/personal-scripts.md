# personal-scripts

<!-- BEGIN GENERATED: personal-scripts -->
<!-- Generated from modules/aspects/apps/personal-scripts.nix; edit the marked Nix block instead. -->
Install and deploy the repository's personal command-line scripts.

Shared scripts are declared in `modules/aspects/files/scripts/common/`; macOS
scripts live in `darwin/`. Each script is linked as an executable in
Home Manager's `xdg.binHome`. Put shared runtime dependencies in the common
package list and platform-only dependencies in the matching platform block.

`darwin-switch-summary` is built with `writeShellApplication` and reads the
repository's `scripts/darwin-switch-summary.sh`. The Git identity helper
changes only local repository config and must be run inside a Git worktree.
The aspect includes 1Password because some scripts call `op`.

See [Home Manager file deployment options] for the `home.file` mechanism.

[Home Manager file deployment options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-home.file>
<!-- END GENERATED: personal-scripts -->

<!-- GENERATED SOURCE: personal-scripts -->
[Source: `modules/aspects/apps/personal-scripts.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/personal-scripts.nix)
<!-- END GENERATED SOURCE: personal-scripts -->

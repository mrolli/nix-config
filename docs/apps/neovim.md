# neovim

<!-- BEGIN GENERATED: neovim -->
<!-- Generated from modules/aspects/apps/neovim.nix; edit the marked Nix block instead. -->
Configure LazyVim through the `lazyvim-nix` Home Manager module.

The editable LazyVim configuration is in `modules/aspects/apps/lazyvim/`.
Spell additions are symlinked out of the Nix store to the live checkout so
`zg` can write them. Add words there and commit the `.add` file.

The aspect also overrides the `diff` Tree-sitter parser: the pinned
`lazyvim-nix` queries require a parser revision newer than its current
manifest. Remove the override when the upstream manifest is coherent.
See the [Home Manager LazyVim module] and [LazyVim] documentation for
configuring the editor.

[Home Manager LazyVim module]: <https://github.com/pfassina/lazyvim-nix>
[LazyVim]: <https://www.lazyvim.org/>
<!-- END GENERATED: neovim -->

<!-- GENERATED SOURCE: neovim -->
[Source: `modules/aspects/apps/neovim.nix`](https://github.com/mrolli/nix-config/blob/HEAD/modules/aspects/apps/neovim.nix)
<!-- END GENERATED SOURCE: neovim -->

# Assembles the final flake outputs (`nixosConfigurations`, `darwinConfigurations`)
# from the named module groups published elsewhere in `modules/` (see
# `modules/hosts/*.nix` for the per-host system modules and `modules/features/*.nix`
# / `modules/users/*.nix` for the home-manager modules referenced below).
{ inputs, ... }: {
  flake.darwinConfigurations.id-mrolli-mbp-M4-24 = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.determinate.darwinModules.default
      inputs.self.modules.darwin.id-mrolli-mbp-M4-24
    ];
  };
}

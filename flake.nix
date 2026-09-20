{
  description = "Flake-based Multi-platform Nix Configuration";

  # This flake follows the "dendritic pattern": every `.nix` file under
  # `modules/` (except entry points like this one) is a flake-parts module,
  # auto-discovered and imported via `import-tree`. See README.md for details
  # on the pattern and how to add new features.

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    #
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    #nix-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Provides the `flake.modules.<class>.<name>` option used throughout
        # `modules/` to publish nixos/darwin/homeManager feature modules.
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}

{
  description = "Den-based multi-platform Nix configuration";

  # Every `.nix` file under `modules/` is a flake-parts module, auto-discovered
  # by `import-tree`. Those modules publish Den aspects, hosts, and defaults;
  # Den resolves them into nix-darwin / NixOS / Home Manager outputs.

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    # Tracks nixpkgs-unstable independently (no `follows`), so individual
    # aspects can opt a specific package into a newer release than the
    # pinned `nixpkgs` input.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # den: the aspect/host framework that assembles the flake outputs from the
    # `den.aspects` / `den.hosts` / `den.default` published under `modules/`.
    den.url = "github:denful/den";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "github:DeterminateSystems/determinate";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # den's flake-parts module: defines the `den.*` options, resolves the
        # aspects/hosts/defaults published under `modules/`, and generates the
        # nixosConfigurations / darwinConfigurations / homeConfigurations outputs.
        inputs.den.flakeModule
        (inputs.import-tree ./modules)
      ];
    };
}

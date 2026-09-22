# Shared defaults applied to every host, user, and home den builds.
#
# `den.default` is broadcast to all entity scopes: the `nixos` / `darwin`
# class blocks only resolve on hosts of the matching class, and the
# `homeManager` block only on home-manager users. The two batteries create
# the user account (name/home/isNormalUser on NixOS, name/home on nix-darwin,
# plus the home-manager username/homeDirectory) and set the network hostname
# from the roster's `hostName` (which defaults to the host name).
{ den, ... }: {
  den.default = {
    includes = [
      den.batteries.define-user
      den.batteries.hostname
    ];

    # NixOS hosts: stateVersion + home-manager wiring (previously duplicated
    # per host in modules/flake/configurations.nix).
    nixos = { ... }: {
      system.stateVersion = "26.05";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
    };

    # nix-darwin hosts: the darwin home-manager module exposes the same
    # options. stateVersion is set by the darwin-base aspect (it is an
    # integer there, not a release string).
    darwin = { ... }: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
    };

    homeManager.home.stateVersion = "26.05";
  };
}

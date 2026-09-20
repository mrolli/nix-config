{ inputs, ... }: {
  flake.modules.darwin.darwin-base =
    {
      pkgs,
      config,
      ...
    }:
    {
      # Determinate Nix owns the Nix daemon and its configuration.
      nix.enable = false;
      system.stateVersion = 6;
      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      nixpkgs.hostPlatform = "aarch64-darwin";

      environment.systemPath = [
        "${config.homebrew.prefix}/bin"
        "${config.homebrew.prefix}/sbin"
      ];

      environment.systemPackages = with pkgs; [
        colima
        docker
        nh
      ];
    };
}

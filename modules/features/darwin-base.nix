{ inputs, ... }: {
  flake.modules.darwin.darwin-base =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.gc = {
        automatic = true;
        interval = [
          {
            Hour = 3;
            Minute = 45;
          }
        ];
      };
      nix.optimise = {
        automatic = true;
        interval = [
          {
            Hour = 3;
            Minute = 45;
          }
        ];
      };
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

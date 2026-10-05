{ inputs, ... }:
{
  den.aspects.darwin-base.darwin =
    { ... }:
    {
      imports = [
        inputs.determinate.darwinModules.default
      ];

      # Determinate Nix owns the Nix daemon and its configuration.
      # https://docs.determinate.systems/guides/nix-darwin/
      nix.enable = false;
      determinateNix = {
        enable = true;
        customSettings = {
          auto-optimise-store = true;
          trusted-users = [
            "root"
            "mrolli"
            "@wheel"
          ];
        };
      };

      power = {
        sleep = {
          computer = "never";
          display = 10;
          harddisk = 10;
        };
        restartAfterFreeze = true;
      };

      system = {
        stateVersion = 6;
        configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      };

      time.timeZone = "Europe/Zurich";
    };
}

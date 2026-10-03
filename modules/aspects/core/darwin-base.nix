{ inputs, ... }:
{
  den.aspects.darwin-base.darwin =
    { config, ... }:
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

        defaults = {
          NSGlobalDomain = {
            # General UI/UX                                                               #
            # Set system appearance theme to dark mode
            AppleInterfaceStyle = "Dark";
            # Always show scrollbar by default; OS default: Automatic
            AppleShowScrollBars = "Always";
            # Expand save panel by default
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;
          };
        };

        # I'm a nvim user, I want the Escape key nearby!
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToEscape = true;
        };

      };

      time.timeZone = "Europe/Zurich";
    };
}

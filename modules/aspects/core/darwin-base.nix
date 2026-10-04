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
            # Set system appearance theme to dark mode
            AppleInterfaceStyle = "Dark";

            # Always show scrollbar by default; OS default: Automatic
            AppleShowScrollBars = "Always";

            # Expand save panel by default
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;

            # Expand print panel by default
            PMPrintingExpandedStateForPrint = true;
            PMPrintingExpandedStateForPrint2 = true;

            # Save to disk (not to iCloud) by default
            NSDocumentSaveNewDocumentsToCloud = false;

            # Disable a lot auto-correction stuff; default: absent
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticInlinePredictionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            #NSAutomaticTextCompletionEnabled = true;

            # Trackpad: Disable natural scroll direction; OS default: true
            "com.apple.swipescrolldirection" = false;

            # Turn F1, F2, ... to standard function keys. Use function key to get the function key
            # to get the special function like volume and brightness control; OS default: false
            "com.apple.keyboard.fnState" = true;

            # Set a blazingly fast keyboard repeat rate, and make it happen more quickly.
            # (The KeyRepeat option requires logging out and back in to take effect.)
            "InitialKeyRepeat" = 20;
            "KeyRepeat" = 1;
          };

          finder = {

          };

          screencapture = {
            # Save screenshots to Documents folder; OS default: Desktop
            location = "${config.users.users.mrolli.home}/Documents/Screenshots";

            # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
            type = "png";

            # Disable shadow in screenshots
            disable-shadow = true;
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

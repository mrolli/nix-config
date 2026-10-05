{ ... }:
{
  den.aspects.mrolli.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      screenshotDirectory = "${config.home.homeDirectory}/Documents/Screenshots";

      writeDefaults =
        domain: settings:
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            key: value:
            let
              typedValue =
                if builtins.isBool value then
                  "-bool ${if value then "true" else "false"}"
                else if builtins.isInt value then
                  "-int ${toString value}"
                else if builtins.isString value then
                  "-string ${lib.escapeShellArg value}"
                else
                  throw "Unsupported macOS default type for ${domain}.${key}";
            in
            "run /usr/bin/defaults write ${lib.escapeShellArg domain} ${lib.escapeShellArg key} ${typedValue}"
          ) settings
        );
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # I'm a nvim user, I want the Escape key nearby!
      services.macos-remap-keys = {
        enable = true;
        keyboard.Capslock = "Escape";
      };

      home.activation.macosDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run /bin/mkdir -p ${lib.escapeShellArg screenshotDirectory}

        ${writeDefaults "NSGlobalDomain" {
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
          InitialKeyRepeat = 20;
          KeyRepeat = 1;
        }}

        ${writeDefaults "com.apple.screencapture" {
          # Save screenshots to Documents folder; OS default: Desktop
          location = screenshotDirectory;

          # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
          type = "png";

          # Disable shadow in screenshots
          disable-shadow = true;
        }}
      '';
    };
}

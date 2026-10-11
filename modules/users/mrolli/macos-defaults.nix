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

      # Scalar type flag for a single `defaults write`/`-dict-add` value, shared
      # between top-level keys and nested dict entries.
      scalarTypedValue =
        domain: key: value:
        if builtins.isBool value then
          "-bool ${if value then "true" else "false"}"
        else if builtins.isInt value then
          "-int ${toString value}"
        else if builtins.isFloat value then
          "-float ${builtins.toJSON value}"
        else if builtins.isString value then
          "-string ${lib.escapeShellArg value}"
        else
          throw "Unsupported macOS default type for ${domain}.${key}";

      writeDefaults =
        domain: settings:
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            key: value:
            let
              typedValue =
                if builtins.isList value && builtins.all builtins.isString value then
                  "-array ${lib.concatMapStringsSep " " lib.escapeShellArg value}"
                else if builtins.isAttrs value then
                  "-dict-add "
                  + lib.concatStringsSep " " (
                    lib.concatLists (
                      lib.mapAttrsToList (subKey: subValue: [
                        (lib.escapeShellArg subKey)
                        (scalarTypedValue domain "${key}.${subKey}" subValue)
                      ]) value
                    )
                  )
                else
                  scalarTypedValue domain key value;
            in
            "run /usr/bin/defaults write ${lib.escapeShellArg domain} ${lib.escapeShellArg key} ${typedValue}"
          ) settings
        );

      lightApps =
        domains:
        if
          builtins.isList domains && builtins.all (domain: builtins.isString domain && domain != "") domains
        then
          lib.concatMapStringsSep "\n" (
            domain: writeDefaults domain { NSRequiresAquaSystemAppearance = true; }
          ) domains
        else
          throw "lightApps expects a list of non-empty macOS preference domains";
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # I'm a nvim user, I want the Escape key nearby!
      services.macos-remap-keys = {
        enable = true;
        keyboard.Capslock = "Escape";
      };

      home.activation.macosDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Applications that shall always use the light mode.
        ${lightApps [
          "com.apple.Mail"
          "com.apple.Safari"
          "com.microsoft.Word"
        ]}


        # Settings in Global Domain
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
          NSAutomaticTextCompletionEnabled = true;

          # Enable spring loading for directories
          #"com.apple.springing".enabled = true;

          # Remove the spring loading delay for directories
          #"com.apple.springing".delay = 0.1;
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


        # Screen Captures
        run /bin/mkdir -p ${lib.escapeShellArg screenshotDirectory}
        ${writeDefaults "com.apple.screencapture" {
          # Save screenshots to Documents folder; OS default: Desktop
          location = screenshotDirectory;

          # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
          type = "png";

          # Disable shadow in screenshots
          disable-shadow = true;
        }}

        # Desktop Service
        ${writeDefaults "com.apple.desktopservices" {
          # Avoid creating .DS_Store files on network volumes and thumb drives
          DSDontWriteUSBStores = true;
          DSDontWriteNetworkStores = true;
        }}


        # Finder Settings
        ${writeDefaults "com.apple.finder" {
          # Sync the Documents folder automatically to the iCloud Drive
          FXICloudDriveDesktop = true;

          # Sync the Desktop folder automatically to the iCloud Drive
          FXICloudDriveDocuments = true;

          # Set the default location for new Finder windows
          # For Desktop paths, use `PfDe` and `file://${config.home.homeDirectory}/Desktop/`
          # For Home folder, use `PfHm` and `file://${config.home.homeDirectory}/`
          # For other paths, use `PfLo` and `file:///full/path/here/`
          #NewWindowTarget -string "PfDe"
          #NewWindowTargetPath -string "file://${config.home.homeDirectory}/Desktop/"
          NewWindowTarget = "PfLo";
          NewWindowTargetPath = "file://${config.home.homeDirectory}/Downloads/";

          # Disable window animations and Get Info animations; required by yabai
          DisableAllAnimations = true;

          # Show icons for hard drives, servers, and removable media on the desktop
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;

          # Show hidden files by default
          #AppleShowAllFiles  = true;

          # Show all filename extensions
          AppleShowAllExtensions = true;

          # Keep folders on top when sorting by name
          "_FXSortFoldersFirst" = true;
          "_FXSortFoldersFirstOnDesktop" = true;

          # Show path bar
          "ShowPathbar" = true;

          # Show status bar
          "ShowStatusBar" = true;

          # Allow text selection in Quick Look
          QLEnableTextSelection = true;

          # Display full POSIX path as Finder window title
          #_FXShowPosixPathInTitle = true;

          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";

          # Disable the warning when changing a file extension
          FXEnableExtensionChangeWarning = false;

          # Use column view in all Finder windows by default
          # Four-letter codes for the other view modes: `icnv`, `Nlsv`, `clmv`, `Flwv`
          FXPreferredViewStyle = "clmv";

          # Disable the warning before emptying the Trash
          WarnOnEmptyTrash = false;

          # Empty Trash securely by default
          EmptyTrashSecurely = true;

        }}
        # Show the ~/Library folder
        run /usr/bin/chflags nohidden ~/Library

        # Enable snap-to-grid for icons on the desktop and in other icon views
        #run /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist
        #run /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist
        #run /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist

        # Set the size of icons on the desktop and in other icon views
        #run /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 64" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist
        #run /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 64" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist
        #run /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 64" ${config.home.homeDirectory}/Library/Preferences/com.apple.finder.plist


        # Dock, Dashboard, and Hot Corners                                            #
        ${writeDefaults "com.apple.dock" {

          # Dock position; left, bottom, right
          orientation = "left";

          # Automatically hide the Dock and disable Dock animation
          autohide = "true";
          "autohide-time-modifier" = 0;
          "autohide-delay" = 0;

          # Set the icon size of Dock items
          tilesize = 36;

          # Speed up Mission Control animations
          "expose-animation-duration" = 0.15;

          # Make Dock icons of hidden applications translucent
          showhidden = true;

          # Trackpad: Enable App Exposé gesture; OS default: false
          showAppExposeGestureEnabled = true;

          # Do not show recent open applications
          "show-recents" = false;

          # Do not rearrange Spaces based on most recent use
          "mru-spaces" = false;

          # Hot corners
          # Possible values:
          #  0: no-op
          #  2: Mission Control
          #  3: Show application windows
          #  4: Desktop
          #  5: Start screen saver
          #  6: Disable screen saver
          #  7: Dashboard
          # 10: Put display to sleep
          # 11: Launchpad
          # 12: Notification Center
          # Bottom right screen corner → Mission Control
          #wvous-br-corner = 2;
          #wvous-br-modifier = 0;
          # Top right screen corner → Put display to sleep
          #wvous-tr-corner = 10;
          #wvous-tr-modifier = 0;
          # Bottom left screen corner → Desktop
          #wvous-bl-corner = 4;
          #wvous-bl-modifier = 0;
        }}


        # Trackpad, mouse, keyboard, Bluetooth accessories, and input
        ${writeDefaults "com.apple.AppleMultitouchTrackpad" {
          # Trackpad: Haptic feedback (light, silent clicking)
          FirstClickThreshold = 0;
          ActuationStrength = 0;

          # Trackpad: Enable tap to click; OS default: false
          Clicking = true;
        }}
        ${writeDefaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" {
          # Trackpad: Enable tap to click; OS default: false
          Clicking = true;
        }}

        # Show text input menu in menu bar
        ${writeDefaults "com.apple.TextInputMenu" {
          visible = true;
        }}



        # Safari Settings
        ${writeDefaults "com.apple.Safari" {
          # Restore browsing session at launch
          AlwaysRestoreSessionAtLaunch = true;

          # Always show the tab bar
          AlwaysShowTabBar = true;

          # Show overlay status bar
          ShowOverlayStatusBar = true;

          # Show the favorites bar
          ShowFavoritesBar-v2 = false;

          # Set default search eingine to DuckDuckGo, in private surfing mode too
          SearchProviderIdentifier = "com.duckduckgo";
          SearchProviderShortName = "DuckDuckGo";
          PrivateSearchEngineUsesNormalSearchEngineToggle = true;

          # Do not preload top hits in serach bar
          PreloadTopHit = false;

          # Open new windows and tabs with the start page
          NewWindowBehavior = 4;
          NewTabBehavior = 4;
          NewTabPageSetByUserGesture = true;

          # Set HomePage to an empty string
          HomePage = "about:blank";

          # Enable the Developer menu in Safari
          IncludeDevelopMenu = true;
          DeveloperMenuVisibility = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;

          # Disable AutoFill
          #AutoFillFromAddressBook = false;
          AutoFillPasswords = false;
          #AutoFillCreditCardData = false;
          #AutoFillMiscellaneousForms = false;

          # Enable “Do Not Track”
          SendDoNotTrackHTTPHeader = true;

          # Warn about fraudulent websites
          WarnAboutFraudulentWebsites = true;

          # Update extensions automatically
          InstallExtensionUpdatesAutomatically = true;
        }}
        ${writeDefaults "com.apple.Safari.SandboxBroker" {
          ShowDevelopMenu = true;
        }}


        # Time Machine Settings
        ${writeDefaults "com.apple.TimeMachine" {
          # Prevent Time Machine from prompting to use new hard drives as backup volume
          DoNotOfferNewDisksForBackup = true;

          # Ignore certain paths from Time Machine backupss
          SkipPaths = [
            "~mrolli/.ansible"
            "~mrolli/.ansible_async"
            "~mrolli/.cache"
            "~mrolli/.cargo"
            "~mrolli/.conda"
            "~mrolli/.colima"
            "~mrolli/.docker"
            "~mrolli/.local"
            "~mrolli/.npm"
            "~mrolli/.ollama/models"
            "~mrolli/.packer.d"
            "~mrolli/.vagrant"
            "~mrolli/.vagrant.d"
            "~mrolli/Downloads/NoBackup"
          ];
        }}

        # Disable local Time Machine backups
        #run tmutil disablelocal


        # Printing
        ${writeDefaults "com.apple.print.PrintingPrefs" {
          # Automatically quit printer app once the print jobs complete
          "Quit When Finished" = true;
        }}


        # Activity Monitor
        ${writeDefaults "com.apple.ActivityMonitor" {
          # Show the main window when launching Activity Monitor
          OpenMainWindow = true;

          # Show all processes in Activity Monitor
          ShowCategory = 0;
        }}


        # Messages Settings
        ${writeDefaults "com.apple.messageshelper.MessageController" {
          # Disable smart quote substitution and spell checking in the message input line
          SOInputLineSettings = {
            automaticQuoteSubstitutionEnabled = false;
            continuousSpellCheckingEnabled = false;
          };
        }}

        # App Store
        ${writeDefaults "com.apple.appstore" {
          # Disable in-app rating requests from apps downloaded from the App Store.
          InAppReviewEnabled = false;
        }}
      '';
    };
}

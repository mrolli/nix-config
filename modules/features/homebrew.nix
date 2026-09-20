{ ... }: {
  flake.modules.darwin.homebrew = { ... }: {
    homebrew = {
      enable = true;
      # onActivation.cleanup = "uninstall";
      brews = [
        "id-unibe-ch/tap/bildschirmUniversum"
      ];
      casks = [
        "windows-app"
      ];
    };
  };
}

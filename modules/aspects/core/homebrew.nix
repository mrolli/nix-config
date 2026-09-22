{ ... }:
{
  den.aspects.homebrew.darwin = {
    homebrew = {
      enable = true;
      brews = [
        "id-unibe-ch/tap/bildschirmUniversum"
      ];
      casks = [
        "windows-app"
      ];
    };
  };
}

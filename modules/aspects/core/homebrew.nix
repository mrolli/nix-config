{ ... }:
{
  den.aspects.homebrew.darwin = {
    homebrew = {
      enable = true;
      taps = [
        "hashicorp/tap"
      ];
      brews = [
        "id-unibe-ch/tap/bildschirmUniversum"
        "hashicorp/tap/terraform"
      ];
      casks = [
        "windows-app"
        "1password"
        "1password-cli"
      ];
    };
  };
}

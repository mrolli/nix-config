{ ... }:
{
  den.aspects.homebrew.darwin =
    { config, ... }:
    {
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
          "1password"
          "iina"
          "windows-app"
        ];
      };

      environment.systemPath = [
        "${config.homebrew.prefix}/bin"
        "${config.homebrew.prefix}/sbin"
      ];
    };
}

{ ... }:
{
  den.aspects.homebrew.darwin =
    { config, ... }:
    {
      homebrew = {
        enable = true;
        enableZshIntegration = true;
        taps = [
          "hashicorp/tap"
        ];
        brews = [
          "id-unibe-ch/tap/bildschirmUniversum"
          "hashicorp/tap/terraform"
        ];
        casks = [
          "1password"
          "ghostty"
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

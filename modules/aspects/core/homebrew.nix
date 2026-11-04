{ ... }:
{
  den.aspects.homebrew.darwin =
    { config, ... }:
    {
      homebrew = {
        enable = true;
        enableZshIntegration = true;
        taps = [
        ];
        brews = [
          "id-unibe-ch/tap/bildschirmUniversum"
        ];
        casks = [
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

{ den, ... }:
{
  den.aspects.galadriel = {
    includes = [
      # (den.batteries.unfree [ "nvidia-x11" "steam" ])
      # (den.batteries.insecure [ "foo-1.2.3" ])

      den.aspects.base
      den.aspects.darwin-base
      den.aspects.azure-cli
      den.aspects.homebrew
    ];

    darwin =
      { ... }:
      {
        homebrew = {
          enable = true;
          # Remove packages not managed here
          onActivation.cleanup = "uninstall";
          casks = [
            "alfred"
          ];
        };
      };

  };
}

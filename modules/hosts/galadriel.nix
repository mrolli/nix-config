{ den, ... }:
{
  den.aspects.galadriel = {
    includes = [
      # (den.batteries.unfree [ "nvidia-x11" "steam" ])
      # (den.batteries.insecure [ "foo-1.2.3" ])

      den.aspects.base
      den.aspects.darwin-base
      den.aspects.devenv
      den.aspects.ghostty
      den.aspects.homebrew
      den.aspects.onepassword
    ];

    darwin =
      { ... }:
      {
        homebrew = {
          # Remove packages not managed here
          onActivation.cleanup = "uninstall";
          brews = [ ];
          casks = [
            "alfred"
          ];
        };
      };

  };
}

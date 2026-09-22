{ den, lib, ... }:
let
  hostName = "id-mrolli";
in
{
  den.aspects."id-mrolli-mbp-M4-24" = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
      den.aspects.homebrew
      den.aspects.starship
    ];

    darwin = {
      networking.computerName = hostName;
      networking.hostName = hostName;
      system.defaults.smb.NetBIOSName = lib.toUpper hostName;
    };
  };
}

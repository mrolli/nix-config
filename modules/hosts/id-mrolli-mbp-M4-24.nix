{ den, lib, ... }:
let
  hostName = "id-mrolli";
in
{
  den.aspects."id-mrolli-mbp-M4-24" = {
    includes = [
      den.aspects.base
      den.aspects.darwin-base
      den.aspects.devenv
      den.aspects.homebrew
    ];

    darwin = {
      networking.computerName = hostName;
      networking.hostName = hostName;
      security.sudo.extraConfig = "%staff      ALL = (ALL) ALL";
      system.defaults.smb.NetBIOSName = lib.toUpper hostName;
    };
  };
}

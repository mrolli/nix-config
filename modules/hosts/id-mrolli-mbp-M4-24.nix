# The "id-mrolli-MBP-M4-24" host: Apple Silicon MacBook Pro running nix-darwin.
# Combines host-specific settings with the feature modules this host should
# implement.
#
{ inputs, lib, ... }:
let
  hostName = "id-mrolli";
in
{
  flake.modules.darwin.id-mrolli-mbp-M4-24 = { ... }: {
    imports = [
      inputs.self.modules.darwin.base
      inputs.self.modules.darwin.darwin-base
      inputs.self.modules.darwin.homebrew
      inputs.self.modules.darwin.mrolli
    ];

    networking.hostName = hostName;
    networking.computerName = hostName;
    system.defaults.smb.NetBIOSName = lib.toUpper hostName;
  };
}

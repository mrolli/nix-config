# @doc id=darwin-base target=docs/core/darwin-base.md
# Shared macOS policy, with Determinate Nix owning the Nix daemon and settings.
#
# `nix.enable = false` is intentional: do not configure the daemon through
# nix-darwin. Add daemon settings via `determinateNix.customSettings`.
# `system.stateVersion` is a compatibility baseline, not a nix-darwin release
# selector; do not bump it during ordinary upgrades.
#
# The hostname battery sets `networking.hostName`; computerName and NetBIOSName
# derive from that evaluated value unless a host overrides the latter. This
# aspect also enables sudo Touch ID and sets shared power, timezone, and startup
# policies.
#
# See [nix-darwin options] and the [Determinate Nix on macOS guide] for the
# platform-specific options and daemon ownership model.
#
# [nix-darwin options]: <https://nix-darwin.github.io/nix-darwin/manual/index.html>
# [Determinate Nix on macOS guide]: <https://docs.determinate.systems/guides/nix-darwin/>
# @enddoc
{ inputs, ... }:
{
  den.aspects.darwin-base.darwin =
    { lib, config, ... }:
    {
      imports = [
        inputs.determinate.darwinModules.default
      ];

      # Determinate Nix owns the Nix daemon and its configuration.
      # https://docs.determinate.systems/guides/nix-darwin/
      nix.enable = false;
      determinateNix = {
        enable = true;
        customSettings = {
          auto-optimise-store = true;
          trusted-users = [
            "root"
            "mrolli"
            "@wheel"
          ];
        };
      };

      networking.computerName = config.networking.hostName;
      system.defaults.smb.NetBIOSName = lib.mkDefault (config.networking.hostName);
      security.pam.services.sudo_local.touchIdAuth = true;

      power = {
        sleep = {
          computer = "never";
          display = 10;
          harddisk = 10;
        };
        restartAfterFreeze = true;
      };

      system = {
        stateVersion = 6;
        configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

        # No startup chime
        startup.chime = false;
      };

      time.timeZone = "Europe/Zurich";
    };
}

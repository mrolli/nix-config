# The den host roster: which machines exist, their system, and which users
# live on each. den turns every entry into a flake output
# (`nixosConfigurations.<name>` / `darwinConfigurations.<name>`), and applies
# the matching `den.aspects.<name>` host aspect plus each user's
# `den.aspects.<userName>` user aspect.
{ lib, ... }:
{
  # Every user gets both the "user" class (the OS account, forwarded to
  # users.users.<name> on NixOS and nix-darwin) and the "homeManager" class
  # (the Home Manager config). mkDefault so an individual user can narrow it
  # (e.g. a service account with no home would set classes = [ "user" ]).
  den.schema.user.config.classes = lib.mkDefault [
    "homeManager"
    "user"
  ];

  den.hosts.aarch64-darwin = {
    "id-mrolli-mbp-M4-24" = {
      hostName = "id-mrolli";
      users.mrolli = { };
    };

    "galadriel" = {
      hostName = "galadriel";
      users.mrolli = { };
    };
  };
}

# mrolli's SSH identities (keys live in 1Password) and encrypted host entries.
# See docs/secrets-management.md.
let
  # Public keys of the 1Password items `ssh-login-key` / `ssh-signing-key`
  # in the vaults Private (private identity) and ID (work identity).
  keys = {
    private-login = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQ7P1VLtKlxDKWKcFIn1GnuVjShgY+ERLx/K59p/0HZ";
    private-signing = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6LuUhz+PsLGapSBLB3hwvDE0VAQZt0a5MxMzMWDrko";
    id-login = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAh7WR46Wzd69/HTewt4cMWWdhZ8fDuxO8QkIkTZgtOe";
    id-signing = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl7yeCzcyv4z1457WgkrUgoPJHTPE8eqcaLVGX9oH80";
  };
in
{
  den.aspects.mrolli.homeManager =
    { config, lib, ... }:
    {
      # `IdentityFile ~/.ssh/<name>.pub` makes ssh request exactly that key
      # from the agent.
      home.file = lib.mapAttrs' (
        name: key: lib.nameValuePair ".ssh/${name}.pub" { text = "${key} ${name}\n"; }
      ) keys;

      # Keys the 1Password agent may offer, in this order.
      xdg.configFile."1Password/ssh/agent.toml".text = ''
        [[ssh-keys]]
        item = "ssh-login-key"
        vault = "Private"

        [[ssh-keys]]
        item = "ssh-login-key"
        vault = "ID"

        [[ssh-keys]]
        item = "ssh-signing-key"
        vault = "Private"

        [[ssh-keys]]
        item = "ssh-signing-key"
        vault = "ID"
      '';

      # Identity defaults. IdentityFile accumulates over all matching blocks, so
      # there is no catch-all: other hosts set IdentityFile in the host entries.
      programs.ssh.settings = {
        "github.com" = {
          User = "git";
          IdentityFile = "~/.ssh/private-login.pub";
        };
        "github.unibe.ch".User = "git";
        "*.unibe.ch".IdentityFile = "~/.ssh/id-login.pub";
      };

      # Host entries (names, users, addresses) in plain ssh_config syntax.
      sops.secrets.ssh-hosts = {
        sopsFile = ../../../secrets/ssh_config;
        format = "binary";
        path = "${config.home.homeDirectory}/.ssh/config.d/hosts";
      };
    };
}

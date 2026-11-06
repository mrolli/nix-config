# @doc id=mrolli-ssh target=docs/users/mrolli-ssh.md
# Manage mrolli's SSH identities, 1Password agent allowlist, Git signing
# identities, and encrypted host configuration.
#
# Private keys remain in 1Password. The four public keys are declared here and
# linked into `~/.ssh`; login and signing keys are separate for the private and
# work identities. `agent.toml` selects the four items by their unique titles.
#
# Host-specific names, users, addresses, and `IdentityFile` choices are kept in
# the encrypted `secrets/ssh_config`, delivered as
# `~/.ssh/config.d/hosts`. Edit it with `sops secrets/ssh_config`. Add a public
# key to the relevant server or hosting account before selecting it in a host
# entry. Keyed hosts set `IdentitiesOnly yes`; unconfigured hosts try all agent
# keys. Avoid a default `IdentityFile`: matching SSH host blocks accumulate
# identity files.
#
# Git defaults to the private signing key. Run `git-use-unibe-identity` inside
# a work repository to select the work identity and signing key. The generated
# allowed-signers file lets Git verify signatures locally.
#
# See [Secrets management] for encrypted-file recovery and recipient handling,
# [1Password SSH agent docs] for agent setup, and [Git signing] for Git's SSH
# signature format.
#
# [Secrets management]: <../../secrets-management.md>
# [1Password SSH agent docs]: <https://developer.1password.com/docs/ssh/agent/>
# [Git signing]: <https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work>
# @enddoc
# mrolli's SSH identities (keys live in 1Password) and encrypted host entries.
# See docs/secrets-management.md.
let
  # Public keys of `private-ssh-{login,signing}-key` in Private and
  # `id-ssh-{login,signing}-key` in ID.
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

      # The default vault is "Private" or "Privat" depending on locale;
      # select unique item titles without a locale-dependent vault name.
      # Order: private login, work login, private signing, work signing.
      xdg.configFile."1Password/ssh/agent.toml".text = ''
        [[ssh-keys]]
        item = "private-ssh-login-key"

        [[ssh-keys]]
        item = "id-ssh-login-key"

        [[ssh-keys]]
        item = "private-ssh-signing-key"

        [[ssh-keys]]
        item = "id-ssh-signing-key"
      '';

      # IdentityFile accumulates over matching blocks, so there is no catch-all.
      # Restrict keyed hosts; unconfigured hosts try the 1Password agent.
      programs.ssh.settings = {
        "github.com" = {
          User = "git";
          IdentityFile = "~/.ssh/private-login.pub";
          IdentitiesOnly = true;
        };
        "github.unibe.ch".User = "git";
        "*.unibe.ch" = {
          IdentityFile = "~/.ssh/id-login.pub";
          IdentitiesOnly = true;
        };
      };

      # Git commit signing: private identity by default; git-use-unibe-identity
      # switches a repository to the work identity and id-signing key.
      xdg.configFile."git/allowed_signers".text = ''
        michael@rollis.ch namespaces="git" ${keys.private-signing}
        michael.rolli@unibe.ch namespaces="git" ${keys.id-signing}
      '';
      programs.git.settings = {
        user.signingkey = "${config.home.homeDirectory}/.ssh/private-signing.pub";
        gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };

      # Host entries (names, users, addresses) in plain ssh_config syntax.
      sops.secrets.ssh-hosts = {
        sopsFile = ../../../secrets/ssh_config;
        format = "binary";
        path = "${config.home.homeDirectory}/.ssh/config.d/hosts";
      };
    };
}

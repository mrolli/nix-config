# @doc id=ssh target=docs/apps/ssh.md
# Configure Home Manager's OpenSSH client with explicit config loading and
# conservative shared defaults.
#
# Home Manager's generated config includes `~/.ssh/config.d/*` and disables its
# implicit defaults. The per-user host file is included before the final
# `Host *` block, so host-specific values win. OpenSSH keeps the first value
# seen for most options, while `IdentityFile` accumulates; avoid a catch-all
# identity file.
#
# Unconfigured hosts may try all agent keys. Hosts with an explicit
# `IdentityFile` also set `IdentitiesOnly yes`, limiting which key is offered;
# the catch-all must not define an `IdentityFile` because it accumulates.
# Keepalive settings are shared defaults. Hostnames, usernames, addresses, and
# per-host identities are configured separately in the user's encrypted host
# file; see [SSH identities].
# See the [Home Manager SSH options] for Nix settings and the
# [OpenSSH client configuration] reference for matching and precedence rules.
#
# [Home Manager SSH options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable>
# [OpenSSH client configuration]: <https://man.openbsd.org/ssh_config>
# [SSH identities]: <../users/mrolli-ssh.md>
# @enddoc
# OpenSSH client baseline managed by Home Manager.
# Host entries are included from ~/.ssh/config.d/ (users provide them there).
# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable
{
  den.aspects.ssh.homeManager = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [ "config.d/*" ];
      # Explicitly keyed hosts use IdentitiesOnly yes; other hosts try the agent.
      settings."*" = {
        IdentitiesOnly = false;
        ServerAliveInterval = 180;
        ServerAliveCountMax = 2;
      };
    };
  };
}

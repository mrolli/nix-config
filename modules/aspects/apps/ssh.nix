# OpenSSH client baseline managed by Home Manager.
# Host entries are included from ~/.ssh/config.d/ (users provide them there).
# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable
{
  den.aspects.ssh.homeManager = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [ "config.d/*" ];
      # Rendered last: first value wins in ssh_config, so host entries override it.
      settings."*" = {
        IdentitiesOnly = true;
        ServerAliveInterval = 180;
        ServerAliveCountMax = 2;
      };
    };
  };
}

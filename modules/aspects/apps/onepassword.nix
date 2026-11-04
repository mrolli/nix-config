# 1Password app, CLI and SSH agent.
# The app is a self-updating Homebrew cask on Darwin (it must live in
# /Applications for the CLI and browser integrations); the CLI comes from
# nixpkgs-unstable. Which SSH keys the agent offers is selected per user in
# ~/.config/1Password/ssh/agent.toml.
# https://developer.1password.com/docs/ssh/agent/
{ inputs, ... }:
{
  den.aspects.onepassword = {
    darwin.homebrew.casks = [ "1password" ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (inputs.self.lib.unstablePkgs pkgs.stdenv.hostPlatform.system)._1password-cli
        ];

        programs.ssh.settings."*".IdentityAgent =
          if pkgs.stdenv.hostPlatform.isDarwin then
            ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
          else
            "~/.1password/agent.sock";
      };
  };
}

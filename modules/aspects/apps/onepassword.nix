# @doc id=onepassword target=docs/apps/onepassword.md
# Install the 1Password app and CLI, and connect OpenSSH and Git to the 1Password
# SSH agent.
#
# The GUI is a self-updating Homebrew cask on Darwin; the CLI is installed from
# nixpkgs-unstable. The GUI must be in `/Applications` for CLI and browser
# integrations.
#
# `programs.ssh.settings."*".IdentityAgent` points OpenSSH to the agent socket.
# On macOS the path is inside the 1Password Group Containers directory; Linux
# uses `~/.1password/agent.sock`. The per-user key allowlist lives in
# `~/.config/1Password/ssh/agent.toml`; see [SSH identities].
#
# Git's `gpg.ssh.program` uses 1Password's `op-ssh-sign`. SSH authentication and
# commit signing are separate operations; signing prompts for 1Password
# authorization. See [Git signing] and the [1Password SSH agent documentation].
# The related settings are documented in the [Home Manager SSH options] and
# [Home Manager Git options].
#
# [Home Manager SSH options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable>
# [Home Manager Git options]: <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable>
# [1Password SSH agent documentation]: <https://developer.1password.com/docs/ssh/agent/>
# [SSH identities]: <../users/mrolli-ssh.md>
# [Git signing]: <git.md#ssh-commit-signing>
# @enddoc
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

        # Git SSH signing through the 1Password app (Touch ID per signature).
        programs.git.settings.gpg.ssh.program =
          if pkgs.stdenv.hostPlatform.isDarwin then
            "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else
            "/opt/1Password/op-ssh-sign";
      };
  };
}

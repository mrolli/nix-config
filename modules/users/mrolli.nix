{ ... }: {
  flake.modules.darwin.mrolli = { pkgs, ... }: {
    system.primaryUser = "mrolli";

    users.users.mrolli = {
      name = "mrolli";
      home = "/Users/mrolli";
      shell = pkgs.zsh;
    };
  };

  flake.modules.homeManager.mrolli-darwin = { ... }: {
    home.username = "mrolli";
    home.homeDirectory = "/Users/mrolli";
  };
}

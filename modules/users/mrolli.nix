{ ... }: {
  flake.modules.darwin.mrolli = { pkgs, ... }:
  let
    username = "mrolli";
  in {
    system.primaryUser = username;

    users.users.mrolli = {
      name = username;
      home = "/Users/mrolli";
      shell = pkgs.zsh;
    };
  };

  flake.modules.homeManager.mrolli-darwin = { ... }: {
    home.username = username;
    home.homeDirectory = "/Users/mrolli";
  };
}

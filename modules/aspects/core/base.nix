{ ... }:
let
  baseModule =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        azure-cli
        bat
        eza
        github-cli
        github-copilot-cli
        gnupg
        jq
        neovim
        viu
        yq
      ];
    };
in
{
  den.aspects.base = {
    nixos = baseModule;
    darwin = baseModule;
  };
}

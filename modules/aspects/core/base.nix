{ ... }:
let
  baseModule =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        azure-cli
        cargo
        eza
        git
        github-cli
        github-copilot-cli
        gnupg
        jq
        neovim
        yq-go
      ];
    };
in
{
  den.aspects.base = {
    nixos = baseModule;
    darwin = baseModule;
  };
}

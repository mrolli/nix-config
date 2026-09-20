{ inputs, ... }:
let
  baseModule = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      eza
      bat
      jq
      yq
      azure-cli
      github-cli
      github-copilot-cli
      gnupg
    ];
  };
in
{
  flake.modules.nixos.base = baseModule;
  flake.modules.darwin.base = baseModule;
}

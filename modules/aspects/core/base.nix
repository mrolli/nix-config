{ ... }:
let
  baseModule =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        cargo
        eza
        gnupg
        jq
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

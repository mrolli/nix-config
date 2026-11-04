# Secrets managed with sops-nix (Home Manager level).
# Concept, key inventory and recipes: docs/secrets-management.md
{ inputs, ... }:
{
  den.aspects.secrets.homeManager =
    { config, pkgs, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      # Tools for editing/rotating secrets from any machine that has the key.
      home.packages = with pkgs; [
        sops
        age
      ];

      # https://github.com/Mic92/sops-nix
      sops = {
        # Host age key; generated per host, never committed.
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = ../../../secrets/secrets.yaml;
      };
    };
}

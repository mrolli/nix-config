# @doc id=secrets target=docs/core/secrets.md
# Load the sops-nix Home Manager module and configure the per-host age key and
# default encrypted YAML file.
#
# The [sops-nix] project provides the [Home Manager sops module] imported here.
#
# Declare individual secrets in the consuming aspect and reference only the
# generated secret path or a `sops.placeholder`; never read secret contents into
# a Nix expression, because that would place plaintext in the Nix store.
# `sops.templates` can render a configuration file during activation without
# exposing the secret in the store.
#
# See [Secrets management] for key provisioning, recipient changes, recovery,
# and operational recipes.
#
# [sops-nix]: <https://github.com/Mic92/sops-nix>
# [Home Manager sops module]: <https://github.com/Mic92/sops-nix#home-manager>
# [Secrets management]: <../../secrets-management.md>
# @enddoc
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

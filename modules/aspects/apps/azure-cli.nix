# Install the Azure CLI with extensions system-wide
# https://learn.microsoft.com/cli/azure/
{ ... }:
let
  azureCliModule =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.azure-cli.withExtensions (
          with pkgs.azure-cli.extensions;
          [
            devcenter
            # k8s-extension 1.7.0 pins kubernetes==24.2.0 and oras==0.2.25;
            # nixpkgs ships newer versions, so skip the strict pin check.
            (k8s-extension.overridePythonAttrs { dontCheckRuntimeDeps = true; })
            log-analytics
            ssh
          ]
        ))
      ];
    };
in
{
  den.aspects.azure-cli = {
    nixos = azureCliModule;
    darwin = azureCliModule;
  };
}

# Onboarding a new or reinstalled Mac

A step-by-step guide to bring a Mac from a fresh macOS install to a fully
switched configuration from this repository. Follow the steps in order; each
one ends with a check.

Commands use `<host>` for the Den host name (the key in
`modules/flake/den-hosts.nix`, e.g. `rivendell` or `galadriel`), not the
macOS hostname.

## 1. Prepare macOS

1. Finish the macOS setup assistant, sign in to the Apple ID, and apply all
   software updates.
2. Install the Command Line Tools (provides `git`):

   ```sh
   xcode-select --install
   ```

3. Install [Homebrew]. nix-darwin manages the brews and casks, but does not
   install Homebrew itself:

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

Check: `git --version` and `brew --version` both work.

## 2. Install Determinate Nix

Install [Determinate Nix]. This repository expects it to own the Nix daemon
(`nix.enable = false` in nix-darwin):

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal afterwards.

Check: `nix --version` works.

## 3. Clone the repository

The repository is private. Neither `gh` nor 1Password is installed yet, so log
in with a temporary `gh` through the browser:

```sh
nix run nixpkgs#gh -- auth login --hostname github.com --git-protocol https --web
nix run nixpkgs#gh -- repo clone mrolli/nix-config ~/.nix-config
cd ~/.nix-config
```

The token is stored in the macOS Keychain. The `gh` installed by the first
switch reuses it, so no second login is needed.

The switch helper expects the checkout at `~/.nix-config`; set
`NIX_SYSTEM_FLAKE_DIR` if it lives elsewhere.

## 4. Register a new host (skip when reinstalling)

1. Add the host to `den.hosts.aarch64-darwin` in `modules/flake/den-hosts.nix`
   (set `hostName` if the macOS hostname differs from the Den key).
2. Create `modules/hosts/<host>.nix` with its host aspect; copy an existing
   host as a starting point.
3. Track the new file, then confirm the output exists:

   ```sh
   git add modules/hosts/<host>.nix
   nix flake show | grep <host>
   ```

## 5. Restore or create the sops host key

Secrets are decrypted with a per-host age key; see
[Secrets management](secrets-management.md) for the concept. `sops` and `age`
are not installed yet, so use `nix shell` / `nix run`.

The first switch does not strictly need the key: the encrypted file is copied
as-is, and only the sops-nix launchd agent decrypts at activation. Without a
key the agent fails and no secrets appear, but the rest of the configuration
activates. Doing this step first avoids a second switch.

### Old key restorable

Copy it back (e.g. from a backup) and you are done with this step:

```sh
mkdir -p ~/.config/sops/age
cp <backup>/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

### Old key lost, or a new host

A lost key cannot be recovered, so a new host key **must** be generated and
the secrets re-encrypted for it:

1. Generate the key and print its public key:

   ```sh
   mkdir -p ~/.config/sops/age
   nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
   ```

2. Put the public key into `.sops.yaml`: replace the host's anchor, or add a
   new `&<host>` anchor and reference it in every rule. Update the key table
   in [Secrets management](secrets-management.md#keys) too.
3. Re-encrypt with the recovery key. `op` is not installed yet, so copy the
   `AGE-SECRET-KEY-1…` line from the 1Password app ("sops recovery age key"):

   ```sh
   SOPS_AGE_KEY='AGE-SECRET-KEY-1…' nix run nixpkgs#sops -- updatekeys -y secrets/*.yaml
   ```

4. Commit `.sops.yaml`, `secrets/`, and the docs change.

If the old key may have been stolen rather than just lost, additionally run
`sops rotate -i secrets/*.yaml` and change the secret values at their source;
Git history still holds files the old key can decrypt.

Check: `nix run nixpkgs#sops -- -d secrets/secrets.yaml` decrypts with the
host key alone.

## 6. First switch

`darwin-rebuild` is not installed yet, so run nix-darwin from the flake:

```sh
sudo nix run nix-darwin -- switch --flake .#<host>
```

Homebrew casks are installed during this step and may take a while. Open a
new terminal afterwards so the new shell environment is loaded.

Check:

- `darwin-rebuild --version`, `sops --version`, and `devenv version` work.
- `ls ~/.config/sops-nix/secrets/` lists the declared secrets.

## 7. Sign in to apps and tools

Some logins are not managed by this repository:

1. Open 1Password, sign in, and enable *Settings → Developer → Integrate with
   1Password CLI* (and the SSH agent once it is configured).
2. Authenticate CLI tools that keep their own tokens, e.g. `gh auth login`
   and `az login`.
3. Grant permissions macOS asks for (Full Disk Access, Accessibility) to the
   terminal and the apps that need them.

## 8. Day-to-day switching

From now on, apply changes with the helper; it builds, shows a summary, and
asks before switching:

```sh
scripts/darwin-switch-summary.sh --host <host>
```

[Homebrew]: <https://brew.sh>
[Determinate Nix]: <https://docs.determinate.systems>

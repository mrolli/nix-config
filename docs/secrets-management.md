# Secrets management

This repository uses a hybrid approach:

- **[sops-nix]** for secrets that a machine needs unattended (activation,
  launchd agents, Nix itself) or that are bound to a host.
- **[1Password]** for interactive, personal secrets: SSH keys, Git signing,
  API tokens injected on demand with `op run` / `op inject`, and shell
  plugins.

Some tools keep their own login (`gh auth login`, `az login`, OAuth-based MCP
servers). Those tokens stay in the tool's own store or the macOS Keychain
and are not managed here.

## 1Password

Use 1Password for interactive secrets and SSH keys. The `onepassword` aspect
installs the macOS app as a Homebrew cask and the CLI from nixpkgs-unstable.
After switching, sign in to the app and enable **Settings → Developer →
Integrate with 1Password CLI** and **SSH Agent**. See the [1Password aspect
guide](apps/onepassword.md) and [1Password's SSH agent documentation].

### SSH keys

There are separate login and signing keys for the private and work identities.
Private key material stays in 1Password; the repository contains only public
keys.

| Identity | Purpose | 1Password item | Vault | Public key path |
| --- | --- | --- | --- | --- |
| Private | SSH login | `ssh-login-key` | `Private` | `~/.ssh/private-login.pub` |
| Private | Git signing | `ssh-signing-key` | `Private` | `~/.ssh/private-signing.pub` |
| Work | SSH login | `ssh-login-key` | `ID` | `~/.ssh/id-login.pub` |
| Work | Git signing | `ssh-signing-key` | `ID` | `~/.ssh/id-signing.pub` |

The user aspect generates `~/.config/1Password/ssh/agent.toml` to allowlist
these four items. Host-specific SSH entries are encrypted in
`secrets/ssh_config` and deployed to `~/.ssh/config.d/hosts`. Edit them with
`sops secrets/ssh_config`; use `IdentityFile ~/.ssh/<key>.pub` to select the
agent key for a host. Register login public keys with the relevant server or
hosting account before selecting them.

See the [OpenSSH aspect guide](apps/ssh.md) and [SSH identity guide](users/mrolli-ssh.md)
for configuration and troubleshooting.

### Git signing

The default Git identity uses the private signing key. Run
`git-use-unibe-identity` inside a work repository to select the work identity
and signing key. The generated `~/.config/git/allowed_signers` file lets Git
verify signatures locally. Register each signing key with its hosting account
as a **Signing** key; authentication keys and signing keys are distinct.

Check a local signature with:

```sh
git log --show-signature -1
```

See the [Git aspect guide](apps/git.md) for how signing is wired.

### Rotate a key

Create a replacement in the same 1Password vault, update its public key in
`modules/users/mrolli/ssh.nix`, and update the 1Password item allowlist if its
item name changes. For a login key, replace the public key on every server or
hosting account and update the encrypted host entries. For a signing key,
update the hosting provider's signing-key registration. Switch, verify login
and signatures, then revoke the old public key. If a private key was exposed,
revoke it immediately and rotate it at every place it was authorized.

## Where does a secret go?

| Question | sops | 1Password |
| --- | --- | --- |
| Needed without me present (activation, boot, launchd)? | yes | no |
| Must work offline or while 1Password is locked? | yes | no |
| Bound to a host rather than to me? | yes | no |
| Only used when I am at the keyboard? | no | yes |
| Personal credential, rotated often, needed on the phone? | no | yes |
| SSH private key or Git signing key? | no | yes |

If a secret is needed in both worlds, 1Password is the source of truth and
sops holds a copy. Rotate in 1Password first, then update the sops copy.

## sops

### Concepts

- **sops** encrypts the *values* of a YAML/JSON file; keys stay readable, so
  diffs show which secret changed.
- **age** is the encryption backend. Each recipient has a key pair; the
  public key (`age1…`) is listed in `.sops.yaml`, and the private key
  (`AGE-SECRET-KEY-1…`) never enters the repository.
- **`.sops.yaml`** holds `creation_rules`: which recipients a file matching a
  path pattern is encrypted for.
- **sops-nix** decrypts the secrets during Home Manager activation (on Darwin
  via a launchd agent) and exposes each one as a file. Nix only ever sees the
  *path*, never the plaintext, so nothing secret enters the Nix store.

### Tooling

`sops`, `age` and `age-keygen` are installed in the user profile by the
`secrets` aspect.

### Keys

| Key | Public key | Private key location |
| --- | --- | --- |
| recovery | `age1wckx8re2n0dfd7qtt4vfpcjtj4q67fcuv6363hqdnp9hn9xwvv6qw08rkw` | 1Password: "sops recovery age key" only |
| rivendell | `age199p8luy9c3gzv8xxd3rmu0u0u4rz8gpz372jdf30xv6mn7mhkchswv4vg9` | rivendell: `~/.config/sops/age/keys.txt` |

The recovery key is a recipient of every rule, so it can decrypt every
secrets file. It is never stored on a machine; use it only to recover or to
onboard a host from a machine that cannot decrypt.

`.sops.yaml` lists the public keys as YAML anchors and references them in
`creation_rules`. A file is encrypted for every recipient of the first rule
whose `path_regex` matches.

### Generate a host key

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt   # public key for .sops.yaml
```

`sops` finds this file through `$XDG_CONFIG_HOME/sops/age/keys.txt`;
`XDG_CONFIG_HOME` is set by the Home Manager environment aspect. Without it,
sops falls back to `~/Library/Application Support/sops/age/keys.txt` on
macOS. Set `SOPS_AGE_KEY_FILE` to override.

[sops-nix]: <https://github.com/Mic92/sops-nix>
[1Password]: <https://developer.1password.com/docs/cli/>
[1Password's SSH agent documentation]: <https://developer.1password.com/docs/ssh/agent/>

### Wiring in Nix

- Flake input `sops-nix` (follows `nixpkgs`).
- Aspect `den.aspects.secrets` in `modules/aspects/core/secrets.nix` imports
  the sops-nix Home Manager module and sets:
  - `sops.age.keyFile` to `~/.config/sops/age/keys.txt`
  - `sops.defaultSopsFile` to `secrets/secrets.yaml`
- The user aspect `modules/users/mrolli.nix` includes `den.aspects.secrets`.

On activation, Home Manager (re)starts the launchd agent
`org.nix-community.home.sops-nix`. It decrypts every declared secret into
`~/.config/sops-nix/secrets/<name>` (mode `0400`, owned by the user). Nix only
references these paths; the plaintext never enters the Nix store.

### Add a secret

1. Add the value: `sops secrets/secrets.yaml` (nested YAML keys are fine,
   e.g. `cachix: { token: … }`).
2. Declare it in the consuming aspect's `homeManager` block:

   ```nix
   sops.secrets."cachix/token" = { };
   ```

3. Reference the *path* (never the content):
   `config.sops.secrets."cachix/token".path`.
4. Commit `secrets/secrets.yaml` and the Nix change together, then switch.

Never read a secret with `builtins.readFile` or string interpolation of its
contents: that would copy the plaintext into the world-readable Nix store.

### Secret inside a config file (templates)

When a tool reads its secret from a config file, render the whole file with
`sops.templates`. The Nix store only holds the template with a placeholder;
sops-nix substitutes the value at activation and links the result
(mode `0400`) to `path`.

Example from `modules/aspects/apps/cachix.nix`:

```nix
sops.secrets."cachix/authToken" = { };
sops.templates."cachix.dhall" = {
  path = "${config.xdg.configHome}/cachix/cachix.dhall";
  content = ''
    { authToken = "${config.sops.placeholder."cachix/authToken"}" … }
  '';
};
```

The file is read-only and owned by sops-nix: tools can no longer write to it
(e.g. `cachix authtoken`); change the value with `sops` and switch instead.

### Inventory

| Secret | Consumer | Delivered as |
| --- | --- | --- |
| `cachix/authToken` | `cachix` aspect | `~/.config/cachix/cachix.dhall` (template) |
| SSH host config (`secrets/ssh_config`) | `mrolli` user aspect | `~/.ssh/config.d/hosts` (binary file) |

Keep this table in sync when adding or removing secrets.

### Remove a secret

1. Delete its `sops.secrets.<name>` declaration and every reference.
2. `sops secrets/secrets.yaml` and delete the key.
3. Commit and switch. If the value was compromised, also rotate it at its
   source; the old value remains decryptable from Git history.

### Inspect

```sh
sops -d secrets/secrets.yaml                          # all values
sops -d --extract '["cachix"]["authToken"]' secrets/secrets.yaml
launchctl print gui/$UID/org.nix-community.home.sops-nix | grep -E 'state|last exit'
ls -l ~/.config/sops-nix/secrets/
```

### Recovery drill

Prove now and then that the recovery key alone can decrypt (pointing
`SOPS_AGE_KEY_FILE` at `/dev/null` disables the host key):

```sh
SOPS_AGE_KEY_FILE=/dev/null \
SOPS_AGE_KEY="$(op read 'op://<vault>/sops recovery age key/<field>')" \
sops -d --extract '["cachix"]["authToken"]' secrets/secrets.yaml
```

Use 1Password's *Copy Secret Reference* for the exact `op://` path. Last
passed: 2026-11-04.

### Change recipients or rotate

| Situation | Action |
| --- | --- |
| Host key lost (not leaked) | New host key, update `.sops.yaml`, `sops updatekeys -y secrets/*.yaml` |
| Host removed | Remove it from `.sops.yaml`, `updatekeys`, then `sops rotate -i secrets/*.yaml` |
| Key leaked or stolen | As above, then change every secret value at its source |

- `updatekeys` re-encrypts only the file's data key for the current
  recipients; the values stay the same. Run it with any working key.
- `rotate` creates a new data key, so the removed key can no longer decrypt
  the new file.
- A removed or leaked key can still decrypt old versions from Git history.
  Only changing the values at their source (new tokens) truly revokes access.
- After any of these: commit, then switch on every host.

### Bootstrap a new or reinstalled host

Restoring or creating a host key on a fresh machine (including the case of a
lost key) is part of [Onboarding](onboarding.md#5-restore-or-create-the-sops-host-key).

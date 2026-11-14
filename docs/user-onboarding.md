# Onboarding a new user

This guide adds a user account to an existing host, composes the user's
aspects, and adjusts shared aspect settings for that user. To install or
restore a whole Mac, follow [Onboarding a new or reinstalled Mac](onboarding.md)
first.

The examples add a user `alice` to the host `galadriel`. Replace both names.

## How users are assembled

- `modules/flake/den-hosts.nix` declares which users live on which host.
- `modules/users/<user>.nix` declares the user aspect `den.aspects.<user>`.
  Den applies it to every host that lists the user.
- `modules/flake/den-defaults.nix` applies shared defaults to every user:
  `den.batteries.define-user` (user name and home directory) and
  `home.stateVersion`.
- Reusable aspects under `modules/aspects/` are opt-in through the user's
  `includes` list.

All files under `modules/` are imported automatically. Do not add import lists.

## 1. Create the macOS account

nix-darwin does not create macOS accounts for users declared here; it only
configures existing ones. Create the account in System Settings → Users &
Groups, and log in once so the home directory exists.

## 2. Add the user to the host roster

Add the user under the host in `modules/flake/den-hosts.nix`:

```nix
den.hosts.aarch64-darwin = {
  "galadriel" = {
    users.mrolli = { };
    users.alice = { };
  };
};
```

The attribute name is the account's short name.

## 3. Create the user aspect

Create `modules/users/alice.nix`:

```nix
{ den, ... }:
{
  den.aspects.alice = {
    includes = [
      (den.batteries.user-shell "zsh")

      den.aspects.bat
      den.aspects.direnv
      den.aspects.fzf
    ];

    homeManager = {
      home.preferXdgDirectories = true;
    };
  };
}
```

Git-backed flakes only see tracked files. Stage the new file before evaluating:

```bash
git add modules/users/alice.nix
```

Batteries useful in a user aspect:

| Battery | Effect |
| --- | --- |
| `den.batteries.user-shell "zsh"` | Enables the shell system-wide and in Home Manager. nix-darwin does not change the login shell of accounts it does not manage; zsh is the macOS default and reads the nix-darwin `/etc/zshrc`. For other shells, run `chsh -s /run/current-system/sw/bin/<shell>`. |
| `den.batteries.primary-user` | On Darwin, sets `system.primaryUser`. Only one user per host. |
| `den.batteries.host-aspects` | Forwards `homeManager` settings from the host aspect to this user. |

`define-user` is already applied by `den.default`; listing it again is
harmless.

For a growing configuration, keep `modules/users/alice.nix` as the composition
file and add concern files such as `modules/users/alice/macos-defaults.nix`.
Each file contributes to the same `den.aspects.alice`.

## 4. Choose aspects

App aspects live in `modules/aspects/apps/`; each file's header and the
[aspect guides](index.md#documentation) describe them. Read an aspect before
including it for another user; some carry personal values:

| Aspect | Personal content |
| --- | --- |
| `git` | mrolli's name, email, commit signing, and credential helpers. |
| `ssh`, `personal-scripts` | mrolli's SSH identities and work scripts. |
| `secrets` | Uses the per-host sops age key; see [Secrets management](secrets-management.md). |
| `starship` | One user's prompt preferences. |

Host-level settings that mention users, such as `trusted-users` in
`modules/aspects/core/darwin-base.nix`, are not added automatically. Extend
them if the new user needs the same rights.

## 5. Override an aspect's settings

Home Manager merges the settings of a shared aspect with the user's own
`homeManager` block. The user's block only affects that user.

- Keys the aspect does not set merge normally.
- Keys the aspect already sets need `lib.mkForce`; otherwise evaluation fails
  with a conflicting definition error.
- `lib.mkForce` on a whole attribute set replaces the aspect's value.

Example: include `git` but with Alice's identity, another editor, and no
commit signing:

```nix
{ den, lib, ... }:
{
  den.aspects.alice = {
    includes = [ den.aspects.git ];

    homeManager.programs.git.settings = {
      user = {
        name = lib.mkForce "Alice Example";
        email = lib.mkForce "alice@example.org";
      };
      core.editor = lib.mkForce "vim";
      commit.gpgSign = lib.mkForce false;
      tag.gpgSign = lib.mkForce false;

      # Not set by the aspect; merges without mkForce.
      pull.rebase = true;
    };
  };
}
```

When many values differ, move the personal parts of the aspect into user
concern files instead, and keep only the shared parts in the aspect.

To opt out of an aspect entirely, leave it out of `includes`. If it reaches
the user through the host, drop `den.batteries.host-aspects`.

## 6. Validate and activate

Inspect the result before switching:

```bash
nix flake check
nix eval --json .#darwinConfigurations.galadriel.config.home-manager.users.alice.programs.git.settings.user
```

Then activate the host:

```bash
scripts/darwin-switch-summary.sh --host galadriel
```

## Checklist

- [ ] macOS account exists and has logged in once.
- [ ] User listed under the host in `modules/flake/den-hosts.nix`.
- [ ] `modules/users/<user>.nix` created and staged with `git add`.
- [ ] Aspects reviewed for personal values; overrides use `lib.mkForce`.
- [ ] `nix flake check` passes.
- [ ] Host switched with `scripts/darwin-switch-summary.sh`.

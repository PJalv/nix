# NixOS configuration

Public NixOS and Home Manager flake for desktop, laptop, WSL, and standalone remote Home Manager profiles.

The repository is split into:

- public reusable NixOS modules, Home Manager modules, and package definitions
- a public-safe `private.template` flake with placeholder values
- an overridable private flake input for real host names, network topology, backup paths, and Git identity

## Outputs

```bash
nix flake show
```

Available public-safe outputs:

- `nixosConfigurations.desktop`
- `nixosConfigurations.laptop`
- `nixosConfigurations.wsl`
- `homeConfigurations.ubuntu`

## Remote Home Manager

On a multi-user Nix installation, configure the Numtide cache in the Nix daemon before the first build:

```bash
./users/remote/configure-nix-cache.sh
nix build .#homeConfigurations.ubuntu.activationPackage
./result/activate
```

Do not use `--max-jobs 0`. The agent packages come from the binary cache, but Home Manager must build small host-specific configuration files locally.

## Layout

```text
.
├── flake.nix                  # composition root
├── modules/                   # reusable NixOS modules
├── hm/                        # Home Manager modules
├── users/                     # system and HM profiles
├── pkgs/                      # local packages and patches
├── private.template/          # safe placeholder private flake interface
└── docs/private-flake.md      # private flake override guide
```

See `codemap.md` for the repository atlas.

## Private values

`inputs.private` defaults to `path:./private.template`, so the public tree can evaluate without access to a private repository.

For real machines, override it with a private flake:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private github:OWNER/nix-private
```

or with a local checkout:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private path:/home/user/src/nix-private
```

The private flake should provide:

- `nixosModules.default`
- `homeManagerModules.default`

See `docs/private-flake.md` and `private.template/` for the expected shape.

## Validation

```bash
nix fmt
nix flake check --no-build --override-input private path:$PWD/private.template
```

After `private.template` is tracked in git, plain `nix flake check --no-build` also works.

## Publishing note

Do not publish old git history if it contained private topology, identity, or local paths. For a public release, create a fresh branch/repository from the sanitized tree and make a new initial commit.

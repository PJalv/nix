# Installation notes

This repository is primarily a flake module set. For real deployment, provide private values with the `private` flake input.

## Public-safe evaluation

```bash
nix flake check --no-build --override-input private path:$PWD/private.template
```

## Apply a NixOS profile

Desktop:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private github:OWNER/nix-private
```

Laptop:

```bash
sudo nixos-rebuild switch --flake .#laptop \
  --override-input private github:OWNER/nix-private
```

WSL:

```bash
sudo nixos-rebuild switch --flake .#wsl \
  --override-input private github:OWNER/nix-private
```

Use a local private checkout instead of GitHub if desired:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private path:/home/user/src/nix-private
```

## Hardware configs

The checked-in hardware profiles are examples for the configured desktop/laptop layout. On a new machine, regenerate hardware configuration before deployment:

```bash
sudo nixos-generate-config --root / --no-hardware-config --dir /etc/nixos/users/primary/desktop
```

or:

```bash
sudo nixos-generate-config --root / --no-hardware-config --dir /etc/nixos/users/primary/laptop
```

If you do not want disk UUIDs public, move hardware profiles into the private flake and import them from `nixosModules.default`.

## Private flake

See `docs/private-flake.md` for the expected private repository interface and examples.

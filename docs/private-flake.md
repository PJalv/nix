# Private flake overlay

This repository is structured as a public NixOS/Home Manager configuration plus a private flake input.

The public repository keeps reusable module logic, packages, and safe defaults. The private flake supplies evaluation-time values that should not be published, such as:

- real host names
- internal DNS/IP mappings
- lab or home network topology
- backup source and destination paths
- Git author identity
- optional hardware profiles if you do not want disk UUIDs public

Runtime secrets such as API tokens, private keys, and passwords should use a secrets manager such as `sops-nix` or `agenix`; they should not be placed in either plaintext flake.

## Public-safe default

`flake.nix` points `inputs.private` at `path:./private.template`. This allows public evaluation to work without a private repository:

```nix
private = {
  url = "path:./private.template";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

## Real private repository shape

Create a private repository with the same interface:

```text
nix-private/
├── flake.nix
└── hosts/
    ├── desktop.nix
    ├── laptop.nix
    └── wsl.nix
```

Example `flake.nix`:

```nix
{
  description = "Private NixOS values";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {...}: {
    nixosModules.default = {machine ? "desktop", ...}: {
      imports = [./hosts/${machine}.nix];
    };

    homeManagerModules.default = {...}: {
      programs.git.settings = {
        user.name = "Your Name";
        user.email = "you@example.com";
      };
    };
  };
}
```

Example `hosts/desktop.nix`:

```nix
{username ? "user", ...}: {
  networking.hostName = "my-desktop";

  networking.hosts = {
    "192.0.2.10" = ["internal.example.invalid"];
  };

  services.piBackup = {
    enable = true;
    user = username;
    sourceDir = "/home/${username}/work/private-project";
    piHost = "backup-host.example.invalid";
    piUser = "backup";
    destRoot = "/srv/backups/my-desktop/private-project";
    timer.enable = false;
    excludes = [
      ".cache/"
      "node_modules/"
      "result"
      "result-*"
    ];
  };
}
```

## Using the private flake

Use the template defaults:

```bash
nix flake check
```

Override with a private GitHub flake for local deployment:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private github:OWNER/nix-private
```

Or keep a local private checkout outside the public repository:

```bash
sudo nixos-rebuild switch --flake .#desktop \
  --override-input private path:/home/user/src/nix-private
```

## Push safety

Do not publish existing git history if it ever contained private topology or identity. For a public release, create a fresh branch or fresh repository from the sanitized tree and make a new initial commit.

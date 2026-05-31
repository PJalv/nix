# pkgs/

## Responsibility

- Hosts Nix package definitions and package-local overlays/patches for this repo.
- Captures build-time adjustments that make upstream software fit the target system.

## Design Patterns/Structure

- One package directory per derivation, with `package.nix` as the build entrypoint.
- Local patch files live beside the derivation and are applied in `patches = [ ... ]`.
- Build logic is kept declarative: dependencies, substitutions, wrappers, and metadata are all encoded in the derivation.

## Data & Control Flow

- Source is fetched from upstream, patched locally, then built by the appropriate Nix builder.
- Build-time substitutions rewrite hardcoded paths or library lookups before compilation/install.
- Install hooks copy runtime assets into `$out`, rename binaries when needed, and wrap executables with required environment variables.

## Integration Points

- Integrates with upstream source archives and Git tags.
- Connects to system libraries, GUI stacks, and runtime tools through `buildInputs`, `nativeBuildInputs`, and wrapper prefixes.
- Exposes final package metadata (`meta`, `passthru`, update scripts) for consumption by the wider NixOS configuration.

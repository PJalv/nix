# pkgs/stremio-linux-shell/

## Responsibility

- Packages Stremio’s Linux desktop shell as a Rust/Nix derivation.
- Adapts upstream source so the app can run with Nix-store paths, bundled assets, and system libraries.

## Design Patterns/Structure

- `rustPlatform.buildRustPackage` drives the build; `fetchFromGitHub` pins the upstream release tag.
- Three local patches handle runtime behavior and platform compatibility:
  - `allow-local-network-access.patch` disables Chromium local network restrictions needed for Stremio server communication.
  - `fix-getshaderinfolog-call.patch` fixes the OpenGL shader log type on aarch64.
  - `better-server-path.patch` rewires server.js lookup to a fixed store path.
- `symlinkJoin` assembles the CEF directory layout Stremio expects.

## Data & Control Flow

- Source is fetched from GitHub, patched, then compiled with offline CEF fetching disabled.
- `postPatch` substitutes hardcoded library names and the `@serverjs@` placeholder with store paths.
- `postInstall` installs desktop/icon assets, stages `server.js` under `$out/share/stremio`, and renames the binary to `stremio`.
- `preFixup` wraps the executable to expose GL libraries, driver runpaths, and `nodejs` for `server.js` execution.

## Integration Points

- Depends on GTK/ATK/AppIndicator/xkbcommon/mpv/OpenSSL plus CEF binary resources.
- Uses `wrapGAppsHook4`, `makeBinaryWrapper`, and `versionCheckHook` for desktop/runtime integration.
- Integrates with Nix packaging metadata via `passthru.cef`, `updateScript`, `meta.mainProgram`, and Linux-only platform constraints.

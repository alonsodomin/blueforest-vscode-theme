# AGENTS.md

## Layout
- Nix flake monorepo of BlueForest theme ports. `apps/<app>/` is a self-contained flake; its `flake-module.nix` is both imported by the app flake and published as `flakeModules.default` for the root `flake.nix` to compose.
- Implemented apps: `apps/vscode` (VS Code/VSCodium extension) and `apps/bat` (TextMate theme). `apps/neovim` and `apps/starship` are placeholders (`README.md` + `VERSION` only) and are not root inputs.
- The VS Code extension is theme-only: `package.json` has no `main`, and there is no JS to build, test, or lint. Node and `vsce` are only for packaging.
- Theme files are hand-edited sources, not generated: `apps/vscode/themes/Blueforest-color-theme.json` and `apps/bat/themes/BlueForest.tmTheme`. Checks compare packaged copies against them.
- `README.md` is the consumer-facing contract (outputs, install snippets, identifiers). Update it when outputs or module behavior change.

## Verify
- Format: `nix fmt` (nixfmt, taplo, prettier for `*.json`, shfmt with tabs, shellcheck).
- Fast checks: `nix flake check` at the root (includes `treefmt`). Per app: `nix flake check ./apps/vscode`, `nix flake check ./apps/bat`. CI runs all three.
- Single check: `nix build .#checks.x86_64-linux.<name>`, where `<name>` is `version`, `treefmt`, `vscode-extension`, `vscode-configuration`, `bat-theme`, `bat-theme-home`, or `bat-theme-nixos`.
- The VSCodium integration check is intentionally absent from `nix flake check`. Run `BLUEFOREST_VSCODE_INTEGRATION_CHECK=1 nix flake check --impure` or `nix build .#vscode-integration-check` (expensive).
- Root flake evaluation only sees tracked files. `git add` new files before running `nix flake check` or `nix build .#...`.
- Shells: `nix develop` (root tools + `release`), `nix develop .#vscode` (nodejs/vsce; provides `package`, `nixfmt`).

## Versions and releases
- One shared version. `VERSION`, every `apps/*/VERSION`, and every `apps/*/package.json` must match (`tests/version.nix`). `apps/vscode` has no `VERSION` (package.json is its copy); the `neovim` and `starship` placeholder `VERSION` files do exist, so include them in manual bumps.
- Prefer the helper over hand-editing: `release vscode` from `nix develop`, or `nix run .#release -- vscode`. It is interactive, needs authenticated `gh` and network, pushes, and triggers CI; do not run it unattended.
- The helper discovers applications from `tools/lib/*.sh`, and only `vscode.sh` exists. `release bat` fails and `release all` currently releases only VS Code. Bat versions/changelogs are edited by hand and published by `release-bat.yml`.
- Changelogs: `apps/<app>/CHANGELOG.md`, newest section first, heading `## X.Y.Z - [DD-MM-YYYY]`. Root `CHANGELOG.md` links to the app changelogs and has an `Unreleased` section.
- Release workflows: `.github/workflows/release.yml` dispatches to `release-<app>.yml`; tags are `vscode/<version>`, `bat/<version>`.

## Conventions and traps
- Split licence: `apps/*/themes/**`, images, and `*.md` are CC BY 4.0; Nix, scripts, workflows, and manifests are MPL-2.0. New code/config files start with `# SPDX-License-Identifier: MPL-2.0`. `NOTICE.md` maps paths.
- Shell is bash and uses tabs (`treefmt.nix`: shfmt `indent_size = 0`, `simplify = false`); shellcheck must pass.
- Identifiers: theme ID `BlueForest`; extension ID `alonsodomin.blueforest-theme`; nixpkgs attr `blueforest-vscode-theme`; bat theme name `BlueForest`. Note the lowercase `f` in `Blueforest-color-theme.json`.
- The VS Code module exists twice and must stay in sync: the exported modules in `apps/vscode/flake-module.nix`, and the copy evaluated by `vscode-configuration` in `apps/vscode/nix/modules/default.nix` (which imports `nix/overlay.nix`). The comment in `default.nix` names the old `pkgs.blueforest-theme`; the real attr is `pkgs.blueforest-vscode-theme`.
- The VSIX build uses `vsce package --no-dependencies`; `.vscodeignore` decides what ships. Keep dev files out and add new runtime files explicitly. `*.vsix` is git-ignored.
- `.vscode/launch.json` still points at the old `vscode/` path; don't rely on F5. Use `code --extensionDevelopmentPath=$PWD/apps/vscode` or package the VSIX.
- Root aggregate modules are explicit: `flake.nix` currently composes only the VS Code overlay/modules in `overlays.default` and `{nixos,home}Modules.default`; bat ships packages/checks only.

## Adding an application
Mirror `apps/bat` (the simplest app): create `flake.nix`, `flake-module.nix`, `devshell.toml`, `VERSION`, `CHANGELOG.md`, and the theme. Then register it in root `flake.nix` (path input with `follows` + `inputs.<app>.flakeModule`), expose it in the root aggregate modules if it provides one, add it to the CI matrix in `.github/workflows/ci.yml`, add `tools/lib/<app>.sh`, add `.github/workflows/release-<app>.yml` plus a dispatch job/input in `release.yml`, and update `README.md`, root `CHANGELOG.md`, and `NOTICE.md`.

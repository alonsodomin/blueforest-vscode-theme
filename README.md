# Blueforest Theme

A dark blue theme inspired by the [Blueforest IntelliJ](https://github.com/sirthias/BlueForest) theme. It has been
optimised for syntax higlighting the following languages:

 * Groovy
 * Haskell
 * HTML
 * Java
 * Markdown
 * Python
 * Scala
 * C / C++
 * Bash
 * Powershell
 * JSON
 * XML / Html
 * Golang
 * GLSL
 * YAML

## Installing the theme with Nix

This repository is also a flake that provides the theme as a VS Code extension, together with a
module that makes it available to your configuration.

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-vscode-theme";

  outputs =
    { nixpkgs, blueforest, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          blueforest.nixosModules.default
          {
            programs.vscode = {
              enable = true;
              package = pkgs.vscodium;
              extensions = [
                pkgs.blueforest-theme
              ];
            };
          }
        ];
      };
    };
}
```

The module only adds the overlay that provides `pkgs.blueforest-theme`. It does not touch
`programs.vscode` or `programs.vscodium`, so which editor installs the theme, and whether it is
installed at all, stays your decision.

If you prefer to wire the overlay yourself:

```nix
nixpkgs.overlays = [ blueforest.overlays.default ];
```

The same module works for Home Manager as `blueforest.homeManagerModules.default`, where the
extension goes into the profile of the editor:

```nix
programs.vscodium.profiles.default.extensions = [
  pkgs.blueforest-theme
];
```

### Outputs

| Output                                                   | Description                                         |
| -------------------------------------------------------- | --------------------------------------------------- |
| `packages.<system>.blueforest-theme`                      | The theme as a VS Code extension package            |
| `overlays.default`                                        | Adds `pkgs.blueforest-theme` to a nixpkgs instance  |
| `nixosModules.default`, `homeManagerModules.default`       | Adds the overlay to `nixpkgs.overlays`              |
| `extensions.<system>.open-vsx.alonsodomin.blueforest-theme` | The same shape `nix-vscode-extensions` uses       |

### Identifiers

* The extension is `alonsodomin.blueforest-theme`.
* The theme inside the editor is `BlueForest`. Select it with `"workbench.colorTheme": "BlueForest"`.

### Checks

`nix flake check` runs the fast checks. The check that builds VSCodium is only run when it is
asked for:

```console
BLUEFOREST_WRAPPER_CHECK=1 nix flake check --impure
```

It can also be built on its own:

```console
nix build .#wrapper-check
```

The extension is built from the sources in this repository with `vsce`, the same tool the release
uses, so the version in `package.json` is the version that gets installed. `nix flake check`
verifies that the installed theme is identical to the one in `themes/`.

## Working with these sources

This repository comes with a Nix flake that sets up a development shell that comes with its own help menu regarding commands available. Simply run `nix develop` at the root of this repository and you'll see the following:

```bash
🔨 Welcome to blueforest

[[general commands]]

  menu    - prints this menu

[formatters]

  nixfmt  - Nix code formatter

[utilities]

  package - Build the .vsix extension package
  release - Interactive release helper
```

### Releases

Releases are managed by the tooling here, you can trigger a release by either running `nix run .#release` or by simply running `release` from the previously mentioned shell.
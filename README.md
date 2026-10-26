# Blueforest Theme

[![Mozilla Public License 2.0](https://img.shields.io/badge/MPL--2.0-blue?logo=mozilla&logoColor=white)](LICENSE)
[![Creative Commons Attribution 4.0 International](https://img.shields.io/badge/CC_BY_4.0-lightgrey?logo=creativecommons&logoColor=black)](LICENSES/CC-BY-4.0.txt)

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

The theme has a configuration for every tool it supports, and every
configuration lives in a directory of its own:

| Application | Directory  | Status                     |
| ----------- | ---------- | -------------------------- |
| VS Code     | `apps/vscode/`   | available                  |
| bat         | `apps/bat/`       | available                  |
| Neovim      | `apps/neovim/`   | planned                    |
| Starship    | `apps/starship/` | planned                    |

Every directory is self-contained: it holds the theme itself, the packaging of
it, the module that installs it and its own changelog. That way a consumer can
install just the configurations it cares about.

## Installing the theme with Nix

This repository is also a flake that provides the theme of every application,
together with modules that make them available to your configuration.

```nix
{
  inputs.blueforest.url = "github:alonsodomin/blueforest-theme";

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
                pkgs.blueforest-vscode-theme
              ];
            };
          }
        ];
      };
    };
}
```

The module only adds the overlay that provides `pkgs.blueforest-vscode-theme`. It does not touch
`programs.vscode` or `programs.vscodium`, so which editor installs the theme, and whether it is
installed at all, stays your decision.

If you prefer to wire the overlay yourself:

```nix
nixpkgs.overlays = [ blueforest.overlays.default ];
```

The same module works for Home Manager as `blueforest.homeModules.default`, where the
extension goes into the profile of the editor:

```nix
programs.vscodium.profiles.default.extensions = [
  pkgs.blueforest-vscode-theme
];
```

### Installing a single application

Every application is a flake of its own, so a consumer that only wants one of
them does not have to take the others:

```nix
{
  inputs.blueforest-vscode.url = "github:alonsodomin/blueforest-theme?dir=apps/vscode";

  outputs =
    { nixpkgs, blueforest-vscode, ... }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        modules = [
          blueforest-vscode.nixosModules.default
        ];
      };
    };
}
```

The same works for `?dir=apps/neovim` and `?dir=apps/starship` once they are written.

### Outputs

The root flake exposes the outputs of every application, together with the
combined ones:

| Output                                                     | Description                                            |
| ---------------------------------------------------------- | ------------------------------------------------------ |
| `packages.<system>.blueforest-vscode-theme`                | The theme as a VS Code extension package               |
| `packages.<system>.vscode-integration-check`               | The check that builds VSCodium                         |
| `packages.<system>.blueforest-bat-theme`                   | The theme for bat                                      |
| `overlays.default`                                          | Adds the packages of every application to a nixpkgs instance |
| `overlays.vscode`                                           | Adds `pkgs.blueforest-vscode-theme` to a nixpkgs instance |
| `nixosModules.default`, `homeModules.default`              | The modules of every application                       |
| `nixosModules.vscode`, `homeModules.vscode`                 | The module of the VS Code theme                        |
| `checks.<system>.<app>-<check>`                             | The checks of every application                        |
| `devShells.default`, `devShells.<app>`                     | The development shells of the repository and of every application |
| `extensions.<system>.open-vsx.alonsodomin.blueforest-theme`  | The same shape `nix-vscode-extensions` uses            |

The application flake exposes the same outputs, without the ones of the other
applications: `overlays.default`, `nixosModules.default` and
`homeModules.default` are the ones of the application itself. It also
publishes the module of the application, so that the root flake can compose
it:

| Output         | Description                                                |
| -------------- | ---------------------------------------------------------- |
| `flakeModule`  | The module of the application, for the root flake          |
| `flakeModules.default` | The same module, under the name of the convention   |

### Identifiers

* The package is `blueforest-vscode-theme`.
* The extension is `alonsodomin.blueforest-theme`.
* The theme inside the editor is `BlueForest`. Select it with `"workbench.colorTheme": "BlueForest"`.

### Checks

`nix flake check` runs the fast checks. The check that builds VSCodium is only run when it is
asked for:

```console
BLUEFOREST_VSCODE_INTEGRATION_CHECK=1 nix flake check --impure
```

It can also be built on its own:

```console
nix build .#vscode-integration-check
```

The extension is built from the sources in the `apps/vscode/` directory with `vsce`, the same tool the release
uses, so the version in `apps/vscode/package.json` is the version that gets installed. `nix flake check`
verifies that the installed theme is identical to the one in `apps/vscode/themes/`, and that every
application carries the version of the repository.

Every application can be checked on its own, the way a consumer that installs only one of them
gets it:

```console
nix flake check ./apps/vscode
nix flake check ./apps/bat
```

### The theme for bat

The theme of bat is a TextMate file, `BlueForest.tmTheme`, and it is packaged as
`blueforest-bat-theme`. The package installs it where bat looks for the themes — the
system-wide configuration directory `/etc/bat` when it is installed in a NixOS system, and the
configuration directory of the user (`bat --config-dir`) when it is installed in Home Manager —
and it does nothing else:

```nix
# NixOS
environment.systemPackages = [ blueforest.packages.${system}.blueforest-bat-theme ];

# Home Manager
home.packages = [ blueforest.packages.${system}.blueforest-bat-theme ];
```

Two things are left to the user: bat itself has to be enabled (`programs.bat.enable = true;`),
and the theme has to be selected (`programs.bat.settings.theme = "BlueForest";` on NixOS,
`programs.bat.config.theme = "BlueForest";` on Home Manager). The name of the theme is
`BlueForest`, the name of the file.

## Working with these sources

This repository comes with a Nix flake that sets up a development shell that comes with its own help menu regarding commands available. Simply run `nix develop` at the root of this repository and you'll see the following:

```bash
🔨 Welcome to blueforest

[[general commands]]

  menu    - prints this menu

[formatters]

  nixfmt  - Nix code formatter

[utilities]

  release - Interactive release helper
```

The development shell of an application comes with the tools that application is built with:

```console
nix develop .#vscode
```

### Releases

Releases are managed by the tooling here, you can trigger a release by either running `nix run .#release -- vscode` or by simply running `release vscode` from the previously mentioned shell.

The release helper takes the name of the application to release, or `all` for every application of
the repository:

```console
release vscode
release all
```

It asks for the version every application shares, for the changelog of each application, and then
commits, pushes and triggers the release workflow of the repository.

The workflow of the repository only dispatches: every application has a workflow of its own
(`.github/workflows/release-vscode.yml`), which is the one that packages and publishes it. A new
application brings a workflow of its own, and a job in `release.yml` that calls it.

## Adding an application

An application is a directory with the theme, the packaging of it and a flake of its own:

```
apps/neovim/
├── flake.nix            # the application as a flake of its own
├── flake-module.nix     # the application as a flake-parts module
├── devshell.toml        # the development shell of the application
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
└── ...
```

The module of the application describes what it provides: its packages, its
checks, its development shell, its overlay and its modules. The flake of the
application imports it and publishes it, so that the root flake can compose it:

```nix
# apps/neovim/flake.nix
outputs =
  inputs@{ flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (
    { config, lib, ... }:
    {
      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.devshell.flakeModule
        inputs.home-manager.flakeModules.home-manager
        ./flake-module.nix
      ];

      flake.flakeModules.default = ./flake-module.nix;
    }
  );
```

Registering it in the root flake is one input and one import, and the root flake then exposes it
on its own and together with the other applications:

```nix
inputs = {
  neovim = {
    url = "path:./apps/neovim";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.devshell.follows = "devshell";
    inputs.home-manager.follows = "home-manager";
  };
};

imports = [
  inputs.devshell.flakeModule
  inputs.home-manager.flakeModules.home-manager
  inputs.vscode.flakeModule
  inputs.neovim.flakeModule
];
```

The release of the application lives in `tools/lib/neovim.sh`, and its workflow in
`.github/workflows/release-neovim.yml`.

## License

The theme — the colour schemes in `apps/*/themes/`, the images and the documentation — is licensed
under the [Creative Commons Attribution 4.0 International licence][cc-by-4.0].

The code that packages it — the Nix expressions, the shell scripts, the CI workflows and the
manifests — is licensed under the [Mozilla Public License 2.0][mpl-2.0].

The theme is a port of [BlueForest][blueforest] by mathias[at]decodified[dot]com, which is licensed
under the [Creative Commons Attribution 3.0 Unported licence][cc-by-3.0]. [NOTICE.md](NOTICE.md)
carries the attribution of the original and the licence of every path in the repository.

[![CC BY 4.0][cc-by-image]][cc-by-4.0] [![MPL 2.0][mpl-image]][mpl-2.0]

[blueforest]: https://github.com/sirthias/BlueForest
[cc-by-3.0]: https://creativecommons.org/licenses/by/3.0/
[cc-by-4.0]: https://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by.svg
[mpl-2.0]: https://mozilla.org/MPL/2.0/
[mpl-image]: assets/mpl-2.0.svg

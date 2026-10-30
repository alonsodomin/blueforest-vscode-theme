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
| VS Code     | `modules/vscode/`   | available                  |
| bat         | `modules/bat/`       | available                  |
| Neovim      | `modules/neovim/`   | available                  |
| Starship    | `modules/starship/` | available                  |
| OpenCode    | `modules/opencode/` | available                  |
| sbt         | `modules/sbt/`      | available                  |

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
  inputs.blueforest-vscode.url = "github:alonsodomin/blueforest-theme?dir=modules/vscode";

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

The same works for `?dir=modules/starship`, `?dir=modules/opencode`,
`?dir=modules/sbt` and `?dir=modules/neovim`.

### Outputs

The root flake exposes the outputs of every application, together with the
combined ones:

| Output                                                     | Description                                            |
| ---------------------------------------------------------- | ------------------------------------------------------ |
| `packages.<system>.blueforest-vscode-theme`                | The theme as a VS Code extension package               |
| `packages.<system>.vscode-integration-check`               | The check that builds VSCodium                         |
| `packages.<system>.blueforest-bat-theme`                   | The theme for bat                                      |
| `packages.<system>.blueforest-starship-preset`             | The preset for Starship                                |
| `packages.<system>.blueforest-starship`                    | Starship with the preset bundled                       |
| `packages.<system>.blueforest-opencode-theme`              | The theme for OpenCode                                 |
| `packages.<system>.blueforest-sbt-prompt`                  | The prompt for sbt                                     |
| `packages.<system>.blueforest-neovim-theme`                | The theme for Neovim                                   |
| `overlays.default`                                          | Adds the packages of every application to a nixpkgs instance |
| `overlays.vscode`                                           | Adds `pkgs.blueforest-vscode-theme` to a nixpkgs instance |
| `overlays.starship`                                         | Adds `pkgs.blueforest-starship-preset` and `pkgs.blueforest-starship` to a nixpkgs instance |
| `overlays.opencode`                                         | Adds `pkgs.blueforest-opencode-theme` to a nixpkgs instance |
| `overlays.sbt`                                              | Adds `pkgs.blueforest-sbt-prompt` to a nixpkgs instance |
| `overlays.neovim`                                           | Adds `pkgs.blueforest-neovim-theme` to a nixpkgs instance |
| `nixosModules.default`, `homeModules.default`              | The modules of every application                       |
| `nixosModules.vscode`, `homeModules.vscode`                 | The module of the VS Code theme                        |
| `nixosModules.starship`, `homeModules.starship`             | The module of the Starship preset                      |
| `nixosModules.opencode`, `homeModules.opencode`             | The module of the OpenCode theme                       |
| `homeModules.sbt`                                           | The module of the sbt prompt                           |
| `nixosModules.neovim`, `homeModules.neovim`                 | The module of the Neovim theme                         |
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
* The Starship packages are `blueforest-starship-preset` and `blueforest-starship`.
* The Starship preset is `blueforest`. Select it with `programs.starship.presets = [ "blueforest" ];`.
* The OpenCode package is `blueforest-opencode-theme`.
* The theme inside OpenCode is `blueforest`, the name of the file. Select it with `programs.opencode.cli.theme = { name = "blueforest"; mode = "dark"; };`.
* The sbt package is `blueforest-sbt-prompt`. The module `blueforest.homeModules.sbt` installs it when `programs.sbt.enable = true`.
* The prompt is the `BlueforestTheme` of the [sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin. There is no option to select another theme: the module selects that one.
* The Neovim package is `blueforest-neovim-theme`.
* The theme inside Neovim is `blueforest`, the name of the file. Select it with `vim.cmd.colorscheme("blueforest")`.
* The theme of lualine is `blueforest` as well, and lualine finds it on its own.

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

The extension is built from the sources in the `modules/vscode/` directory with `vsce`, the same tool the release
uses, so the version in `modules/vscode/package.json` is the version that gets installed. `nix flake check`
verifies that the installed theme is identical to the one in `modules/vscode/themes/`, and that every
application carries the version of the repository. The Starship preset is compared with
`modules/starship/themes/blueforest.toml` and rendered with the actual `starship` binary. The theme of OpenCode is
compared with `modules/opencode/themes/blueforest.json`, checked to have every token OpenCode reads and every colour
of it resolved, and the configuration of the README is evaluated against Home Manager to see that the theme ends up
where OpenCode reads it and that the settings of the terminal select it. The theme of Neovim is compared with
`modules/neovim/themes/blueforest.lua`, and Neovim itself is run headless to see that it reads the theme and that
every colour of it is the one the repository has; lualine is run with it as well, to see that it finds the theme of
the statusline on its own. The prompt for sbt is checked to carry the plugin declaration and the theme selection, and
its Home Manager module is evaluated to see that it writes them where both generations of sbt read their global
configuration, and that it writes nothing when sbt is not enabled. The
overlay of the repository is applied to a nixpkgs instance, and the packages of every application are looked up in the
result, the way a consumer gets them.

Every application can be checked on its own, the way a consumer that installs only one of them
gets it:

```console
nix flake check ./modules/vscode
nix flake check ./modules/bat
nix flake check ./modules/starship
nix flake check ./modules/opencode
nix flake check ./modules/sbt
nix flake check ./modules/neovim
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

### The theme for Neovim

The theme is a plugin, so it is packaged as `blueforest-neovim-theme`. It carries the
colourscheme of Neovim and the theme of lualine, at the places both of them read them from:

```
colors/blueforest.lua
lua/lualine/themes/blueforest.lua
```

The Home Manager module adds it to the plugins of the editor:

```nix
{
  imports = [
    blueforest.homeModules.neovim
  ];

  programs.neovim.enable = true;
}
```

The module does not enable Neovim, so that the consumer decides whether the editor is
installed at all, and it does not select the colourscheme either: that is a line of the
configuration of the editor, and it belongs to the consumer:

```lua
vim.cmd.colorscheme("blueforest")
```

The theme of lualine needs no configuration at all: lualine looks its theme up by the name
of the colourscheme, and both are `blueforest`. The sections of the statusline are the
configuration of lualine, and the ones this theme was made with are:

```lua
require("lualine").setup({
  options = {
    theme = "blueforest",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "diagnostics" },
    lualine_x = { "filename" },
    lualine_y = { "filetype" },
    lualine_z = { "position" },
  },
})
```

The package carries the theme for the consumers that wire it by hand, or that do not use
Home Manager:

```nix
home.packages = [ pkgs.blueforest-neovim-theme ];
```

The NixOS module only adds the overlay: Neovim reads the configuration of the user, and
there is no system-wide directory it reads.

### The theme for Starship

The preset is `blueforest.toml`, named `blueforest` the way Starship names its presets, and it is
packaged twice:

- `blueforest-starship-preset` carries the preset at its root and in
  `share/starship/presets/blueforest.toml`, where Starship looks for its presets.
- `blueforest-starship` is Starship with the preset bundled, so that Home Manager can select it by
  name.

The overlay leaves `pkgs.starship` untouched. With the module applied, enable Starship and select
the bundled package and preset:

```nix
programs.starship = {
  enable = true;
  package = pkgs.blueforest-starship;
  presets = [ "blueforest" ];
};
```

If you only want the preset file, read it directly without replacing the Starship package:

```nix
programs.starship.settings = builtins.fromTOML (
  builtins.readFile "${pkgs.blueforest-starship-preset}/blueforest.toml"
);
```

The prompt uses Nerd Font glyphs, so the terminal needs a Nerd Font.

### The theme for OpenCode

The theme is `blueforest.json`, named `blueforest` the way OpenCode names a custom theme: the name of the
theme is the name of the file. It is the format OpenCode 2 reads, the tokens of the `base` and the palette of
the `dark` mode. It is a dark theme, so it defines that mode only, and OpenCode uses it when another one is
asked for.

The theme is part of the configuration of OpenCode, so the Home Manager module installs it:

```nix
{
  imports = [
    blueforest.homeModules.default
  ];

  programs.opencode.enable = true;
}
```

The module does not enable OpenCode: whether the program is installed at all stays your decision. It puts the
theme in `~/.config/opencode/themes/blueforest.json`, and selects it in `~/.config/opencode/cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "blueforest",
    "mode": "dark"
  }
}
```

Those are the settings of OpenCode 2, the ones `cli.json` holds. OpenCode 1 reads `tui.json` instead, and this
theme does not support it.

The package `blueforest-opencode-theme` carries the theme at its root and in `share/opencode/themes/`, for the
consumers that want the file itself, e.g. to put it in the themes directory of a project
(`.opencode/themes/`):

```nix
home.packages = [ pkgs.blueforest-opencode-theme ];
```

The NixOS module only adds the overlay: OpenCode reads the configuration of the user, and there is no
system-wide directory it reads.

### The prompt for sbt

The prompt is the `BlueforestTheme` of the
[sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin, which is where the prompt and the theme are defined.
This repository does not define the prompt: it installs the plugin and selects its theme.

The Home Manager module does it, and it does nothing unless sbt is enabled:

```nix
{
  imports = [
    blueforest.homeModules.sbt
  ];

  programs.sbt.enable = true;
}
```

It writes the plugin declaration and the theme selection into the global configuration of both generations of sbt,
because a consumer may run either of them:

| File | sbt 1.x | sbt 2.x |
| --- | --- | --- |
| Plugin | `~/.sbt/1.0/plugins/sbt-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/plugins/sbt-prompt.sbt` |
| Theme | `~/.sbt/1.0/blueforest-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/blueforest-prompt.sbt` |

The sbt 1 paths are relative to `programs.sbt.baseUserConfigPath` (`.sbt` by default), and the sbt 2 paths follow the
XDG base directory specification.

The package `blueforest-sbt-prompt` carries the same files for consumers that wire them by hand. Adding it to
`home.packages` alone is not enough: Home Manager does not copy the files into the configuration of sbt. The module is
the supported way to install them.

There is no NixOS module: sbt reads the configuration of the user, and there is no system-wide directory it reads.

There is nothing to release here: the prompt and its theme are provided by the upstream plugin, so this application has
no release workflow.

The prompt uses true colour and Nerd Font glyphs, so the terminal has to support both.

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
nix develop .#starship
nix develop .#opencode
nix develop .#sbt
nix develop .#neovim
```

### Releases

Releases are managed by the tooling here, you can trigger a release by either running `nix run .#release -- vscode` or by simply running `release vscode` from the previously mentioned shell.

The release helper takes the name of the application to release, or `all` for every application that
has a release script (`vscode`, `starship`, `opencode` and `neovim`):

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
modules/neovim/
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
# modules/neovim/flake.nix
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
    url = "path:./modules/neovim";
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

The theme — the colour schemes in `modules/*/themes/`, the images and the documentation — is licensed
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

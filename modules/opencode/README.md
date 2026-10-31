# BlueForest theme for OpenCode

The theme is `themes/blueforest.json`, named `blueforest` the way OpenCode
names a custom theme: the name of the theme is the name of the file.

The theme is the one OpenCode 2 reads: the tokens of the `base`, shared by
every mode, and the palette of the `dark` mode. It is a dark theme, so it
defines that mode only, and OpenCode uses it when another one is asked for.

The palette has a hue for every colour the theme uses: the neutrals, the
blues of the keywords, the greens of the strings, the ambers of the operators,
the reds of the numbers, and the yellows of the variables and of the emphasis.
The two yellows of BlueForest are the pale one of the variables and the vivid
one of the constants, and the hue carries both of them, together with the
golds the other ports of the theme use for their headings and their status
bars.

A theme OpenCode cannot read is a theme OpenCode ignores: it falls back to
the theme it ships with, without a word. That is why the checks of this
application make sure that the theme has every token OpenCode reads, and that
every colour of it that is a reference resolves.

The package `blueforest-opencode-theme` carries the theme at its root and in
`share/opencode/themes/`, which is where OpenCode looks for the themes.

## Installing the theme

The theme is part of the configuration of OpenCode, so Home Manager installs
it with the program:

```nix
programs.opencode.enable = true;
```

and the module of this application adds the theme and selects it:

```nix
{
  imports = [
    blueforest.homeModules.default
  ];
}
```

The module does not enable OpenCode, so that the consumer decides whether the
program is installed at all.

The theme ends up in `~/.config/opencode/themes/blueforest.json`, and the
settings that select it in `~/.config/opencode/cli.json`:

```json
{
  "$schema": "https://opencode.ai/v2/cli.json",
  "theme": {
    "name": "blueforest",
    "mode": "dark"
  }
}
```

Both are the options of OpenCode 2, the ones `cli.json` holds. OpenCode 1
reads `tui.json` instead, and this theme does not support it.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
modules/opencode/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging of the theme
└── themes/              # the theme itself
```

The application is registered in the root flake, as an input:

```nix
opencode = {
  url = "path:./modules/opencode";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
  inputs.home-manager.follows = "home-manager";
};
```

and its module is imported by the root flake:

```nix
imports = [
  inputs.home-manager.flakeModules.home-manager
  inputs.vscode.flakeModule
  inputs.opencode.flakeModule
];
```

The root flake then exposes it on its own and together with the other
applications:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `nixosModules.opencode`     | the module of this application       |
| `nixosModules.default`    | the modules of every application     |
| `homeModules.opencode`     | the module of this application       |
| `homeModules.default`    | the modules of every application     |
| `overlays.opencode`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The overlay leaves `pkgs.opencode` alone: the theme is a package of its own,
so that applying the overlay does not replace the OpenCode of a configuration
that does not want the theme.

The NixOS module adds the overlay and nothing else: OpenCode reads the
configuration of the user, and there is no system-wide directory it reads.

The release of the application lives in `tools/lib/opencode.sh`, and its
workflow in `.github/workflows/release-opencode.yml`.

See the root [README](../../README.md) for the installation of the flake and
the modules.

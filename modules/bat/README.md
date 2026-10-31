# BlueForest theme for bat

The theme is `themes/BlueForest.tmTheme`, a TextMate file, the format bat reads. The name of the
theme is the name of the file: `BlueForest`.

The colours are the ones of BlueForest: the dark blue of the background, the vivid blue of the
keywords, the green of the strings, the amber of the operators, the red of the numbers, and the
pale yellow of the variables.

The package `blueforest-bat-theme` carries the theme at `share/bat/themes/BlueForest.tmTheme`,
which is where bat looks for the themes of the system-wide configuration directory, and a setup
hook that puts it there: `/etc/bat` when the hook runs as root, which is what the activation of a
NixOS system does, and the configuration directory of the user otherwise, which is what Home
Manager does in the session of the user.

## Installing the theme

The theme is a package, and it does no more than putting the theme where bat looks for it:

```nix
# NixOS
environment.systemPackages = [ blueforest.packages.${system}.blueforest-bat-theme ];

# Home Manager
home.packages = [ pkgs.blueforest-bat-theme ];
```

Two things are left to the user: bat itself has to be enabled (`programs.bat.enable = true;`),
and the theme has to be selected (`programs.bat.settings.theme = "BlueForest";` on NixOS,
`programs.bat.config.theme = "BlueForest";` on Home Manager). The name of the theme is
`BlueForest`, the name of the file.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
modules/bat/
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
bat = {
  url = "path:./modules/bat";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
};
```

and its module is imported by the root flake:

```nix
imports = [
  inputs.flake-parts.flakeModules.flakeModules
  inputs.vscode.flakeModule
  inputs.bat.flakeModule
];
```

The application ships a package and its checks, and nothing else: it has no overlay and no
module, so the consumer that wants the theme takes it from the outputs of the flake:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `tools/lib/bat.sh`, and its workflow in
`.github/workflows/release-bat.yml`.

See the root [README](../../README.md) for the installation of the flake and
the modules.

# BlueForest theme for VS Code

The theme is `themes/Blueforest-color-theme.json`, a colour theme, the format VS Code reads. The
name of the theme inside the editor is `BlueForest`, the identifier of the extension.

The colours are the ones of BlueForest: the dark blue of the background, the vivid blue of the
keywords, the green of the strings, the amber of the operators, the red of the numbers, and the
pale yellow of the variables.

The package `blueforest-vscode-theme` is the theme as a VS Code extension, built with `vsce`,
the same tool the release uses.

## Installing the theme

The module of this application adds the overlay that provides `pkgs.blueforest-vscode-theme`, and
nothing else: which editor installs the theme, and whether it is installed at all, stays your
decision.

```nix
{
  imports = [
    blueforest.homeModules.default
  ];

  programs.vscodium.profiles.default.extensions = [
    pkgs.blueforest-vscode-theme
  ];
}
```

The theme is then selected with `"workbench.colorTheme": "BlueForest"`.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
modules/vscode/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── package.json         # the manifest of the extension
├── .vscodeignore        # the files the extension does not ship
├── icon.png             # the icon of the extension
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging of the extension
└── themes/              # the theme itself
```

The application is registered in the root flake, as an input:

```nix
vscode = {
  url = "path:./modules/vscode";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
  inputs.home-manager.follows = "home-manager";
};
```

and its module is imported by the root flake:

```nix
imports = [
  inputs.flake-parts.flakeModules.flakeModules
  inputs.home-manager.flakeModules.home-manager
  inputs.vscode.flakeModule
];
```

The root flake then exposes it on its own and together with the other
applications:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `nixosModules.vscode`     | the module of this application       |
| `nixosModules.default`    | the modules of every application     |
| `homeModules.vscode`      | the module of this application       |
| `homeModules.default`     | the modules of every application     |
| `overlays.vscode`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `tools/lib/vscode.sh`, and its workflow in
`.github/workflows/release-vscode.yml`.

See the root [README](../../README.md) for the installation of the flake and
the modules.

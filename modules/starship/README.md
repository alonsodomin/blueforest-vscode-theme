# BlueForest theme for Starship

The preset is `themes/blueforest.toml`, named `blueforest` the way Starship
names its presets.

The package `blueforest-starship-preset` carries the preset at its root and in
`share/starship/presets/`, which is where Starship looks for the presets that
`programs.starship.presets` reads. `blueforest-starship` is Starship with the
preset bundled.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
modules/starship/
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
starship = {
  url = "path:./modules/starship";
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
  inputs.starship.flakeModule
];
```

The root flake then exposes it on its own and together with the other
applications:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `nixosModules.starship`     | the module of this application       |
| `nixosModules.default`    | the modules of every application     |
| `homeModules.starship`     | the module of this application       |
| `homeModules.default`    | the modules of every application     |
| `overlays.starship`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The overlay leaves `pkgs.starship` alone: the Starship with the preset
bundled is a package of its own, so that applying the overlay does not
replace the Starship of a configuration that does not want the theme.

The release of the application lives in `tools/lib/starship.sh`, and its
workflow in `.github/workflows/release-starship.yml`.

See the root [README](../../README.md) for the installation of the flake and
the modules.

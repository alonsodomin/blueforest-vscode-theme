# BlueForest theme for Starship

This directory will hold the Starship configuration of the BlueForest theme.
It is not written yet; the directory is here so that the layout of the
repository is settled before the first theme is.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
apps/starship/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── devshell.toml        # the development shell of the application
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
└── blueforest.toml      # the theme itself
```

The application is registered in the root flake, as an input:

```nix
starship = {
  url = "path:./apps/starship";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
  inputs.devshell.follows = "devshell";
  inputs.home-manager.follows = "home-manager";
};
```

and its module is imported by the root flake:

```nix
imports = [
  inputs.devshell.flakeModule
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
| `overlays.starship`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `tools/lib/starship.sh`, and its
workflow in `.github/workflows/release-starship.yml`.

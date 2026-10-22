# BlueForest theme for Neovim

This directory will hold the Neovim configuration of the BlueForest theme.
It is not written yet; the directory is here so that the layout of the
repository is settled before the first theme is.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
apps/neovim/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── devshell.toml        # the development shell of the application
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
└── lua/                 # the theme itself
```

The module of the application describes what it provides: its packages, its
checks, its development shell, its overlay and its modules. The flake of the
application imports it and publishes it, so that the root flake can compose
it.

The application is registered in the root flake, as an input:

```nix
neovim = {
  url = "path:./apps/neovim";
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
  inputs.neovim.flakeModule
];
```

The root flake then exposes it on its own and together with the other
applications:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `nixosModules.neovim`     | the module of this application       |
| `nixosModules.default`    | the modules of every application     |
| `overlays.neovim`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `tools/lib/neovim.sh`, and its
workflow in `.github/workflows/release-neovim.yml`.

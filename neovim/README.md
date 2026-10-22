# BlueForest theme for Neovim

This directory will hold the Neovim configuration of the BlueForest theme.
It is not written yet; the directory is here so that the layout of the
repository is settled before the first theme is.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
neovim/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── nix/
│   ├── outputs.nix      # the outputs of the application
│   ├── overlay.nix      # adds `pkgs.blueforest-neovim` to a nixpkgs instance
│   └── modules/
│       └── default.nix  # the module that adds the overlay
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── devshell.toml        # the tools this application is developed with
└── lua/                 # the theme itself
```

The application is registered in the root flake, in `appOutputs`:

```nix
appOutputs = {
  vscode = import ./vscode/nix/outputs.nix { … };
  neovim = import ./neovim/nix/outputs.nix { … };
};
```

The root flake then exposes it on its own and together with the other
applications:

| Output                    | Description                          |
| ------------------------- | ------------------------------------ |
| `nixosModules.neovim`     | the module of this application       |
| `nixosModules.default`    | the modules of every application     |
| `overlays.neovim`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `scripts/lib/neovim.sh`, and its
workflow in `.github/workflows/release-neovim.yml`.

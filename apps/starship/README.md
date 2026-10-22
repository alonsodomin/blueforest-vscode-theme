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
├── nix/
│   ├── outputs.nix      # the outputs of the application
│   ├── overlay.nix      # adds `pkgs.blueforest-starship` to a nixpkgs instance
│   └── modules/
│       └── default.nix  # the module that adds the overlay
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── devshell.toml        # the tools this application is developed with
└── blueforest.toml      # the theme itself
```

The application is registered in the root flake, in `appOutputs`:

```nix
appOutputs = {
  vscode = import ./apps/vscode/nix/outputs.nix { … };
  starship = import ./apps/starship/nix/outputs.nix { … };
};
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

# Change Log

All notable changes to the BlueForest theme will be documented in this file.

The theme has a configuration for several tools, and every configuration has
its own changelog:

| Application | Changelog                                  |
| ----------- | ------------------------------------------ |
| VS Code    | [modules/vscode/CHANGELOG.md](modules/vscode/CHANGELOG.md) |
| bat        | [modules/bat/CHANGELOG.md](modules/bat/CHANGELOG.md) |
| Starship   | [modules/starship/CHANGELOG.md](modules/starship/CHANGELOG.md) |

Every configuration of the repository shares one version, which lives in
[VERSION](VERSION).

## Unreleased

- The configurations of the theme are licensed under CC BY 4.0 International,
  and the code that packages them under MPL-2.0
- The BlueForest theme now includes a Starship preset, packaged as
  `blueforest-starship-preset` and `blueforest-starship`
- The overlay of the repository adds the packages of every application again:
  it was composed by hand, which lost one of the two arguments an overlay
  takes, and it did not add anything

## 0.4.0 - [22-10-2026]

- The repository holds a configuration of the theme per application, each of
  them in a directory of its own
- The applications are flakes of their own, which publish a module that the
  root flake composes
- The Home Manager modules are now called `homeModules`, the way Home Manager
  calls them

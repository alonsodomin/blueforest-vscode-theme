# Change Log

All notable changes to the BlueForest theme will be documented in this file.

The theme has a configuration for several tools, and every configuration has
its own changelog:

| Application | Changelog                                  |
| ----------- | ------------------------------------------ |
| VS Code    | [apps/vscode/CHANGELOG.md](apps/vscode/CHANGELOG.md) |
| bat        | [apps/bat/CHANGELOG.md](apps/bat/CHANGELOG.md) |

Every configuration of the repository shares one version, which lives in
[VERSION](VERSION).

## 0.4.0 - [22-10-2026]

- The repository holds a configuration of the theme per application, each of
  them in a directory of its own
- The applications are flakes of their own, which publish a module that the
  root flake composes
- The Home Manager modules are now called `homeModules`, the way Home Manager
  calls them

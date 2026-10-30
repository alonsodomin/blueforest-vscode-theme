# Change Log

All notable changes to the BlueForest theme will be documented in this file.

The theme has a configuration for several tools, and every configuration has
its own changelog:

| Application | Changelog                                  |
| ----------- | ------------------------------------------ |
| VS Code    | [modules/vscode/CHANGELOG.md](modules/vscode/CHANGELOG.md) |
| bat        | [modules/bat/CHANGELOG.md](modules/bat/CHANGELOG.md) |
| Neovim     | [modules/neovim/CHANGELOG.md](modules/neovim/CHANGELOG.md) |
| Starship   | [modules/starship/CHANGELOG.md](modules/starship/CHANGELOG.md) |
| OpenCode   | [modules/opencode/CHANGELOG.md](modules/opencode/CHANGELOG.md) |
| sbt        | [modules/sbt/CHANGELOG.md](modules/sbt/CHANGELOG.md) |

Every configuration of the repository shares one version, which lives in
[VERSION](VERSION).

## Unreleased

- The configurations of the theme are licensed under CC BY 4.0 International,
  and the code that packages them under MPL-2.0
- The BlueForest theme now includes a Starship preset, packaged as
  `blueforest-starship-preset` and `blueforest-starship`
- The BlueForest theme now includes a theme for OpenCode, packaged as
  `blueforest-opencode-theme`. It is the format OpenCode 2 reads, and the
  Home Manager module selects it through the settings of the terminal
- The BlueForest theme now includes a prompt for sbt, packaged as
  `blueforest-sbt-prompt`. It installs the
  [sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin and selects
  its `BlueforestTheme`, which is defined upstream
- The BlueForest theme now includes a theme for Neovim, packaged as
  `blueforest-neovim-theme`. It is a plugin that carries the colourscheme of
  Neovim and the theme of lualine, and the Home Manager module adds it to the
  plugins of the editor
- The theme for OpenCode has a yellow hue for the variables and the emphasis,
  and the categorical palette of the agents counts it
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

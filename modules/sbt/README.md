# BlueForest prompt for sbt

The prompt is the one of the
[sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin, which is where
the prompt and its `BlueforestTheme` are defined. This directory does not
define the prompt: it installs the plugin and selects its theme.

The plugin is declared as:

```scala
addSbtPlugin("com.github.alonsodomin" % "sbt-prompt" % "3.0.0")
```

and the prompt is selected with:

```scala
import com.github.alonsodomin.sbt.prompt.SbtPrompt.autoImport._

promptTheme := BlueforestTheme
```

The theme is `PromptThemes.BlueforestTheme` in the upstream repository, and the
example is `examples/blueforest-theme/build.sbt`. See the
[sbt-prompt repository](https://github.com/alonsodomin/sbt-prompt) for the
prompt and the theme themselves.

The prompt uses true colour and Nerd Font glyphs, so the terminal has to
support both.

## Installing the prompt

The Home Manager module installs the two files in the global configuration of
sbt:

```nix
{
  imports = [
    blueforest.homeModules.sbt
  ];

  programs.sbt.enable = true;
}
```

The module does not enable sbt: it only adds the files when
`programs.sbt.enable` is true. It writes both generations of sbt, because a
consumer may run either of them:

| File | sbt 1.x | sbt 2.x |
| --- | --- | --- |
| Plugin | `~/.sbt/1.0/plugins/sbt-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/plugins/sbt-prompt.sbt` |
| Theme | `~/.sbt/1.0/blueforest-prompt.sbt` | `$XDG_CONFIG_HOME/sbt/2/blueforest-prompt.sbt` |

The sbt 1 paths are relative to `programs.sbt.baseUserConfigPath`, which is
`.sbt` by default. The sbt 2 paths follow the XDG base directory
specification, and Home Manager uses `~/.config` when `XDG_CONFIG_HOME` is not
set.

The package `blueforest-sbt-prompt` carries the same files for consumers that
wire them by hand:

```nix
home.packages = [ pkgs.blueforest-sbt-prompt ];
```

Adding the package alone is not enough: Home Manager does not copy the files
into the global configuration of sbt. The module is the supported way to
install them. The package exposes them under `share/sbt/`, in the layout of the
global configuration of sbt:

```
share/sbt/plugins/sbt-prompt.sbt
share/sbt/blueforest-prompt.sbt
```

There is no NixOS module: sbt reads the configuration of the user, and there is
no system-wide directory it reads.

## Releasing

There is nothing to release here: the prompt and its theme come from the
[sbt-prompt](https://github.com/alonsodomin/sbt-prompt) plugin. This directory
only carries the files that install and select them, so it has no release
workflow of its own.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer can
install just one of them:

```
modules/sbt/
├── flake.nix            # the application as a flake of its own
├── flake-module.nix     # the application as a flake-parts module
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the prompt
├── config/              # the plugin declaration and the theme selection
└── nix/                 # the packaging, the module and their checks
```

## Checks

```console
nix flake check ./modules/sbt
```

`nix flake check ./modules/sbt` checks that the package carries the files of
`config/`, that the plugin declaration and the theme selection are the ones
above, and that the Home Manager module installs the files where both
generations of sbt read them, and only when sbt is enabled.

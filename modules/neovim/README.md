# BlueForest theme for Neovim

The theme is `themes/blueforest.lua`, the colourscheme of Neovim: the name of
the theme is the name of the file, and `:colorscheme blueforest` loads it.

The theme is `themes/lualine-blueforest.lua` as well: lualine reads a table of
colours rather than a colourscheme, so the palette of the theme is written
down for it a second time. The name of that theme is `blueforest` too, and
lualine finds it on its own: the `auto` theme of lualine looks the theme up by
the name of the colourscheme, which is `blueforest` as well.

The colours are the ones of BlueForest: the dark blue of the background, the
vivid blue of the keywords, the green of the strings, the amber of the
operators, the red of the numbers, and the pale yellow of the variables. The
theme describes the groups of Neovim, the captures of Tree-sitter, the
diagnostics of the language servers, the signs of Git, and the groups of the
plugins that are common enough to be worth a colour: Telescope, the git signs,
the buffer line, Noice, Snacks, blink.cmp, the indent blankline, and the rest.

It also describes the seven groups of the rainbow delimiters, one for each
level of nesting. The plugin paints the delimiters of a buffer with the groups
it is told to use, and it reads their colours from the colourscheme, so a
group that the theme does not define leaves the rainbow without a colour.

## Installing the theme

The theme is a plugin, so it goes into the plugins of Neovim, and the Home
Manager module of this application adds it there:

```nix
{
  imports = [
    blueforest.homeModules.neovim
  ];

  programs.neovim.enable = true;
}
```

The module does not enable Neovim, so that the consumer decides whether the
editor is installed at all. It does not select the colourscheme either: that
is a line of the configuration of the editor, and it belongs to the consumer:

```lua
vim.cmd.colorscheme("blueforest")
```

The theme ends up in the directory of the runtimepath where Neovim reads a
colourscheme from, and where lualine reads its theme from:

```
~/.local/share/nvim/site/pack/hm/start/blueforest-neovim-theme/
├── colors/blueforest.lua
└── lua/lualine/themes/blueforest.lua
```

The package `blueforest-neovim-theme` carries the same files, for the
consumers that wire them by hand, or that do not use Home Manager:

```nix
home.packages = [ pkgs.blueforest-neovim-theme ];
```

The overlay leaves `pkgs.neovim` alone: the theme is a package of its own, so
that applying the overlay does not replace the Neovim of a configuration that
does not want the theme.

The NixOS module adds the overlay and nothing else: Neovim reads the
configuration of the user, and there is no system-wide directory it reads.

## The statusline

The theme of lualine is found on its own, so lualine needs no configuration at
all to paint the statusline with it. The sections of the statusline are the
configuration of lualine, though, and the ones this theme was made with are:

```lua
require("lualine").setup({
  options = {
    theme = "blueforest",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "diagnostics" },
    lualine_x = { "filename" },
    lualine_y = { "filetype" },
    lualine_z = { "position" },
  },
})
```

## The theme in nixvim

[nixvim](https://github.com/nix-community/nixvim) reads its configuration in its own module
system, and it builds an instance of nixpkgs of its own, so the overlay of the consumer does
not reach it. The theme is therefore installed by a module of nixvim, which is imported into
the configuration of nixvim:

```nix
{
  imports = [
    nixvim.nixosModules.default   # or nixvim.homeModules.default
  ];

  programs.nixvim = {
    imports = [ blueforest.nixvimModules.neovim ];
    enable = true;
  };
}
```

The module adds the overlay of the theme to the nixpkgs of nixvim, installs the theme among
the plugins of the editor, and selects the colourscheme. The consumer can select another
colourscheme: the module only offers the one of the theme as the default.

The pin of nixvim belongs to the repository, so that the check of the application is not at the
mercy of the release cycle of nixvim. This application, used on its own, keeps its own pin of
it, in `flake.lock`.

## What an application directory holds

Every application of this repository is self-contained, so that a consumer
can install just one of them:

```
modules/neovim/
├── flake.nix            # the application as a flake of its own
├── flake.lock
├── flake-module.nix     # the application as a flake-parts module
├── devshell.toml        # the development shell of the application
├── VERSION              # the version of the application
├── CHANGELOG.md         # the changes of the application
├── NOTICE.md            # the attribution of the theme
├── nix/                 # the packaging of the theme
└── themes/              # the theme itself
```

The application is registered in the root flake, as an input:

```nix
neovim = {
  url = "path:./modules/neovim";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-parts.follows = "flake-parts";
  inputs.devshell.follows = "devshell";
  inputs.home-manager.follows = "home-manager";
  inputs.nixvim.follows = "nixvim";
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
| `homeModules.neovim`      | the module of this application       |
| `homeModules.default`     | the modules of every application     |
| `nixvimModules.neovim`    | the module of this application, for nixvim |
| `overlays.neovim`         | the overlay of this application      |
| `packages.<system>.*`     | the packages of this application     |

The release of the application lives in `tools/lib/neovim.sh`, and its
workflow in `.github/workflows/release-neovim.yml`.

See the root [README](../../README.md) for the installation of the flake and
the modules.

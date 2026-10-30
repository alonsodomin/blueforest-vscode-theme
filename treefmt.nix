# SPDX-License-Identifier: MPL-2.0
#
# The formatting of the repository.
#
# The configuration lives here, and the root flake only points treefmt-nix at
# it. The formatter and the check that verifies the formatting come with the
# module.
{
  settings.on-unmatched = "info";

  programs.nixfmt.enable = true;

  programs.taplo.enable = true;

  # The Lua sources of the themes. The settings are the ones of LazyVim, which
  # the theme of Neovim is written for.
  programs.stylua = {
    enable = true;

    settings = {
      indent_type = "Spaces";
      indent_width = 2;
      column_width = 120;
      sort_requires.enabled = true;
    };
  };

  programs.prettier = {
    enable = true;

    # Only the JSON files of the repository are formatted.
    includes = [ "*.json" ];

    # .vscode/launch.json is JSONC (it has comments), which prettier cannot
    # parse as json.
    excludes = [ ".vscode/**" ];
  };

  programs.shfmt = {
    enable = true;

    # The scripts of the repository are indented with tabs.
    indent_size = 0;
  };

  # shellcheck exits non-zero on findings, which makes treefmt fail the run.
  programs.shellcheck = {
    enable = true;

    excludes = [ ".envrc" ];
  };
}

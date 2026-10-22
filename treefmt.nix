# The formatting of the repository.
#
# The configuration lives here, and the root flake only points treefmt-nix at
# it. The formatter and the check that verifies the formatting come with the
# module.
{
  settings.on-unmatched = "info";

  programs.nixfmt.enable = true;

  programs.taplo.enable = true;

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

    # The scripts are written the way they are, without the simplifications
    # of shfmt.
    simplify = false;
  };

  # shellcheck exits non-zero on findings, which makes treefmt fail the run.
  programs.shellcheck.enable = true;
}

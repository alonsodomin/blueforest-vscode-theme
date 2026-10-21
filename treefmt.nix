{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  settings.on-unmatched = "info";

  programs.nixfmt.enable = true;

  programs.taplo.enable = true;
  settings.formatter.taplo = {
    options = [ "format" ];
    includes = [ "*.toml" ];
  };

  programs.prettier.enable = true;
  settings.formatter.prettier = {
    options = [ "--write" ];
    # .vscode/launch.json is JSONC (it has comments), which prettier cannot parse as json.
    excludes = [ ".vscode/**" ];
    includes = [ "*.json" ];
  };

  programs.shfmt.enable = true;
  # -w is required: without it shfmt writes to stdout and treefmt would
  # silently report no change.
  settings.formatter.shfmt = {
    options = [ "-w" ];
    includes = [ "*.sh" ];
  };

  programs.shellcheck = {
    enable = true;
    package = pkgs.shellcheck-minimal;
  };
  # shellcheck exits non-zero on findings, which makes treefmt fail the run.
  settings.formatter.shellcheck = {
    includes = [ "*.sh" ];
  };
}

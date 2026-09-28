{
  on-unmatched = "info";

  formatter.nixfmt = {
    command = "nixfmt";
    includes = [ "*.nix" ];
  };

  formatter.taplo = {
    command = "taplo";
    options = [ "format" ];
    includes = [ "*.toml" ];
  };

  formatter.prettier = {
    command = "prettier";
    options = [ "--write" ];
    # .vscode/launch.json is JSONC (it has comments), which prettier cannot parse as json.
    excludes = [ ".vscode/**" ];
    includes = [ "*.json" ];
  };

  # -w is required: without it shfmt writes to stdout and treefmt would
  # silently report no change.
  formatter.shfmt = {
    command = "shfmt";
    options = [ "-w" ];
    includes = [ "*.sh" ];
  };

  # shellcheck exits non-zero on findings, which makes treefmt fail the run.
  formatter.shellcheck = {
    command = "shellcheck";
    includes = [ "*.sh" ];
  };
}

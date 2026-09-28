{
  description = "BlueForest VS Code theme - packaging devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      devshell,
      ...
    }:
    let
      # x86_64-darwin is omitted on purpose: nixpkgs 26.11 dropped it.
      supportedSystems = [
        flake-utils.lib.system.x86_64-linux
        flake-utils.lib.system.aarch64-linux
        flake-utils.lib.system.aarch64-darwin
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };

        devShell = pkgs.devshell.fromTOML ./devshell.toml;

        releaseTool = pkgs.writeShellApplication {
          name = "release";
          # scripts/release.sh stays the single source of truth; the wrapper
          # only supplies a hermetic PATH with the tools the script needs.
          text = ''exec ${./scripts/release.sh} "$@"'';
          inheritPath = false;
          runtimeInputs = [
            pkgs.coreutils
            pkgs.gawk
            pkgs.gnused
            pkgs.gnugrep
            pkgs.git
            pkgs.curl
            pkgs.jq
            pkgs.gh
          ];
        };
        treefmt = pkgs.treefmt.withConfig {
          name = "treefmt";
          settings.imports = [ ./treefmt.nix ];
          runtimeInputs = [
            pkgs.nixfmt
            pkgs.taplo
            pkgs.prettier
            pkgs.shfmt
            pkgs.shellcheck-minimal
          ];
        };
      in
      {
        devShells.default = devShell;
        packages.default = devShell;
        apps.default = devShell.flakeApp // {
          meta.description = "BlueForest packaging devshell";
        };
        apps.release = {
          type = "app";
          program = "${releaseTool}/bin/release";
          meta.description = "Interactive release helper";
        };
        formatter = treefmt;
        # Fails if any file is not formatted. Because a non-zero exit from a
        # linter (shellcheck) aborts treefmt, this also fails when a linter
        # reports an error.
        checks.formatting = treefmt.check ./.;
      }
    );
}

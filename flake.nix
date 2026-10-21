{
  description = "BlueForest VS Code theme - packaging devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      devshell,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devshell.flakeModule
        treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = { system, ... }: {
        treefmt.imports = [ ./treefmt.nix ];

        devshells.default = devshell.lib.importTOML ./devshell.toml;
      };

      flake = {

      };
    };
  # let
  #   # x86_64-darwin is omitted on purpose: nixpkgs 26.11 dropped it.
  #   supportedSystems = [
  #     flake-utils.lib.system.x86_64-linux
  #     flake-utils.lib.system.aarch64-linux
  #     flake-utils.lib.system.aarch64-darwin
  #   ];
  # in
  # flake-utils.lib.eachSystem supportedSystems (
  #   system:
  #   let
  #     pkgs = import nixpkgs {
  #       inherit system;
  #       overlays = [ devshell.overlays.default ];
  #     };

  #     devShell = pkgs.devshell.fromTOML ./devshell.toml;

  #     releaseTool = pkgs.writeShellApplication {
  #       name = "release";
  #       # scripts/release.sh stays the single source of truth; the wrapper
  #       # only supplies a hermetic PATH with the tools the script needs.
  #       text = ''exec ${./scripts/release.sh} "$@"'';
  #       inheritPath = false;
  #       runtimeInputs = [
  #         pkgs.coreutils
  #         pkgs.gawk
  #         pkgs.gnused
  #         pkgs.gnugrep
  #         pkgs.git
  #         pkgs.curl
  #         pkgs.jq
  #         pkgs.gh
  #       ];
  #     };
  #     treefmt = pkgs.treefmt.withConfig {
  #       name = "treefmt";
  #       settings.imports = [ ./treefmt.nix ];
  #       runtimeInputs = [
  #         pkgs.nixfmt
  #         pkgs.taplo
  #         pkgs.prettier
  #         pkgs.shfmt
  #         pkgs.shellcheck-minimal
  #       ];
  #     };
  #   in
  #   {
  #     apps.default = devShell.flakeApp // {
  #       meta.description = "BlueForest packaging devshell";
  #     };
  #     apps.release = {
  #       type = "app";
  #       program = "${releaseTool}/bin/release";
  #       meta.description = "Interactive release helper";
  #     };
  #   }
  # );
}

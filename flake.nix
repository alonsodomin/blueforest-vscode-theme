{
  description = "BlueForest Theme Collection";

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

      perSystem = { system, pkgs, ... }: {
        treefmt.imports = [ ./treefmt.nix ];

        devshells.default = devshell.lib.importTOML ./devshell.toml;

        apps.release =
          let
            releaseTool = pkgs.callPackage ./tools/release.nix { inherit pkgs; };
          in
          {
            type = "app";
            program = "${releaseTool}/bin/release";
            meta.description = "Interactive release helper";
          };
      };

      flake = { };
    };
}

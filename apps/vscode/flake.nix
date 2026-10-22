{
  description = "BlueForest theme for VS Code / VSCodium";

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
    import ./nix/outputs.nix {
      inherit
        nixpkgs
        flake-utils
        devshell
        ;
    };
}

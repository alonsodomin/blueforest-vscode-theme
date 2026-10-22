{
  description = "BlueForest themes for many tools";

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

      # The nixpkgs instance of this repository, with the overlays the
      # development tools need.
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ devshell.overlays.default ];
      };

      inherit (pkgs) lib;

      # The theme configurations in this repository. Every one of them is a
      # function that returns the outputs of that application, so that the
      # application flake and this flake cannot disagree about them.
      #
      # Adding an application is a matter of adding a directory and a line
      # here.
      appOutputs = {
        vscode = import ./vscode/nix/outputs.nix {
          inherit
            nixpkgs
            flake-utils
            devshell
            ;
        };
      };

      # The outputs of every application, as a list.
      allApps = lib.attrValues appOutputs;

      # The overlays of every application, applied like nixpkgs applies
      # them.
      composeOverlays =
        overlays: final: prev:
        lib.foldl' (acc: overlay: overlay acc) prev (lib.reverseList overlays);

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

      devShell = pkgs.devshell.fromTOML ./devshell.toml;

      # The interactive release helper. scripts/release.sh dispatches to the
      # script of the application that is being released.
      releaseTool = pkgs.writeShellApplication {
        name = "release";
        # scripts/release.sh stays the single source of truth; the wrapper
        # only supplies a hermetic PATH with the tools the script needs.
        text = ''exec ${./scripts/release.sh} "$@"'';
        inheritPath = false;
        runtimeInputs = [
          pkgs.bash
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

      # Checks that every application carries the version of the repository.
      # The applications keep their own copy of it, because a consumer that
      # installs a single application only gets that application.
      versionCheck =
        pkgs.runCommand "blueforest-version-check"
          {
            nativeBuildInputs = [ pkgs.jq ];
            src = ./.;
          }
          ''
            cd "$src"

            expected=$(cat VERSION)

            for file in */VERSION; do
              actual=$(cat "$file")
              if [ "$actual" != "$expected" ]; then
                echo "$file has version $actual, the repository has $expected" >&2
                exit 1
              fi
            done

            for file in */package.json; do
              actual=$(jq -r '.version' "$file")
              if [ "$actual" != "$expected" ]; then
                echo "$file has version $actual, the repository has $expected" >&2
                exit 1
              fi
            done

            touch $out
          '';

      perSystem = flake-utils.lib.eachSystem supportedSystems (system: {
        packages = lib.concatMapAttrs (name: outputs: outputs.packages.${system} or { }) appOutputs;

        checks =
          lib.concatMapAttrs (
            name: outputs:
            lib.mapAttrs' (checkName: check: lib.nameValuePair "${name}-${checkName}" check) (
              outputs.checks.${system} or { }
            )
          ) appOutputs
          // {
            # Fails if any file is not formatted.
            formatting = treefmt.check ./.;

            # Fails if an application carries a version of its own.
            version = versionCheck;
          };

        devShells = lib.concatMapAttrs (name: outputs: outputs.devShells.${system} or { }) appOutputs // {
          default = devShell;
        };

        apps =
          lib.concatMapAttrs (
            name: outputs:
            lib.mapAttrs' (appName: app: lib.nameValuePair "${name}-${appName}" app) (
              outputs.apps.${system} or { }
            )
          ) appOutputs
          // {
            release = {
              type = "app";
              program = "${releaseTool}/bin/release";
              meta.description = "Interactive release helper";
            };
          };

        formatter = treefmt;
      });
    in
    {
      # The same shape nix-vscode-extensions uses.
      extensions = lib.mergeAttrsList (map (outputs: outputs.extensions) allApps);

      overlays = {
        default = composeOverlays (map (outputs: outputs.overlays.default) allApps);
      }
      // lib.mapAttrs' (name: outputs: lib.nameValuePair name outputs.overlays.default) appOutputs;

      nixosModules = {
        default = {
          imports = map (outputs: outputs.nixosModules.default) allApps;
        };
      }
      // lib.mapAttrs' (name: outputs: lib.nameValuePair name outputs.nixosModules.default) appOutputs;

      homeManagerModules = {
        default = {
          imports = map (outputs: outputs.homeManagerModules.default) allApps;
        };
      }
      // lib.mapAttrs' (
        name: outputs: lib.nameValuePair name outputs.homeManagerModules.default
      ) appOutputs;
    }
    // perSystem;
}

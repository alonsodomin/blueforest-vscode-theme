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

      # The integration check builds VSCodium, which is a ~150 MB download. It
      # is only part of `nix flake check` when it is asked for explicitly:
      #
      #   BLUEFOREST_VSCODE_INTEGRATION_CHECK=1 nix flake check --impure
      #
      # The environment variable is only read in impure mode, so a plain
      # `nix flake check` never builds VSCodium by accident. The check can
      # also be built on its own: nix build .#vscode-integration-check
      heavyChecks = builtins.getEnv "BLUEFOREST_VSCODE_INTEGRATION_CHECK" == "1";

      # Adds `blueforest-vscode-theme` to a nixpkgs instance.
      overlay = import ./nix/overlay.nix;

      # The module consumers import to get `pkgs.blueforest-vscode-theme`.
      module = import ./nix/modules/default.nix;

      perSystem = flake-utils.lib.eachSystem supportedSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              devshell.overlays.default
              overlay
            ];
          };

          devShell = pkgs.devshell.fromTOML ./devshell.toml;

          inherit (pkgs) lib;

          # The extension, built with the nixpkgs of this flake.
          extension = pkgs.blueforest-vscode-theme;

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

          # Checks that the extension is a valid VS Code extension: the files
          # VS Code reads are there and the metadata is the expected one.
          extensionCheck =
            pkgs.runCommand "blueforest-extension-check"
              {
                nativeBuildInputs = [ pkgs.jq ];
              }
              ''
                dir="${extension}/share/vscode/extensions/alonsodomin.blueforest-theme"

                test -f "$dir/package.json"
                jq -e '.publisher == "alonsodomin"' "$dir/package.json" >/dev/null
                jq -e '.name == "blueforest-theme"' "$dir/package.json" >/dev/null
                jq -e '.version == "${extension.version}"' "$dir/package.json" >/dev/null
                jq -e '.contributes.themes[0].id == "BlueForest"' "$dir/package.json" >/dev/null

                test -f "$dir/themes/Blueforest-color-theme.json"
                jq -e 'type == "object"' "$dir/themes/Blueforest-color-theme.json" >/dev/null

                # The theme that gets installed is the theme of this
                # repository.
                cmp "$dir/themes/Blueforest-color-theme.json" ${./themes/Blueforest-color-theme.json}

                # This is the entry `vscode-with-extensions` writes to
                # extensions.json, the file VS Code reads to find its
                # extensions.
                echo '${pkgs.vscode-utils.toExtensionJson [ extension ]}' \
                  | jq -e '.[0].identifier.id == "alonsodomin.blueforest-theme"' >/dev/null

                touch $out
              '';

          # Checks that the configuration documented in the README evaluates
          # and ends up installing the theme.
          configurationCheck =
            pkgs.runCommand "blueforest-configuration-check"
              {
                nativeBuildInputs = [ pkgs.jq ];
                result = builtins.toJSON (
                  import ./nix/modules/check.nix {
                    inherit
                      lib
                      pkgs
                      module
                      ;
                    extensionId = "alonsodomin.blueforest-theme";
                  }
                );
              }
              ''
                echo "$result" | jq -e '
                  .hasTheme
                  and (.extensionIds | index("alonsodomin.blueforest-theme"))
                  and (.vscodeExtensionIds | index("alonsodomin.blueforest-theme"))
                  and (.wrapperName != null)
                ' >/dev/null
                touch $out
              '';

          # Checks that the theme is really installed into VSCodium. This one
          # builds VSCodium, so it is only run on purpose.
          integrationCheck =
            pkgs.runCommand "blueforest-vscode-integration-check"
              {
                nativeBuildInputs = [ pkgs.jq ];
              }
              ''
                wrapper=${
                  pkgs.vscode-with-extensions.override {
                    vscode = pkgs.vscodium;
                    vscodeExtensions = [ extension ];
                  }
                };

                extensions_dir=$(
                  grep -oE '\-\-extensions-dir [^ "]+' "$wrapper/bin/codium" \
                    | head -n 1 | cut -d ' ' -f 2
                )
                test -n "$extensions_dir"

                test -f "$extensions_dir/alonsodomin.blueforest-theme/themes/Blueforest-color-theme.json"
                jq -e '.[0].identifier.id == "alonsodomin.blueforest-theme"' \
                  "$extensions_dir/extensions.json" >/dev/null

                touch $out
              '';
        in
        {
          devShells.default = devShell;

          packages = {
            default = extension;
            blueforest-vscode-theme = extension;
            # The expensive check, kept out of `nix flake check` but buildable
            # on demand: nix build .#vscode-integration-check
            vscode-integration-check = integrationCheck;
          };

          apps.release = {
            type = "app";
            program = "${releaseTool}/bin/release";
            meta.description = "Interactive release helper";
          };

          formatter = treefmt;

          checks = {
            # Fails if any file is not formatted. Because a non-zero exit from
            # a linter (shellcheck) aborts treefmt, this also fails when a
            # linter reports an error.
            formatting = treefmt.check ./.;

            configuration = configurationCheck;
            extension = extensionCheck;
          }
          // (
            if heavyChecks then
              {
                vscode-integration = integrationCheck;
              }
            else
              {
              }
          );
        }
      );
    in
    {
      overlays.default = overlay;

      nixosModules.default = module;
      homeManagerModules.default = module;

      # The same shape nix-vscode-extensions uses, so that tooling
      # expecting it can pick the theme up.
      extensions = builtins.listToAttrs (
        map (system: {
          name = system;
          value = {
            open-vsx = {
              alonsodomin = {
                "blueforest-theme" = perSystem.packages.${system}.blueforest-vscode-theme;
              };
            };
          };
        }) supportedSystems
      );
    }
    // perSystem;
}

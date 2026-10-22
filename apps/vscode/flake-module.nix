# The BlueForest theme for VS Code, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
{
  config,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      inputs',
      system,
      ...
    }:
    let
      # The nixpkgs instance of the application. The extension is built with
      # the overlaid nixpkgs, so it always matches the VS Code version of the
      # editor it is installed into.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.vscode ];
      };

      # The extension, built with the nixpkgs of this flake.
      extension = pkgs.blueforest-vscode-theme;

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
                  ;
                module = import ./nix/modules/default.nix;
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
      packages = {
        default = extension;
        blueforest-vscode-theme = extension;
        # The expensive check, kept out of `nix flake check` but buildable
        # on demand: nix build .#vscode-integration-check
        vscode-integration-check = integrationCheck;
      };

      checks = {
        vscode-extension = extensionCheck;
        vscode-configuration = configurationCheck;
      }
      // (
        if builtins.getEnv "BLUEFOREST_VSCODE_INTEGRATION_CHECK" == "1" then
          {
            vscode-integration = integrationCheck;
          }
        else
          {
          }
      );

      # The development shell of the application, declared in TOML.
      devshells.vscode = inputs.devshell.lib.importTOML ./devshell.toml;
    };

  flake = {
    # The same shape nix-vscode-extensions uses, so that tooling expecting
    # it can pick the theme up.
    extensions = lib.genAttrs config.systems (system: {
      open-vsx = {
        alonsodomin = {
          "blueforest-theme" = config.allSystems.${system}.packages.blueforest-vscode-theme;
        };
      };
    });

    overlays.vscode = final: prev: {
      blueforest-vscode-theme = import ./nix/extension.nix { pkgs = final; };
    };

    nixosModules.vscode = {
      nixpkgs.overlays = [ config.flake.overlays.vscode ];
    };

    homeModules.vscode = {
      nixpkgs.overlays = [ config.flake.overlays.vscode ];
    };
  };
}

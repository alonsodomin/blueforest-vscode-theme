# Evaluates the configuration documented in the README against the module
# shipped by this flake and reports what the module system resolved.
#
# The result only contains JSON-serialisable values, so that it can be
# asserted on from a derivation. See `checks.configuration` in flake.nix.
{
  lib,
  # The nixpkgs instance of the consumer, i.e. one with our overlay applied.
  pkgs,
  # The module under test.
  module,
  # The unique id of the extension, e.g. "alonsodomin.blueforest-theme".
  extensionId,
}:
let
  # Stubs of the options that a consumer's own editor module provides.
  # They mirror the contracts documented in the README: the extensions of an
  # editor are a list of packages.
  consumerModule =
    { lib, ... }:
    {
      options.nixpkgs.overlays = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [ ];
      };

      options.programs.vscode.extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };

      options.programs.vscodium.profiles = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              extensions = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [ ];
              };
            };
          }
        );
        default = {
          default = {
            extensions = [ ];
          };
        };
      };
    };

  evaluated = lib.evalModules {
    modules = [
      consumerModule
      module
      {
        programs.vscode.extensions = [ pkgs.blueforest-vscode-theme ];
        programs.vscodium.profiles.default.extensions = [ pkgs.blueforest-vscode-theme ];
      }
    ];
    specialArgs = {
      inherit pkgs;
    };
  };

  profile = evaluated.config.programs.vscodium.profiles.default;

  # The editor the consumer ends up with. Building it is expensive, but
  # evaluating it is not, and it shows that the extension can be handed over
  # to the editor.
  wrapper = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = profile.extensions;
  };
in
{
  hasTheme = builtins.elem extensionId (map (e: e.vscodeExtUniqueId) profile.extensions);

  extensionIds = map (e: e.vscodeExtUniqueId) profile.extensions;

  # The same for the editor of the nixpkgs module system.
  vscodeExtensionIds = map (e: e.vscodeExtUniqueId) evaluated.config.programs.vscode.extensions;

  # Only a smoke test: the wrapper is built by the heavy check.
  wrapperName = wrapper.name;
}

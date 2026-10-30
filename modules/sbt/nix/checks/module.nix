# SPDX-License-Identifier: MPL-2.0
#
# Checks that the Home Manager module installs the files of the prompt where
# both generations of sbt read their global configuration, and that it writes
# nothing when sbt is not enabled.
{
  lib,
  pkgs,
  homeManager,
  module,
  sources,
}:
let
  # The identity of the user of the configuration, so that the paths of the
  # files are known.
  identity = {
    home.username = "blueforest";
    home.homeDirectory = "/home/blueforest";
    home.stateVersion = "26.11";
  };

  evaluate =
    extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        identity
        extra
      ];
    }).config;

  enabled = evaluate { programs.sbt.enable = true; };
  disabled = evaluate { };

  # The global base directories of both generations of sbt.
  sbt1 = ".sbt/1.0";
  sbt2 = "sbt/2";

  # The paths stay paths, so that `builtins.toJSON` keeps their string
  # context and the files become inputs of the check, instead of a path that
  # points into a source tree that may not have been copied to the store.
  result = builtins.toJSON {
    enabled = {
      sbt1Plugin = {
        target = "${enabled.home.homeDirectory}/${sbt1}/plugins/sbt-prompt.sbt";
        source = enabled.home.file."${sbt1}/plugins/sbt-prompt.sbt".source;
      };
      sbt1Settings = {
        target = "${enabled.home.homeDirectory}/${sbt1}/blueforest-prompt.sbt";
        source = enabled.home.file."${sbt1}/blueforest-prompt.sbt".source;
      };
      sbt2Plugin = {
        target = "${enabled.xdg.configHome}/${sbt2}/plugins/sbt-prompt.sbt";
        source = enabled.xdg.configFile."${sbt2}/plugins/sbt-prompt.sbt".source;
      };
      sbt2Settings = {
        target = "${enabled.xdg.configHome}/${sbt2}/blueforest-prompt.sbt";
        source = enabled.xdg.configFile."${sbt2}/blueforest-prompt.sbt".source;
      };
    };

    # The module does not enable sbt, so a configuration that does not enable
    # it gets none of the files.
    disabled = {
      sbt1Plugin = disabled.home.file ? "${sbt1}/plugins/sbt-prompt.sbt";
      sbt1Settings = disabled.home.file ? "${sbt1}/blueforest-prompt.sbt";
      sbt2Plugin = disabled.xdg.configFile ? "${sbt2}/plugins/sbt-prompt.sbt";
      sbt2Settings = disabled.xdg.configFile ? "${sbt2}/blueforest-prompt.sbt";
    };
  };
in
pkgs.runCommand "blueforest-sbt-module-check"
  {
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    inherit result;
  }
  ''
    # The files end up in the global configuration directories of both
    # generations of sbt.
    echo "$result" | jq -e '
      .enabled.sbt1Plugin.target == "/home/blueforest/.sbt/1.0/plugins/sbt-prompt.sbt"
      and .enabled.sbt1Settings.target == "/home/blueforest/.sbt/1.0/blueforest-prompt.sbt"
      and .enabled.sbt2Plugin.target == "/home/blueforest/.config/sbt/2/plugins/sbt-prompt.sbt"
      and .enabled.sbt2Settings.target == "/home/blueforest/.config/sbt/2/blueforest-prompt.sbt"
      and (.disabled | to_entries | all(.value == false))
    ' >/dev/null

    # The installed files are the files of the repository.
    cmp "$(echo "$result" | jq -r '.enabled.sbt1Plugin.source')" ${sources.plugin}
    cmp "$(echo "$result" | jq -r '.enabled.sbt1Settings.source')" ${sources.settings}
    cmp "$(echo "$result" | jq -r '.enabled.sbt2Plugin.source')" ${sources.plugin}
    cmp "$(echo "$result" | jq -r '.enabled.sbt2Settings.source')" ${sources.settings}

    touch $out
  ''

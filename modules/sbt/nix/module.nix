# SPDX-License-Identifier: MPL-2.0
#
# Installs the BlueForest prompt for sbt.
#
# The prompt itself is the one of the sbt-prompt plugin, which is configured
# upstream at https://github.com/alonsodomin/sbt-prompt. This module only
# installs the plugin declaration and the selection of its BlueforestTheme.
#
# The module is inert unless `programs.sbt.enable` is true: it does not enable
# sbt, it only adds the files to the global configuration of an sbt that the
# consumer already enabled.
#
# sbt 1 reads its global configuration from
# `$HOME/<programs.sbt.baseUserConfigPath>/1.0`, and sbt 2 follows the XDG base
# directory specification and reads it from `$XDG_CONFIG_HOME/sbt/2`. Both
# generations read the plugins from the `plugins` directory of that base and
# the settings from the base itself.
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.sbt;

  # The two files of the repository, which are the ones the package carries.
  plugin = ../config/sbt-prompt.sbt;
  settings = ../config/blueforest-prompt.sbt;

  # The global base directory of sbt 1, relative to the home directory.
  sbt1 = "${cfg.baseUserConfigPath}/1.0";

  # The global base directory of sbt 2, relative to the configuration
  # directory of the user.
  sbt2 = "sbt/2";
in
{
  config = lib.mkIf cfg.enable {
    home.file = {
      "${sbt1}/plugins/sbt-prompt.sbt".source = plugin;
      "${sbt1}/blueforest-prompt.sbt".source = settings;
    };

    xdg.configFile = {
      "${sbt2}/plugins/sbt-prompt.sbt".source = plugin;
      "${sbt2}/blueforest-prompt.sbt".source = settings;
    };
  };
}

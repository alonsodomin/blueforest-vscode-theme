# SPDX-License-Identifier: MPL-2.0
#
# Checks that the package carries the files of the repository, and that they
# declare the plugin and select the theme of the plugin.
{
  pkgs,
  prompt,
  sources,
}:
pkgs.runCommand "blueforest-sbt-prompt-package-check"
  {
    nativeBuildInputs = [ pkgs.gnugrep ];
  }
  ''
    # The files of the package are the files of the repository.
    cmp ${prompt}/share/sbt/plugins/sbt-prompt.sbt ${sources.plugin}
    cmp ${prompt}/share/sbt/blueforest-prompt.sbt ${sources.settings}

    # The plugin is the one of the upstream repository.
    grep -q 'addSbtPlugin("com.github.alonsodomin" % "sbt-prompt" % "3.0.0")' \
      ${prompt}/share/sbt/plugins/sbt-prompt.sbt

    # And the theme is the one the plugin ships.
    grep -q 'promptTheme := BlueforestTheme' \
      ${prompt}/share/sbt/blueforest-prompt.sbt

    test -f ${prompt}/share/doc/blueforest/NOTICE.md
    test -f ${prompt}/share/doc/blueforest/LICENSE

    touch $out
  ''

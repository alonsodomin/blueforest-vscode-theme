# SPDX-License-Identifier: MPL-2.0
#
# The references of a theme of OpenCode that do not resolve.
#
# A theme is a tree of colours. A colour is a hex value, the word
# "transparent", or a reference to another colour of the theme, written as
# "$" followed by the path to it.
#
# A reference that does not resolve is one OpenCode silently replaces with a
# default colour, so the theme has to be checked before it is shipped.
{
  lib,
  # The theme, as it was read.
  theme,
}:
let
  # Whether a value is a reference to another colour.
  isReference = value: lib.isString value && lib.hasPrefix "$" value;

  # The path of a reference, without the "$".
  refPath = value: lib.filter (part: part != "") (lib.splitString "." (lib.removePrefix "$" value));

  # The mode of the theme. It is a dark theme, so it has one mode.
  mode = if (theme ? dark) then theme.dark else (theme.light or { });

  # The tree a mode sees: the tokens of the base, with the tokens of the mode
  # over them.
  merged = lib.recursiveUpdate theme.base mode;

  # The value at a path of the tree, with the references resolved on the way.
  #
  # A reference is a path from the root of the theme, so it is always
  # resolved against the root, and never against the node the walk is at.
  lookup =
    root: node: parts: depth:
    if depth > 16 then
      null
    else if parts == [ ] then
      node
    else if !lib.isAttrs node then
      null
    else
      let
        value = node.${lib.head parts} or null;
        rest = lib.tail parts;
      in
      if value == null then
        null
      else if isReference value then
        # The reference points at another colour, which may be a tree of
        # colours itself.
        let
          resolved = lookup root root (refPath value) (depth + 1);
        in
        if rest == [ ] then resolved else lookup root resolved rest (depth + 1)
      else
        lookup root value rest (depth + 1);

  # Every reference of a tree.
  collect =
    value:
    if lib.isAttrs value then
      lib.concatLists (lib.mapAttrsToList (_: collect) value)
    else if lib.isList value then
      lib.concatLists (map collect value)
    else if isReference value then
      [ value ]
    else
      [ ];

  # The references of the base that do not resolve to a colour.
  unresolved = lib.filter (ref: !(lib.isString (lookup merged merged (refPath ref) 0))) (
    collect theme.base
  );

  # The aliases of the hues that do not resolve to a hue.
  unresolvedHues = lib.filter (ref: !(lib.isAttrs (lookup merged merged (refPath ref) 0))) (
    collect (mode.hue or { })
  );

  # The hues of the categorical palette that the mode does not have.
  missingHues = lib.filter (hue: !(builtins.hasAttr hue (mode.hue or { }))) (
    theme.base.categorical or [ ]
  );
in
{
  inherit missingHues unresolved unresolvedHues;
}

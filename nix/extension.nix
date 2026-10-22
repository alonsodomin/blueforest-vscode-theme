# The BlueForest theme as a VS Code extension.
#
# The extension is fetched from Open VSX, the same way the extensions of
# nix-vscode-extensions are, so the resulting derivation is interchangeable
# with theirs.
{
  pkgs,
}:
let
  publisher = "alonsodomin";

  name = "blueforest-theme";

  # Keep in sync with the version in package.json. `checks.version` fails
  # when the two drift apart.
  version = "0.3.2";
in
pkgs.vscode-utils.buildVscodeExtension {
  pname = name;
  inherit version;

  src = pkgs.fetchurl {
    url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
    hash = "sha256-Bg7lzexT+NRJu8kC3iYEUY62WiLkk7/rBWZktWoCaLw=";
  };

  vscodeExtPublisher = publisher;
  vscodeExtName = name;
  vscodeExtUniqueId = "${publisher}.${name}";

  meta = {
    description = "A dark, high contrast, blue theme";
    homepage = "https://github.com/alonsodomin/blueforest-vscode-theme";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.all;
  };
}

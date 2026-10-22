# The BlueForest theme as a VS Code extension.
#
# The extension is built from the sources in this repository, the same way the
# extensions of nix-vscode-extensions are built, so that the resulting
# derivation is interchangeable with theirs.
{
  pkgs,
}:
let
  # The metadata of the extension is the one of the sources in this
  # repository, so that the two cannot drift apart.
  packageJson = builtins.fromJSON (builtins.readFile ../package.json);

  inherit (packageJson) name publisher version;

  description = packageJson.description;

  homepage = packageJson.repository.url;

  # The extension as a VSIX, the archive the marketplaces distribute. It is
  # built with the same tool the release uses, so that the archive holds the
  # same files as the published one.
  vsix = pkgs.stdenvNoCC.mkDerivation {
    # The name has to end in .vsix, that is how the unpacker recognises the
    # archive.
    name = "blueforest-theme-${version}.vsix";
    pname = "blueforest-theme-vsix";
    inherit version;

    src = ../.;

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.vsce
    ];

    buildPhase = ''
      runHook preBuild
      vsce package --no-dependencies --out blueforest-theme-${version}.vsix
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp blueforest-theme-${version}.vsix $out
      runHook postInstall
    '';
  };
in
pkgs.vscode-utils.buildVscodeExtension {
  pname = name;
  inherit version;

  src = vsix;

  vscodeExtPublisher = publisher;
  vscodeExtName = name;
  vscodeExtUniqueId = "${publisher}.${name}";

  meta = {
    inherit description homepage;
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.all;
  };
}

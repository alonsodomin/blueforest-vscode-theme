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

  displayName = packageJson.displayName;

  homepage = packageJson.repository.url;

  engine = packageJson.engines.vscode;

  # The extension as a VSIX, the archive the marketplaces distribute.
  vsix =
    pkgs.runCommand "blueforest-theme-${version}.vsix"
      {
        nativeBuildInputs = [ pkgs.zip ];
      }
      ''
        mkdir -p extension

        cp ${../package.json} extension/package.json
        cp -r ${../themes} extension/themes
        cp ${../icon.png} extension/icon.png
        cp ${../README.md} extension/readme.md
        cp ${../LICENSE.md} extension/LICENSE.md
        cp ${../CHANGELOG.md} extension/changelog.md

        cat > extension.vsixmanifest <<EOF
        <?xml version="1.0" encoding="utf-8"?>
        <PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
          <Metadata>
            <Identity Language="en-US" Id="${name}" Version="${version}" Publisher="${publisher}" />
            <DisplayName>${displayName}</DisplayName>
            <Description xml:space="preserve">${description}</Description>
            <Tags>theme,color-theme</Tags>
            <Categories>${builtins.concatStringsSep ", " packageJson.categories}</Categories>
            <GalleryFlags>Public</GalleryFlags>
            <Properties>
              <Property Id="Microsoft.VisualStudio.Code.Engine" Value="${engine}" />
              <Property Id="Microsoft.VisualStudio.Code.ExtensionKind" Value="ui,workspace,web" />
              <Property Id="Microsoft.VisualStudio.Services.Links.Source" Value="${homepage}" />
              <Property Id="Microsoft.VisualStudio.Services.Links.Getstarted" Value="${homepage}" />
              <Property Id="Microsoft.VisualStudio.Services.Links.GitHub" Value="${homepage}" />
              <Property Id="Microsoft.VisualStudio.Services.Links.Support" Value="${homepage}/issues" />
              <Property Id="Microsoft.VisualStudio.Services.Content.Pricing" Value="Free" />
            </Properties>
            <License>extension/LICENSE.md</License>
            <Icon>extension/icon.png</Icon>
          </Metadata>
          <Installation>
            <InstallationTarget Id="Microsoft.VisualStudio.Code" />
          </Installation>
          <Dependencies />
          <Assets>
            <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true" />
            <Asset Type="Microsoft.VisualStudio.Services.Content.Details" Path="extension/readme.md" Addressable="true" />
            <Asset Type="Microsoft.VisualStudio.Services.Content.Changelog" Path="extension/changelog.md" Addressable="true" />
            <Asset Type="Microsoft.VisualStudio.Services.Content.License" Path="extension/LICENSE.md" Addressable="true" />
            <Asset Type="Microsoft.VisualStudio.Services.Icons.Default" Path="extension/icon.png" Addressable="true" />
          </Assets>
        </PackageManifest>
        EOF

        cat > '[Content_Types].xml' <<EOF
        <?xml version="1.0" encoding="utf-8"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension=".json" ContentType="application/json" />
          <Default Extension=".md" ContentType="text/markdown" />
          <Default Extension=".png" ContentType="image/png" />
          <Default Extension=".vsixmanifest" ContentType="text/xml" />
        </Types>
        EOF

        zip -r -X $out extension extension.vsixmanifest '[Content_Types].xml'
      '';
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

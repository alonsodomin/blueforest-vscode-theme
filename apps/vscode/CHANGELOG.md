# Change Log
All notable changes to the "blueforest-theme" extension will be documented in this file.

Check [Keep a Changelog](http://keepachangelog.com/) for recommendations on how to structure this file.


## 0.4.0 - [22-10-2026]

- The theme moved into the `apps/vscode/` directory, and the repository now hosts
  the configurations of the theme for several tools
- The application is a flake of its own, which publishes a flake-parts module
  that the root flake composes
- The release process is split per application: `tools/release.sh` picks the
  application and hands it over to `tools/lib/vscode.sh`

## 0.3.2 - [28-09-2026]

- - Add ID to the theme manifest
- - Fix bad syntax errors in the theme's JSON

## 0.3.1 - [13-10-2025]

- Lowered the minimum VS Code version to 1.104 to allow installing on Codium
- Fixed a typo in the license header

## 0.3.0 - [10-10-2025]

- Added MIT license
- Raised the minimum VS Code version to 1.105

## 0.2.1 - [23-12-2019]

- Improved color for overlay widgets (Search, Debug, etc.)
- Improved syntax highlighting for some more languages

## 0.2.0 - [16-12-2019]

- Enhanced Theme to work with latest Visual Studio Code versions
- Improved Syntax Highlighting for more languages

## 0.1.0 - [15-08-2017]

- Initial release

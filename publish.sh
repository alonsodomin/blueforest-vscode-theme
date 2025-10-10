#!/bin/sh

set -e

npm install -g @vscode/vsce
vsce package
vsce publish

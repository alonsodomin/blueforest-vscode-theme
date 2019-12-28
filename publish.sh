#!/bin/sh

set -e

npm install -g vsce
vsce package
vsce publish

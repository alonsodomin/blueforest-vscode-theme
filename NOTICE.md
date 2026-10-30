# Notices

## The theme

BlueForest is a colour scheme by [mathias[at]decodified[dot]com][author],
published at <https://github.com/sirthias/BlueForest> under the
[Creative Commons Attribution 3.0 Unported][cc-by-3.0] licence.

The configurations in this repository are ports of that theme. They are
distributed under the [Creative Commons Attribution 4.0 International][cc-by-4.0]
licence, and they have been modified: the colours have been adapted to the
format of each tool.

### Attribution

- **Title:** BlueForest
- **Creator:** mathias[at]decodified[dot]com
- **Source:** <https://github.com/sirthias/BlueForest>
- **Original licence:** [CC BY 3.0 Unported][cc-by-3.0]
- **Changes:** ported to the configuration format of each tool in `modules/`

The material is provided as is and without warranties of any kind. The
disclaimer of warranties is Section 5 of the CC BY 4.0 legal code, which is in
[LICENSES/CC-BY-4.0.txt](LICENSES/CC-BY-4.0.txt); the licence itself is at
<https://creativecommons.org/licenses/by/4.0/legalcode>.

### The prompt for sbt

The prompt of `modules/sbt/` is not defined in this repository. It is the
`BlueforestTheme` of [sbt-prompt](https://github.com/alonsodomin/sbt-prompt),
which is distributed under the [MIT licence][mit]. The files in
`modules/sbt/config/` only declare the plugin and select that theme; they do
not carry the prompt.

The BlueForest colours of that theme are a port of BlueForest by
[mathias[at]decodified[dot]com][author], under the same attribution as the
other ports of this repository.

## The code

The code that packages the theme — the Nix expressions, the shell scripts, the
CI workflows and the manifests — is licensed under the
[Mozilla Public License 2.0][mpl-2.0]. The full text is in [LICENSE](LICENSE).

## What each licence covers

| Path | Licence |
| --- | --- |
| `modules/*/themes/**` | CC BY 4.0 |
| `modules/sbt/config/**` | MPL-2.0 |
| `assets/**` | CC BY 4.0 |
| `*.png`, `modules/*/*.png` | CC BY 4.0 |
| `*.md`, `modules/*/*.md` | CC BY 4.0 |
| `LICENSE`, `LICENSES/**`, `modules/*/LICENSE` | the licence text itself |
| everything else | MPL-2.0 |

## Copyright

The code in this repository: Copyright © 2019-2026 A. Alonso Dominguez.

The ports of the theme: Copyright © 2019-2026 A. Alonso Dominguez, based on
BlueForest by mathias[at]decodified[dot]com.

[author]: https://github.com/sirthias
[cc-by-3.0]: https://creativecommons.org/licenses/by/3.0/
[cc-by-4.0]: https://creativecommons.org/licenses/by/4.0/
[mit]: https://opensource.org/licenses/MIT
[mpl-2.0]: https://mozilla.org/MPL/2.0/

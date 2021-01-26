# Template for a latex document
Make use of github workflows to automatically lint (tex and python), create figures (python and tikz) and compile the `pdf`.
## [see latest pdf](../../blob/compiledPDF/main.pdf)


## Repo Health

![compile pdf](../../workflows/compile%20pdf/badge.svg)
![Latex linter](../../workflows/Latex%20linter/badge.svg)


## Build instruction
### manuscript
`Makefile` exists, checks whether latexmk is available to speed up local builds.
`make` builds the pdf (and tikz figures), python figures are included in `make all` or build specificially `make fig_python`.
python figures are done with the [gridspeccer](https://github.com/obreitwi/gridspeccer/), which has to be installed (see there for install instructions).
### `tikz` diagrams
The are simple `.tex` files located in the `fig` subfolder, and they can be build with `pdflatex` for example.
For easier use, they build instruction is in the `Makefile`, so typing `make fig_tikz` builds the intro figure, and they are added as dependencies to `make main.pdf`

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
The are simple `.tex` files located in the `fig_tikz` subfolder, and they can be build with `pdflatex` for example.
For easier use, they build instruction is in the `Makefile`, so typing `make fig_tikz` builds the intro figure, and they are added as dependencies to `make main.pdf`
### githooks
There is a hook for git in `.githooks/pre-commit` that runs `chktex` (the latex linter) before every commit to see if there are any problems. In case you want this, you have to (locally) configure `git` to do that with (make sure the file is executable `chmod u+x .githooks/pre-commit`)
```
git config core.hooksPath .githooks
```
### updating your repo to current version of the template
Unfortunately, as of now there is no standard/easy/GUI way of doing this.
The best way, I guess, is described [here](https://stackoverflow.com/a/56577320), i.e., add this repo as a remote, fetch changes and do a manual merge:
```
git remote add template git@github.com:JulianGoeltz/automised_latex_template.git
# or: git remote add template https://github.com/JulianGoeltz/automised_latex_template/
git fetch --all
git merge template/main
```

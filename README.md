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
### building without `make`/`python`
The following allows local tex compilation (with your favourite tex suite) even without python, make, gridspeccer or whatnot.
Make sure you are on the current version with `git pull`, and also that you are on the correct branch (probably `git checkout main`), then using the command gets the pdf files from the `compiledPDF` branch, i.e., the figures build on github (YMMV with the globbing, you can also try `bash -c "git restore --source=origin/compiledPDF -- fig/fig*.pdf fig_tikz/fig*/*.pdf"`)
```zsh
git restore --source=origin/compiledPDF -- "fig/fig*.pdf" "fig_tikz/fig*/*.pdf"
```
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
The best way, I guess, is described [here](https://stackoverflow.com/a/56577320), i.e., add this repo as a remote and fetch changes
```
git remote add template git@github.com:JulianGoeltz/automised_latex_template.git
# or: git remote add template https://github.com/JulianGoeltz/automised_latex_template/
git fetch --all
```
One can then do a manual merge, but this is tedious as all files that are touched by both branches need to be resolved by hand. If you still want to do it, go ahead with `git merge template/main --allow-unrelated-histories`.
The following should work a lot more automatically, and only actual merge conflicts have to be resolved:
```
git checkout -B tmp_TemplateUpdate $(git rev-list --max-parents=0 main)
git cherry-pick $(git rev-list --max-parents=0 template/main)..template/main
git checkout main
git merge tmp_TemplateUpdate
```
Explanation: all commits made in the template are `cherry-pick`ed onto the initial commit.
This temporary branch is then merged (now it comes from a `related-history`, allowing gits magic to work).
After resolving potential merge conflicts, one can delete the temporary branch with `git branch -d tmp_TemplateUpdate`.
If you used this approach, please let me know how it went (as this is not entirely smooth, I might consider going back to a non-template repo that should be forked. Then updates would be easier).


## Todos
* perhaps a 'make release' button, or something like this, that automatically creates a tarball that can be uploaded to arxiv (with the help of arxiv collector)
* link badges to actions


## Miscellaneous
### applying `changes`
If you use the `changes` package and want to apply the changes, I find the following very helpful.
Works with multilines and when there are curly brackets in the changes; but might introduce empty lines where they are not wanted.
```
bracket_pattern='((([^{}]|\n)*\{([^{}]|\n)*\})*([^{}]|\n)*)'
sed -i -Ez 's/\\replaced\{'$bracket_pattern'\}\n*\{'$bracket_pattern'\}/\1/gm' **/*.tex
sed -i -Ez 's/\\added\{'$bracket_pattern'\}/\1/gm' **/*.tex
sed -i -Ez 's/\\deleted\{'$bracket_pattern'\}//gm' **/*.tex
```
### deleting comments
The following should delete comments:
	* first deletes all lines that are (linestart,whitespace,comment)
	* second removes the comments of inline comments IFF the preceeding character is not a backslash, and IFF there is actual non whitespace comment (sometimes a percent before a EOF is needed for some commands)
```
sed -i '/^\s*\%.*/d' **/*.tex\
sed -i -E 's/([^\])\%.+$/\1/gm' **/*.tex
```

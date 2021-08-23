## Repository structure
* `python` figures expected to be in `/code/` and be named like `fig*.py` to be turned into `fig*.pdf` in `/fig/`
* `TikZ` tex files be in `/fig_tikz/fig*/` folders and named `fig*.tex` like the respective folder.
* `main.tex` to include content files from `/sections/` and support files from `/texMaterials/`.

## Build instruction
### Manuscript
`Makefile` exists, checks whether latexmk is available to speed up local builds.
`make` builds the pdf (and `TikZ` figures), speed up through parallelisation with `make all`
`python` figures are included in `make all`, or build specifically with `make fig_python`. [gridspeccer](https://github.com/gridspeccer/gridspeccer/) is used, which has to be installed (see there for install instructions).
`make lint_tex` lints the tex files.

### Building without `make`/`python`
The following allows local tex compilation (with your favourite tex suite) even without python, make, gridspeccer or whatnot.
Make sure you are on the current version with `git pull`, and also that you are on the correct branch (probably `git checkout main`), then using the command gets the pdf files from the `compiledPDF` branch, i.e., the figures build on github (YMMV with the globbing, you can also try `bash -c "git restore --source=origin/compiledPDF -- fig/fig*.pdf fig_tikz/fig*/*.pdf"`)
```zsh
git restore --source=origin/compiledPDF -- "fig/fig*.pdf" "fig_tikz/fig*/*.pdf"
```
### `TikZ` diagrams
The are simple `.tex` files located in the `fig_tikz` subfolder, and they can be build with `pdflatex` for example.
For easy use, the build instruction is in the `Makefile`, so typing `make fig_tikz` builds the intro figure and any you add.
### `git` hooks
There is a hook for git in `.githooks/pre-commit` that runs `chktex` (the latex linter) before every commit to see if there are any problems. In case you want this, you have to (locally) configure `git` to do that with (make sure the file is executable `chmod u+x .githooks/pre-commit`)
```
git config core.hooksPath .githooks
```


## Updating your repo to current version of the template
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



## Miscellaneous
### Compute time and storage on Github
Only limited time and space are available for free on github, so if you're pushing many things you might exceed the free capacity.
However, at time of writing 2000mins are available each month, so with an average build time of 5min you can have 400 commits per month; and if things are extra crucial, it is very cheap to buy additional exection time.
As a precaution for the storage, you can reduce the time builds are available as this might help.

### Applying `changes`
If you use the `changes` package and want to apply the changes, I find the following very helpful.
Works with multilines and when there are curly brackets in the changes; but might introduce empty lines where they are not wanted.
```
bracket_pattern='((([^{}]|\n)*\{([^{}]|\n)*\})*([^{}]|\n)*)'
sed -i -Ez 's/\\replaced\{'$bracket_pattern'\}\n*\{'$bracket_pattern'\}/\1/gm' **/*.tex
sed -i -Ez 's/\\added\{'$bracket_pattern'\}/\1/gm' **/*.tex
sed -i -Ez 's/\\deleted\{'$bracket_pattern'\}//gm' **/*.tex
```
### Deleting comments
The following should delete comments:
	* first deletes all lines that are (linestart,whitespace,comment)
	* second removes the comments of inline comments IFF the preceeding character is not a backslash, and IFF there is actual non whitespace comment (sometimes a percent before a EOF is needed for some commands)
```
sed -i '/^\s*\%.*/d' **/*.tex\
sed -i -E 's/([^\])\%.+$/\1/gm' **/*.tex
```

### `languageckeck`
(the following is not really stable)

There is a `Makefile` routine called `make languageckeck` that uses `LanguageTool` and `YaLafi` to grammar check the language.
This works more or less: a lot of false negatives, but occasionally some good hints.
The idea is to check in the `.languagetool_state` at each commit after checking that no new actual errors arose.
In the `Makefile` the call is designed  cut the irrelevant info with `sed` to ease `git-diff`s.

The call needs the `docdef=atom` option for the `glossaries-extra` package, as well as the `poorman` option for `cleveref`, plus a file that for me lies in `~/.config/vlty/defs.tex` and [can be found online](https://github.com/JulianGoeltz/myConfigFiles/blob/master/other_configs/vlty_defs.tex), currently:
```
\LTinput{main.glsdefs}
\YYCleverefInput{main.sed}
```
For more details check the infos of [YaLafi](https://github.com/matze-dd/YaLafi) and [LanguageTool](https://github.com/languagetool-org/languagetool)

LATEXEXE=pdflatex -synctex=1
MV=mv
BIBTEXEXE=bibtex
LATEXMK_EXISTS := $(shell latexmk --version 2>/dev/null)
LATEXMK=latexmk -pdf -synctex=1

# list all possible figure sources (form fig*.py in the code folder) and
# construct the resulting pdf filenames this allows us to create rules for
# the individual figures, allowing us to only rebuild the figures that change
PYTHON_FIG_SOURCES := $(wildcard code/fig*.py)
PYTHON_FIGStmp := $(patsubst %.py,%.pdf,$(PYTHON_FIG_SOURCES))
PYTHON_FIGS := $(patsubst code/%,fig/%,$(PYTHON_FIGStmp))
TIKZ_FIG_SOURCES := $(wildcard fig_tikz/fig*/)
TIKZ_FIGS := $(patsubst fig_tikz/fig%/,fig_tikz_%,$(TIKZ_FIG_SOURCES))

# chktex wrapper to have exit on error (-g0 means to not read global cktexrc)
CHKTEX_WRAPPER=sh -c '\
  tmp="$$(chktex -q -v3 -g0 $$@)"; \
  if [ -n "$$tmp" ] ; then \
    chktex -q -v3 -g0 $$@; \
    exit 1; \
  fi' --


main.pdf: fig_tikz
ifdef LATEXMK_EXISTS
	$(LATEXMK) main.tex
else
	$(LATEXEXE) main
	$(BIBTEXEXE) main
	$(LATEXEXE) main
	$(LATEXEXE) main
endif

all:
	$(MAKE) check-and-reinit-submodules
	$(MAKE) -j4 fig_python
	$(MAKE) -j4 fig_tikz
	$(MAKE) main.pdf

cleanall: clean fig_python_clean
	$(RM) main.pdf

clean: fig_tikz_clean
	$(RM) *.toc *.nav *.out *.snm *.bak *.aux *.log *.bbl *.blg *.lof *.lot *.fls *.fdb_latexmk *.loc *.soc *-blx.bib  *.run.xml  *.synctex.gz

fig_tikz_clean:
	@echo "make fig_tikz_clean"
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		$(RM) *aux *log *fls *.fdb_latexmk; \
		$(RM) fig*.pdf; \
		cd ../; \
	done

fig_python: $(PYTHON_FIGS)

fig/fig%.pdf: code/matplotlibrc code/fig%.py
	cd code; gridspeccer --mplrc matplotlibrc --loglevel WARNING fig$*.py

fig_python_clean:
	$(RM) fig/*pdf

fig_tikz: $(TIKZ_FIGS)

fig_tikz/fig%/: fig_tikz_% 
	@echo

fig_tikz/fig%: fig_tikz_% 
	@echo

fig_tikz_%:
ifdef LATEXMK_EXISTS
	@cd fig_tikz/fig$*; \
	echo "fig_tikz/fig$*/; latexmk -pdf fig$*.tex"; \
	${LATEXMK} fig$*".tex" || exit;
else
	@cd fig_tikz/fig$*; \
	echo "fig_tikz/fig$*/; pdflatex fig$*.tex"; \
	${LATEXEXE} fig$*".tex" || exit;
endif

lint_tex:
	@echo "chktex -q -v3 -g0 --localrc texMaterials/chktexrc main.tex"
	@${CHKTEX_WRAPPER} --localrc texMaterials/chktexrc main.tex
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		echo "cd fig_tikz/$$folder; chktex -q -v3 -g0 --localrc ../.chktexrc $$folder.tex"; \
		${CHKTEX_WRAPPER} --localrc ../.chktexrc $$folder.tex || exit; \
		cd ../; \
	done

lint_bib:
	@echo "Checking that all bib files are staged, s.t. the change can be tracked"
	git diff --exit-code texMaterials/*.bib || (echo "unstashed changes in texMaterials/*.bib, stash first"; exit 1)
	bibtex-tidy --curly --numeric --duplicates=key --no-remove-dupe-fields texMaterials/*.bib

check-and-reinit-submodules:
	@if git submodule status | egrep -q '^[-]|^[+]' ; then \
		echo "INFO: Need to reinitialize git submodules"; \
		git submodule update --init; \
	fi

languagecheck:
	python -m yalafi.shell --lt-command languagetool --define ~/.config/vlty/defs.tex --equation-punctuation display --packages "*" --include --language en-US main.tex | sed -Ez 's/===\n[0-9]+\.\)/===\n.)/gm' > texMaterials/.languagetool_state.tmp && mv texMaterials/.languagetool_state.tmp texMaterials/.languagetool_state

# get the current 'ground truth' pdf as a specific file
compiledPDF_main.pdf:
	git show compiledPDF:main.pdf > compiledPDF_main.pdf
# compare PDFs and save differences
comparePDF: main.pdf compiledPDF_main.pdf
	diff-pdf --mark-differences --skip-identical --grayscale --output-diff=diff_main_compiledPDF.pdf main.pdf compiledPDF_main.pdf


.PHONY: all main.pdf cleanall clean fig_tikz fig_tikz_clean fig_python_clean lint_tex check-and-reinit-submodules languagecheck comparePDF

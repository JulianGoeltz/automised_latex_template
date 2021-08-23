LATEXEXE=pdflatex -synctex=1
MV=mv
BIBTEXEXE=bibtex
LATEXMK_EXISTS := $(shell latexmk --version 2>/dev/null)
LATEXMK=latexmk -pdf -synctex=1

# list all possible figure sources (form fig*.py in the code folder) and
# construct the resulting pdf filenames this allows us to create rules for
# the individual figures, allowing us to only rebuild the figures that change
PYTHON_FIG_SOURCES := $(wildcard src/python/fig*.py)
PYTHON_FIGStmp := $(patsubst %.py,%.pdf,$(PYTHON_FIG_SOURCES))
PYTHON_FIGS := $(patsubst src/python/%,fig/%,$(PYTHON_FIGStmp))
TIKZ_FIG_SOURCES := $(wildcard src/tikz/fig*/)
TIKZ_FIGS := $(patsubst src/tikz/fig%/,fig_tikz_%,$(TIKZ_FIG_SOURCES))

# chktex wrapper to have exit on error
CHKTEX_WRAPPER=sh -c '\
  tmp="$$(chktex -q -v3 $$@)"; \
  if [ -n "$$tmp" ] ; then \
    chktex -q -v3 $$@; \
    exit 1; \
  fi' CHKTEX


main.pdf: fig_tikz
ifdef LATEXMK_EXISTS
	cd src/tex && $(LATEXMK) main.tex
else
	cd src/tex && $(LATEXEXE) main
	cd src/tex && $(BIBTEXEXE) main
	cd src/tex && $(LATEXEXE) main
	cd src/tex && $(LATEXEXE) main
endif

all:
	$(MAKE) check-and-reinit-submodules
	$(MAKE) -j4 fig_python
	$(MAKE) -j4 fig_tikz
	$(MAKE) main.pdf

cleanall: clean fig_python_clean
	$(RM) src/tex/main.pdf

clean: fig_tikz_clean
	cd src/tex && $(RM) *.toc *.nav *.out *.snm *.bak *.aux *.log *.bbl *.blg *.lof *.lot *.fls *.fdb_latexmk *.loc *.soc

fig_tikz_clean:
	@echo "make fig_tikz_clean"
	@cd src/tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		$(RM) *aux *log *fls *.fdb_latexmk; \
		$(RM) fig*.pdf; \
		cd ../; \
	done

fig_python: $(PYTHON_FIGS)

fig/fig%.pdf: src/python/matplotlibrc src/python/fig%.py
	cd src/python; gridspeccer --mplrc matplotlibrc --output-folder=../../fig/ --loglevel WARNING fig$*.py

fig_python_clean:
	$(RM) fig/*pdf

fig_tikz: $(TIKZ_FIGS)

fig_tikz/fig%/: fig_tikz_% 
	@echo

fig_tikz/fig%: fig_tikz_% 
	@echo

fig_tikz_%:
ifdef LATEXMK_EXISTS
	@cd src/tikz/fig$*; \
	echo "src/tikz/fig$*/; latexmk -pdf fig$*.tex"; \
	${LATEXMK} fig$*".tex" || exit;
else
	@cd src/tikz/fig$*; \
	echo "src/tikz/fig$*/; pdflatex fig$*.tex"; \
	${LATEXEXE} fig$*".tex" || exit;
endif

lint_tex:
	@echo "chktex -q -v3 main.tex"
	@cd src/tex && ${CHKTEX_WRAPPER} main.tex
	@cd src/tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		echo "chktex -q -v3 --localrc ../.chktexrc src/tikz/$$folder/$$folder.tex"; \
		${CHKTEX_WRAPPER} --localrc ../.chktexrc $$folder.tex || exit; \
		cd ../; \
	done

check-and-reinit-submodules:
	@if git submodule status | egrep -q '^[-]|^[+]' ; then \
		echo "INFO: Need to reinitialize git submodules"; \
		git submodule update --init; \
	fi

.PHONY: all main.pdf cleanall clean fig_tikz fig_tikz_clean fig_python_clean lint_tex check-and-reinit-submodules

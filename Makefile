LATEXEXE=pdflatex
MV=mv
BIBTEXEXE=bibtex
LATEXMK_EXISTS := $(shell latexmk --version 2>/dev/null)
LATEXMK=latexmk -pdf

# list all possible figure sources (form fig*.py in the code folder) and
# construct the resulting pdf filenames this allows us to create rules for
# the individual figures, allowing us to only rebuild the figures that change
PYTHON_FIG_SOURCES := $(wildcard code/fig*.py)
PYTHON_FIGStmp := $(patsubst %.py,%.pdf,$(PYTHON_FIG_SOURCES))
PYTHON_FIGS := $(patsubst code/%,fig/%,$(PYTHON_FIGStmp))

# chktex wrapper to have exit on error
CHKTEX_WRAPPER=sh -c '\
  tmp="$$(chktex -q -v3 $$1)"; \
  if [ -n "$$tmp" ] ; then \
    chktex -q -v3 $$1; \
    exit 1; \
  fi' CHKTEX


main.pdf: fig_tikz
ifdef LATEXMK_EXISTS
	$(LATEXMK) main.tex
else
	$(LATEXEXE) main
	$(BIBTEXEXE) main
	$(LATEXEXE) main
	$(LATEXEXE) main
endif

all: fig_python main.pdf

cleanall: clean
	$(RM) main.pdf

clean: fig_python_clean fig_tikz_clean
	$(RM) *.toc *.nav *.out *.snm *.bak *.aux *.log *.bbl *.blg *.lof *.lot *.fls *.fdb_latexmk

fig_tikz_clean:
	@echo "make fig_tikz_clean"
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		$(RM) *aux *log *fls *.fdb_latexmk; \
		$(RM) $$folder".pdf"; \
		cd ../; \
	done

fig_python: $(PYTHON_FIGS)

fig/fig%.pdf: code/matplotlibrc code/fig%.py
	cd code; gridspeccer --mplrc matplotlibrc fig$*.py

fig_python_clean:
	$(RM) fig/*pdf

fig_tikz:
ifdef LATEXMK_EXISTS
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		echo "fig_tikz/$$folder/; latexmk -pdf $$folder.tex"; \
		${LATEXMK} $$folder".tex"; \
		cd ../; \
	done
else
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		echo "fig_tikz/$$folder/; pdflatex $$folder.tex"; \
		${LATEXEXE} $$folder".tex"; \
		cd ../; \
	done
endif

lint_tex:
	@echo "chktex -q -v3 main.tex"
	@${CHKTEX_WRAPPER} main.tex
	@cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		echo "chktex -q -v3 fig_tikz/$$folder/$$folder.tex"; \
		${CHKTEX_WRAPPER} $$folder".tex" || exit; \
		cd ../; \
	done


.PHONY: all main.pdf cleanall clean fig_tikz fig_tikz_clean fig_python_clean lint_tex

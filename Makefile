LATEXEXE=pdflatex
MV=mv
BIBTEXEXE=bibtex
LATEXMK_EXISTS := $(shell latexmk --version 2>/dev/null)
LATEXMK=latexmk -pdf


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
	cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		$(RM) *aux *log *fls *.fdb_latexmk; \
		$(RM) $$folder".pdf"; \
		cd ../; \
	done

fig_python:
	cd code; gridspeccer --mplrc matplotlibrc

fig_python_clean:
	rm fig/*pdf

fig_tikz:
ifdef LATEXMK_EXISTS
	cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		${LATEXMK} $$folder".tex"; \
		cd ../; \
	done
else
	cd fig_tikz; \
	for folder in *; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		${LATEXEXE} $$folder".tex"; \
		cd ../; \
	done
endif

lint_tex:
	chktex main.tex
	cd fig_tikz; \
		for folder in fig_*; do \
		[ -d "$$folder" ] || continue; \
		cd "$$folder"; \
		chktex $$folder".tex"; \
		cd ../; \
	done


.PHONY: all main.pdf cleanall clean fig_tikz fig_tikz_clean fig_python_clean lint_tex

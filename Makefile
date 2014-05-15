# You want latexmk to *always* run, because make does not have all the info.
.PHONY: trainee trainer example_trainee example_trainer

# First rule should always be the default "all" rule, so both "make all" and
# "make" will invoke it.
all: trainee trainer example_trainee example_trainer

# CUSTOM BUILD RULES

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.

%.tex: %.raw
	./raw2tex $< > $@

%.tex: %.dat
	./dat2tex $< > $@

# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.

# -interactive=nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.

trainee: handout.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' handout.tex
	latexmk -pdf -jobname=trainee_handout -pdflatex='pdflatex -halt-on-error %O %S -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make handout.tex

trainer: handout.tex
	/bin/sed -i -e 's@^\\usepackage{btp}@\\usepackage[trainermanual]{btp}@' handout.tex
	latexmk -pdf -jobname=trainer_handout -pdflatex='pdflatex -halt-on-error %O %S -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make handout.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' handout.tex

example_trainee: example.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' example.tex
	latexmk -pdf -jobname=trainee_example -pdflatex='pdflatex -halt-on-error %O %S -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make example.tex

example_trainer: example.tex
	/bin/sed -i -e 's@^\\usepackage{btp}@\\usepackage[trainermanual]{btp}@' example.tex
	latexmk -pdf -jobname=trainer_example -pdflatex='pdflatex -halt-on-error %O %S -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make example.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' example.tex
clean:
	latexmk -CA -jobname=trainee_handout handout.tex
	latexmk -CA -jobname=trainer_handout handout.tex
	latexmk -CA -jobname=trainee_example example.tex
	latexmk -CA -jobname=trainer_example example.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' handout.tex
	/bin/sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' example.tex

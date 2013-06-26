#!/bin/bash

HALFDAYSOURCE=halfday_handout.tex
HALFDAYTRAINEE_NAME=halfday_trainee_handout
HALFDAYTRAINER_NAME=halfday_trainer_handout


make_trainee() {
   sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' ${HALFDAYSOURCE}
   latexmk -pdf -jobname=${HALFDAYTRAINEE_NAME} -pdflatex='pdflatex -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make ${HALFDAYSOURCE}
}

make_trainer() {
   sed -i -e 's@^\\usepackage{btp}@\\usepackage[trainermanual]{btp}@' ${HALFDAYSOURCE}
   latexmk -pdf -jobname=${HALFDAYTRAINER_NAME} -pdflatex='pdflatex -synctex=1 -interaction=nonstopmode --src-specials' -quiet -f -use-make ${HALFDAYSOURCE}
   sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' ${HALFDAYSOURCE}
}

clean() {
   latexmk -CA -jobname=${HALFDAYTRAINEE_NAME} ${HALFDAYSOURCE}
   latexmk -CA -jobname=${HALFDAYTRAINER_NAME} ${HALFDAYSOURCE}
   sed -i -e 's@^\\usepackage\[trainermanual\]{btp}@\\usepackage{btp}@' ${HALFDAYSOURCE}
}

clean
make_trainee
make_trainer


